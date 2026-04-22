import Foundation
import Combine

class LocalDatabase: ObservableObject {
    static let shared = LocalDatabase()
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    // Keys
    private let cropsKey = "fc_crops"
    private let ordersKey = "fc_orders"
    private let threadsKey = "fc_threads"
    private let notificationsKey = "fc_notifications"
    private let alertsKey = "fc_alerts"
    private let userKey = "fc_user"
    private let onboardingKey = "fc_onboarding"
    private let roleKey = "fc_pendingRole"

    // Published state
    @Published var crops: [Crop] = []
    @Published var orders: [Order] = []
    @Published var chatThreads: [ChatThread] = []
    @Published var notifications: [AppNotification] = []
    @Published var priceAlerts: [PriceAlert] = []

    init() {
        load()
        if crops.isEmpty { seedData() }
    }

    // MARK: - Persistence

    func load() {
        crops = loadObject(forKey: cropsKey) ?? []
        orders = loadObject(forKey: ordersKey) ?? []
        chatThreads = loadObject(forKey: threadsKey) ?? []
        notifications = loadObject(forKey: notificationsKey) ?? []
        priceAlerts = loadObject(forKey: alertsKey) ?? []
    }

    private func save<T: Encodable>(_ value: T, forKey key: String) {
        if let data = try? encoder.encode(value) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    private func loadObject<T: Decodable>(forKey key: String) -> T? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? decoder.decode(T.self, from: data)
    }

    // MARK: - User

    func saveUser(_ user: User) {
        save(user, forKey: userKey)
    }

    func loadUser() -> User? {
        loadObject(forKey: userKey)
    }

    func savePendingRole(_ role: UserRole?) {
        if let role = role {
            save(role, forKey: roleKey)
        } else {
            UserDefaults.standard.removeObject(forKey: roleKey)
        }
    }

    func loadPendingRole() -> UserRole? {
        loadObject(forKey: roleKey)
    }

    func saveOnboarding(_ seen: Bool) {
        UserDefaults.standard.set(seen, forKey: onboardingKey)
    }

    func loadOnboarding() -> Bool {
        UserDefaults.standard.bool(forKey: onboardingKey)
    }

    // MARK: - Crops

    func addCrop(_ crop: Crop) {
        crops.append(crop)
        save(crops, forKey: cropsKey)
        addNotification(title: "Listing Posted", body: "\(crop.name) is now live on the marketplace!", icon: "checkmark.circle.fill")
    }

    func updateCrop(_ crop: Crop) {
        if let idx = crops.firstIndex(where: { $0.id == crop.id }) {
            crops[idx] = crop
            save(crops, forKey: cropsKey)
        }
    }

    func deleteCrop(_ crop: Crop) {
        crops.removeAll { $0.id == crop.id }
        save(crops, forKey: cropsKey)
    }

    // MARK: - Orders

    func placeOrder(_ order: Order) {
        orders.append(order)
        save(orders, forKey: ordersKey)
        addNotification(title: "Order Placed!", body: "Your order for \(order.crop.name) has been placed.", icon: "bag.fill")
    }

    func updateOrderStatus(_ order: Order, status: OrderStatus) {
        if let idx = orders.firstIndex(where: { $0.id == order.id }) {
            orders[idx].status = status
            save(orders, forKey: ordersKey)
        }
    }

    // MARK: - Chat

    func sendMessage(to threadId: UUID, message: ChatMessage) {
        if let idx = chatThreads.firstIndex(where: { $0.id == threadId }) {
            chatThreads[idx].messages.append(message)
            chatThreads[idx].lastMessage = message.text
            chatThreads[idx].lastMessageTime = message.timestamp
            save(chatThreads, forKey: threadsKey)
        }
    }

    func findOrCreateThread(with participantName: String, role: UserRole, cropId: UUID? = nil) -> ChatThread {
        if let existing = chatThreads.first(where: { $0.participantName == participantName }) {
            return existing
        }
        let newThread = ChatThread(
            participantName: participantName,
            participantRole: role,
            lastMessage: "Start a conversation...",
            lastMessageTime: Date(),
            cropId: cropId,
            messages: []
        )
        chatThreads.append(newThread)
        save(chatThreads, forKey: threadsKey)
        return newThread
    }

    // MARK: - Notifications

    func addNotification(title: String, body: String, icon: String) {
        let n = AppNotification(title: title, body: body, date: Date(), icon: icon)
        notifications.insert(n, at: 0)
        save(notifications, forKey: notificationsKey)
    }

    func markNotificationRead(_ id: UUID) {
        if let idx = notifications.firstIndex(where: { $0.id == id }) {
            notifications[idx].isRead = true
            save(notifications, forKey: notificationsKey)
        }
    }

    func markAllNotificationsRead() {
        for idx in notifications.indices { notifications[idx].isRead = true }
        save(notifications, forKey: notificationsKey)
    }

    var unreadNotificationCount: Int { notifications.filter { !$0.isRead }.count }

