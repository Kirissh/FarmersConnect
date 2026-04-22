import Foundation
import Combine

// MARK: - Mock Firebase Manager (No Dependencies)
// Fully decoupled from Firebase for a smooth MVP presentation
class FirebaseManager: ObservableObject {
    static let shared = FirebaseManager()
    
    @Published var currentUser: User?
    @Published var verificationID: String?
    
    // In-memory data store to handle app state during presentation
    @Published var availableCrops: [Crop] = []
    @Published var orders: [Order] = []
    @Published var chatThreads: [ChatThread] = []
    
    init() {
        // Pre-populate with sample data to make the app look "alive"
        setupMockData()
    }
    
    private func setupMockData() {
        self.availableCrops = [
            Crop(name: "Organic Tomatoes", pricePerKg: 45, quantityAvailable: 200, description: "Fresh, vine-ripened organic tomatoes from Pune.", farmerName: "Rajesh Kumar", farmerId: UUID(), location: "Pune, MH", imageName: "leaf.fill", status: .active, category: "Vegetables", minOrderKg: 10),
            Crop(name: "Nagpur Oranges", pricePerKg: 65, quantityAvailable: 500, description: "Sweet and juicy Nagpur oranges, world famous.", farmerName: "Sunil Shinde", farmerId: UUID(), location: "Nagpur, MH", imageName: "sun.max.fill", status: .active, category: "Fruits", minOrderKg: 20),
            Crop(name: "Basmati Rice", pricePerKg: 120, quantityAvailable: 1000, description: "Long grain aromatic Basmati rice from the foothills.", farmerName: "Guru Singh", farmerId: UUID(), location: "Amritsar, PB", imageName: "leaf.circle", status: .active, category: "Grains", minOrderKg: 50),
            Crop(name: "Red Chillies", pricePerKg: 85, quantityAvailable: 50, description: "Hot and spicy red chillies, dried and sorted.", farmerName: "Anita Patil", farmerId: UUID(), location: "Guntur, AP", imageName: "flame.fill", status: .active, category: "Spices", minOrderKg: 5)
        ]
        
        self.chatThreads = [
            ChatThread(participantName: "Market Support", participantRole: .customer, lastMessage: "Welcome to Farmers Connect! How can we help?", lastMessageTime: Date(), cropId: nil, messages: [
                ChatMessage(text: "Welcome to Farmers Connect! How can we help?", timestamp: Date(), isFromCurrentUser: false, senderName: "Support")
            ])
        ]
    }
    
    // MARK: - Mock Auth (Simulates Firebase Auth)
    func verifyPhone(number: String, completion: @escaping (Bool, String?) -> Void) {
        print("MOCK: Verifying phone +91 \(number)")
        self.verificationID = "mock_id_123"
        completion(true, nil)
    }
    
    func signInWithOTP(verificationCode: String, completion: @escaping (Bool, String?) -> Void) {
        print("MOCK: Logged in with OTP: \(verificationCode)")
        // In local mock, any OTP works!
        completion(true, "need_profile")
    }
    
    func saveUserProfile(user: User, completion: @escaping (Bool, String?) -> Void) {
        DispatchQueue.main.async {
            self.currentUser = user
            completion(true, nil)
        }
    }
    
    func signOut() {
        self.currentUser = nil
        print("MOCK: User signed out")
    }
    
    // MARK: - Mock Data Operations (Synchronous placeholders)
    func startListeningToCrops() { /* Handled locally */ }
    func stopListeningToCrops() { /* Handled locally */ }
    
    func addCrop(_ crop: Crop, completion: @escaping (Bool) -> Void) {
        DispatchQueue.main.async {
            self.availableCrops.append(crop)
            completion(true)
        }
    }
    
    func deleteCrop(_ crop: Crop) {
        DispatchQueue.main.async {
            self.availableCrops.removeAll { $0.id == crop.id }
        }
    }
    
    func updateCrop(_ crop: Crop) {
        DispatchQueue.main.async {
            if let index = self.availableCrops.firstIndex(where: { $0.id == crop.id }) {
                self.availableCrops[index] = crop
            }
        }
    }
    
    func startListeningToOrders() { /* Handled locally */ }
    
    func placeOrder(_ order: Order) {
        DispatchQueue.main.async {
            self.orders.append(order)
            print("MOCK: Order successfully placed locally.")
        }
    }
    
    func updateOrderStatus(_ order: Order, status: OrderStatus) {
        DispatchQueue.main.async {
            if let index = self.orders.firstIndex(where: { $0.id == order.id }) {
                self.orders[index].status = status
            }
        }
    }
    
    func startListeningToChats() { /* Handled locally */ }
    
    func saveThread(_ thread: ChatThread) {
        DispatchQueue.main.async {
            if let index = self.chatThreads.firstIndex(where: { $0.id == thread.id }) {
                self.chatThreads[index] = thread
            } else {
                self.chatThreads.append(thread)
            }
        }
    }
    
    func sendMessage(to threadId: UUID, message: ChatMessage) {
        DispatchQueue.main.async {
            guard var thread = self.chatThreads.first(where: { $0.id == threadId }) else { return }
            thread.messages.append(message)
            thread.lastMessage = message.text
            thread.lastMessageTime = message.timestamp
            self.saveThread(thread)
            
            // Simulate an auto-reply for the demo experience
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                let reply = ChatMessage(text: "Thank you for contacting us! We'll respond shortly.", timestamp: Date(), isFromCurrentUser: false, senderName: thread.participantName)
                thread.messages.append(reply)
                thread.lastMessage = "Thank you for contacting us!"
                thread.lastMessageTime = Date()
                self.saveThread(thread)
            }
        }
    }
    
    func stopAllListeners() { /* No-op */ }
}
