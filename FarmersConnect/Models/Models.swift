import Foundation

// MARK: - Enums

enum UserRole: String, CaseIterable, Identifiable, Codable {
    case farmer = "Farmer"
    case customer = "Customer"
    var id: String { self.rawValue }
}

enum PredictionType: String, Codable {
    case priceUp
    case demandHigh
    case priceDrop
    case demandLow
}

enum OrderStatus: String, Codable, CaseIterable {
    case pending = "Pending"
    case confirmed = "Confirmed"
    case dispatched = "Dispatched"
    case delivered = "Delivered"
    case cancelled = "Cancelled"
}

enum CropStatus: String, Codable {
    case active = "Active"
    case soldOut = "Sold Out"
    case draft = "Draft"
}

// MARK: - User

struct User: Identifiable, Codable {
    var id = UUID()
    var name: String
    var phoneNumber: String
    var role: UserRole?
    var location: String?
    var isVerified: Bool = false
    var rating: Double?
    var bio: String?
    var email: String?
    var farmName: String?          // farmers only
    var farmSizeAcres: Double?     // farmers only
    var savedCropIds: [UUID] = []  // customers: saved/wishlist crops
}

// MARK: - Crop

struct Crop: Identifiable, Codable {
    var id = UUID()
    var name: String
    var pricePerKg: Double
    var quantityAvailable: Int
    var description: String
    var farmerName: String
    var farmerId: UUID?
    var location: String
    var imageName: String
    var status: CropStatus = .active
    var category: String = "Vegetables"
    var listedDate: Date = Date()
    var minOrderKg: Int = 1
}

// MARK: - Order

struct Order: Identifiable, Codable {
    var id = UUID()
    var crop: Crop
    var quantity: Int
    var totalAmount: Double
    var date: Date
    var status: OrderStatus
    var buyerName: String
    var buyerPhone: String
    var deliveryAddress: String
    var farmerName: String
}

// MARK: - ChatThread

struct ChatThread: Identifiable, Codable {
    var id = UUID()
    var participantName: String
    var participantRole: UserRole
    var lastMessage: String
    var lastMessageTime: Date
    var unreadCount: Int = 0
    var cropId: UUID?
    var messages: [ChatMessage] = []
}

struct ChatMessage: Identifiable, Codable {
    var id = UUID()
    var text: String
    var timestamp: Date
    var isFromCurrentUser: Bool
    var senderName: String
}

// MARK: - Market

struct MarketPrice: Identifiable, Codable {
    var id = UUID()
    var marketName: String
    var price: Double
    var cropName: String
    var change: Double = 0.0  // % change
    var trend: PriceTrend = .stable
}

enum PriceTrend: String, Codable {
    case up, down, stable
}

// MARK: - Prediction / Notification

struct Prediction: Identifiable, Codable {
    var id = UUID()
    var text: String
    var type: PredictionType
    var cropName: String = ""
    var date: Date = Date()
}

struct AppNotification: Identifiable, Codable {
    var id = UUID()
    var title: String
    var body: String
    var date: Date
    var isRead: Bool = false
    var icon: String
    var color: String = "2E7D32"
}

// MARK: - Price Alert

struct PriceAlert: Identifiable, Codable {
    var id = UUID()
    var cropName: String
    var targetPrice: Double
    var condition: AlertCondition
    var isActive: Bool = true
    var createdDate: Date = Date()
}

enum AlertCondition: String, Codable {
    case above = "Above"
    case below = "Below"
}