    // MARK: - Price Alerts

    func addPriceAlert(_ alert: PriceAlert) {
        priceAlerts.append(alert)
        save(priceAlerts, forKey: alertsKey)
        addNotification(title: "Price Alert Set", body: "You'll be notified when \(alert.cropName) goes \(alert.condition.rawValue) ₹\(Int(alert.targetPrice))", icon: "bell.fill")
    }

    func removePriceAlert(_ alert: PriceAlert) {
        priceAlerts.removeAll { $0.id == alert.id }
        save(priceAlerts, forKey: alertsKey)
    }

    // MARK: - Saved Crops (Customer wishlist)
    func toggleSavedCrop(cropId: UUID, user: inout User) {
        if user.savedCropIds.contains(cropId) {
            user.savedCropIds.removeAll { $0 == cropId }
        } else {
            user.savedCropIds.append(cropId)
        }
        saveUser(user)
    }

    // MARK: - Seeding

    private func seedData() {
        let farmer1Id = UUID()
        let farmer2Id = UUID()
        let farmer3Id = UUID()

        crops = [
            Crop(name: "Tomato", pricePerKg: 45, quantityAvailable: 200, description: "Farm-fresh red tomatoes sourced from organic farms in Pune. No pesticides, naturally ripened.", farmerName: "Ramesh Singh", farmerId: farmer1Id, location: "Pune APMC", imageName: "leaf.fill", status: .active, category: "Vegetables", minOrderKg: 5),
            Crop(name: "Onion", pricePerKg: 30, quantityAvailable: 500, description: "Premium quality Nashik onions. Known for their rich flavour and long shelf life.", farmerName: "Suresh Patil", farmerId: farmer2Id, location: "Nashik Market", imageName: "leaf.circle.fill", status: .active, category: "Vegetables", minOrderKg: 10),
            Crop(name: "Wheat", pricePerKg: 28, quantityAvailable: 1000, description: "Grade A wheat from Punjab's golden fields. Ideal for flour, roti, and bread production.", farmerName: "Amit Kumar", farmerId: farmer3Id, location: "Ludhiana", imageName: "leaf.arrow.triangle.circlepath", status: .active, category: "Grains", minOrderKg: 50),
            Crop(name: "Potato", pricePerKg: 22, quantityAvailable: 300, description: "Fresh potatoes from Agra. Smooth skin, perfect for all cooking styles.", farmerName: "Vikram Yadav", farmerId: farmer1Id, location: "Agra Market", imageName: "leaf.fill", status: .active, category: "Vegetables", minOrderKg: 10),
            Crop(name: "Chilli", pricePerKg: 85, quantityAvailable: 80, description: "Spicy red chillies from Guntur – India's chilli capital. High capsaicin, naturally dried.", farmerName: "Ravi Reddy", farmerId: farmer2Id, location: "Guntur APMC", imageName: "flame.fill", status: .active, category: "Spices", minOrderKg: 2),
            Crop(name: "Rice", pricePerKg: 38, quantityAvailable: 600, description: "Basmati rice from the Himalayan foothills. Long-grain, aromatic, ideal for biryani.", farmerName: "Priya Sharma", farmerId: farmer3Id, location: "Dehradun", imageName: "plus.viewfinder", status: .active, category: "Grains", minOrderKg: 25)
        ]
        save(crops, forKey: cropsKey)

        chatThreads = [
            ChatThread(participantName: "Ramesh Singh", participantRole: .farmer, lastMessage: "Yes, tomatoes are available!", lastMessageTime: Date().addingTimeInterval(-3600), unreadCount: 1, messages: [
                ChatMessage(text: "Hi, is the tomato lot still available?", timestamp: Date().addingTimeInterval(-7200), isFromCurrentUser: true, senderName: "You"),
                ChatMessage(text: "Yes, tomatoes are available!", timestamp: Date().addingTimeInterval(-3600), isFromCurrentUser: false, senderName: "Ramesh Singh")
            ]),
            ChatThread(participantName: "Amit Kumar", participantRole: .farmer, lastMessage: "Can you give a bulk discount?", lastMessageTime: Date().addingTimeInterval(-86400), unreadCount: 0, messages: [
                ChatMessage(text: "Can you give a bulk discount?", timestamp: Date().addingTimeInterval(-86400), isFromCurrentUser: true, senderName: "You")
            ])
        ]
        save(chatThreads, forKey: threadsKey)

        notifications = [
            AppNotification(title: "Welcome to Farmers Connect!", body: "Discover fresh produce directly from farmers near you.", date: Date(), isRead: false, icon: "leaf.circle.fill"),
            AppNotification(title: "Tomato Price Alert", body: "Tomato prices dropped to ₹42/kg at Pune APMC.", date: Date().addingTimeInterval(-3600), isRead: false, icon: "arrow.down.circle.fill")
        ]
        save(notifications, forKey: notificationsKey)
    }
}
