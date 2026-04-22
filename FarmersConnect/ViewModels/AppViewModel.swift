import SwiftUI
import Combine

class AppViewModel: ObservableObject {
    // MARK: - State
    @Published var isAuthenticated = false
    @Published var hasSeenOnboarding = false
    @Published var currentUser: User?
    @Published var pendingRole: UserRole?

    let db = LocalDatabase.shared
    private var cancellables = Set<AnyCancellable>()

    init() {
        // Restore persisted session
        hasSeenOnboarding = db.loadOnboarding()
        pendingRole = db.loadPendingRole()
        if let savedUser = db.loadUser() {
            currentUser = savedUser
            isAuthenticated = true
            refreshAIPredictions()
        }

        // Keep db published changes flowing through
        db.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }.store(in: &cancellables)
        
        // Listen to Firebase Manager
        FirebaseManager.shared.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }.store(in: &cancellables)
        
        // Start live sync
        FirebaseManager.shared.startListeningToCrops()
        FirebaseManager.shared.startListeningToOrders()
        FirebaseManager.shared.startListeningToChats()
        
        // Fetch AI Predictions (Now with Gemini!)
        refreshAIPredictions()
    }
    
    // MARK: - Gemini AI Integration
    @Published var aiChatHistory: [ChatMessage] = []
    @Published var isAILoading = false
    @Published var aiWeatherForecast: String = "Loading weather forecast..."

    func refreshAIPredictions() {
        isAILoading = true
        let cropsToAnalyze = ["Tomato", "Onion", "Wheat"]
        var fetchedPredictions: [Prediction] = []
        let group = DispatchGroup()
        
        for crop in cropsToAnalyze {
            group.enter()
            GeminiService.shared.getPriceAnalysis(crop: crop) { text in
                let type: PredictionType = text.contains("rise") || text.contains("increase") ? .priceUp : .priceDrop
                fetchedPredictions.append(Prediction(text: text, type: type, cropName: crop))
                group.leave()
            }
        }
        
        // Also fetch weather for a default location or user location
        group.enter()
        GeminiService.shared.getWeatherForecast(location: currentUser?.location ?? "Maharashtra") { forecast in
            self.aiWeatherForecast = forecast
            group.leave()
        }
        
        group.notify(queue: .main) {
            self.livePredictions = fetchedPredictions
            self.isAILoading = false
        }
    }

    func sendAIChatMessage(_ text: String) {
        let userMsg = ChatMessage(text: text, timestamp: Date(), isFromCurrentUser: true, senderName: "You")
        aiChatHistory.append(userMsg)
        
        isAILoading = true
        let prompt = "You are the Farmers Connect AI Assistant. Help the user with agricultural advice, market trends, or app navigation. User says: \(text)"
        
        GeminiService.shared.generateContent(prompt: prompt) { result in
            DispatchQueue.main.async {
                self.isAILoading = false
                switch result {
                case .success(let response):
                    let aiMsg = ChatMessage(text: response, timestamp: Date(), isFromCurrentUser: false, senderName: "AI Assistant")
                    self.aiChatHistory.append(aiMsg)
                case .failure:
                    let errorMsg = ChatMessage(text: "Sorry, I'm having trouble connecting right now.", timestamp: Date(), isFromCurrentUser: false, senderName: "AI Assistant")
                    self.aiChatHistory.append(errorMsg)
                }
            }
        }
    }

    // MARK: - Auth (Firebase)
    @Published var authError: String? = nil
    @Published var needsOTPVerification = false
    @Published var livePredictions: [Prediction] = []

    func requestOTP(phoneNumber: String) {
        FirebaseManager.shared.verifyPhone(number: phoneNumber) { success, error in
            DispatchQueue.main.async {
                if success {
                    self.needsOTPVerification = true
                } else {
                    self.authError = error ?? "Unknown error"
                }
            }
        }
    }
    
    func verifyOTPAndLogin(otp: String, name: String = "Test User") {
        FirebaseManager.shared.signInWithOTP(verificationCode: otp) { success, result in
            DispatchQueue.main.async {
                if success {
                    if result == "need_profile" {
                        // User exists in auth but not Firestore, save them
                        let user = User(name: name, phoneNumber: "", role: self.pendingRole ?? .customer)
                        FirebaseManager.shared.saveUserProfile(user: user) { saved, _ in
                            if saved {
                                self.currentUser = user
                                self.isAuthenticated = true
                                self.db.saveUser(user)
                            }
                        }
                    } else if let fsUser = FirebaseManager.shared.currentUser {
                        self.currentUser = fsUser
                        self.isAuthenticated = true
                        self.db.saveUser(fsUser)
                    } else {
                        // Fallback logic for mock users if Firebase fails to map correctly
                        var user = User(name: name, phoneNumber: "", role: self.pendingRole ?? .customer)
                        self.db.saveUser(user)
                        self.currentUser = user
                        self.isAuthenticated = true
                    }
                    self.db.addNotification(title: "Welcome back!", body: "You logged in successfully.", icon: "person.circle.fill")
                    self.needsOTPVerification = false
                    self.refreshAIPredictions()
                } else {
                    self.authError = result ?? "OTP failed"
                }
            }
        }
    }

    func selectRole(_ role: UserRole) {

        pendingRole = role
        db.savePendingRole(role)
    }

    func logout() {
        FirebaseManager.shared.stopAllListeners()
        FirebaseManager.shared.signOut()
        isAuthenticated = false
        currentUser = nil
        pendingRole = nil
        db.savePendingRole(nil)
        UserDefaults.standard.removeObject(forKey: "fc_user")
    }

    func updateUser(_ user: User) {
        currentUser = user
        db.saveUser(user)
    }

    // MARK: - Onboarding

    func completeOnboarding() {
        hasSeenOnboarding = true
        db.saveOnboarding(true)
    }

    // MARK: - Crops (Live from Firebase)

    var availableCrops: [Crop] { FirebaseManager.shared.availableCrops.filter { $0.status == .active } }
    var farmerCrops: [Crop] {
        guard let uid = currentUser?.id else { return [] }
        return FirebaseManager.shared.availableCrops.filter { $0.farmerId == uid }
    }
    var searchCrops: [Crop] { FirebaseManager.shared.availableCrops.filter { $0.status != .soldOut } }

    func addCrop(name: String, price: Double, quantity: Int, description: String, location: String, category: String, minOrder: Int) {
        guard let user = currentUser else { return }
        let crop = Crop(
            name: name, pricePerKg: price, quantityAvailable: quantity,
            description: description, farmerName: user.name,
            farmerId: user.id, location: location,
            imageName: iconForCrop(name), status: .active,
            category: category, minOrderKg: minOrder
        )
        // Add to Firebase
        FirebaseManager.shared.addCrop(crop) { _ in }
        
        // Retain local notification
        db.addNotification(title: "Listing Posted", body: "\(crop.name) is now live on the marketplace!", icon: "checkmark.circle.fill")
    }

    func deleteCrop(_ crop: Crop) { FirebaseManager.shared.deleteCrop(crop) }
    func updateCrop(_ crop: Crop) { FirebaseManager.shared.updateCrop(crop) }

    // MARK: - Orders (Live from Firebase)

    var myOrders: [Order] {
        guard let user = currentUser else { return [] }
        if user.role == .customer {
            return FirebaseManager.shared.orders.filter { $0.buyerName == user.name }
        } else {
            return FirebaseManager.shared.orders.filter { $0.farmerName == user.name }
        }
    }

    func placeOrder(crop: Crop, quantity: Int, address: String) {
        guard let user = currentUser else { return }
        let order = Order(
            crop: crop, quantity: quantity,
            totalAmount: Double(quantity) * crop.pricePerKg,
            date: Date(), status: .pending,
            buyerName: user.name, buyerPhone: user.phoneNumber,
            deliveryAddress: address, farmerName: crop.farmerName
        )
        FirebaseManager.shared.placeOrder(order)
        db.addNotification(title: "Order Placed!", body: "Your order for \(crop.name) is sent.", icon: "bag.fill")
    }

    func updateOrderStatus(_ order: Order, status: OrderStatus) {
        FirebaseManager.shared.updateOrderStatus(order, status: status)
    }

    // MARK: - Chat (Live from Firebase)

    var chatThreads: [ChatThread] { FirebaseManager.shared.chatThreads }

    func findOrCreateThread(with name: String, role: UserRole, cropId: UUID? = nil) -> ChatThread {
        if let existing = FirebaseManager.shared.chatThreads.first(where: { $0.participantName == name }) {
            return existing
        }
        let newThread = ChatThread(
            participantName: name, participantRole: role,
            lastMessage: "Start a conversation...", lastMessageTime: Date(),
            cropId: cropId, messages: []
        )
        FirebaseManager.shared.saveThread(newThread)
        return newThread
    }

    func sendMessage(threadId: UUID, text: String) {
        guard let user = currentUser else { return }
        let msg = ChatMessage(text: text, timestamp: Date(), isFromCurrentUser: true, senderName: user.name)
        FirebaseManager.shared.sendMessage(to: threadId, message: msg)
    }

    // MARK: - Notifications

    var notifications: [AppNotification] { db.notifications }
    var unreadCount: Int { db.unreadNotificationCount }
    func markRead(_ id: UUID) { db.markNotificationRead(id) }
    func markAllRead() { db.markAllNotificationsRead() }

    // MARK: - Price Alerts

    var priceAlerts: [PriceAlert] { db.priceAlerts }
    func addPriceAlert(cropName: String, targetPrice: Double, condition: AlertCondition) {
        let alert = PriceAlert(cropName: cropName, targetPrice: targetPrice, condition: condition)
        db.addPriceAlert(alert)
    }
    func removePriceAlert(_ alert: PriceAlert) { db.removePriceAlert(alert) }

    // MARK: - Wishlist (Customer)

    var savedCrops: [Crop] {
        guard let user = currentUser else { return [] }
        return FirebaseManager.shared.availableCrops.filter { user.savedCropIds.contains($0.id) }
    }

    func toggleSaved(cropId: UUID) {
        guard var user = currentUser else { return }
        db.toggleSavedCrop(cropId: cropId, user: &user)
        currentUser = user
        FirebaseManager.shared.saveUserProfile(user: user) { _, _ in }
    }

    func isSaved(_ cropId: UUID) -> Bool {
        currentUser?.savedCropIds.contains(cropId) ?? false
    }

    // MARK: - Market Analytics

    var marketPrices: [MarketPrice] {
        [
            MarketPrice(marketName: "Pune APMC", price: 45, cropName: "Tomato", change: +5.2, trend: .up),
            MarketPrice(marketName: "Mumbai APMC", price: 48, cropName: "Tomato", change: +8.1, trend: .up),
            MarketPrice(marketName: "Nashik Market", price: 30, cropName: "Onion", change: -2.3, trend: .down),
            MarketPrice(marketName: "Delhi Azadpur", price: 35, cropName: "Onion", change: +1.1, trend: .up),
            MarketPrice(marketName: "Ludhiana Grain", price: 28, cropName: "Wheat", change: 0.0, trend: .stable)
        ]
    }

    var predictions: [Prediction] {
        if livePredictions.isEmpty {
            return [
                Prediction(text: "Tomato prices likely to rise 12% next week", type: .priceUp, cropName: "Tomato"),
                Prediction(text: "High demand for chillies in local area", type: .demandHigh, cropName: "Chilli"),
                Prediction(text: "Wheat prices stable for the next 30 days", type: .demandHigh, cropName: "Wheat"),
                Prediction(text: "Onion oversupply — expect price drop", type: .priceDrop, cropName: "Onion")
            ]
        }
        return livePredictions
    }

    // MARK: - Helpers

    func iconForCrop(_ name: String) -> String {
        switch name.lowercased() {
        case "tomato": return "leaf.fill"
        case "onion": return "leaf.circle.fill"
        case "wheat", "rice": return "leaf.arrow.triangle.circlepath"
        case "chilli": return "flame.fill"
        case "potato": return "leaf.fill"
        default: return "leaf.circle"
        }
    }
}
