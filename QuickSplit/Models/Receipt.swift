import Foundation

struct Receipt: Identifiable, Codable, Equatable {
    let id: UUID
    var items: [ReceiptItem]
    var subtotal: Double
    var tax: Double
    var tip: Double
    var total: Double
    var date: Date
    var restaurantName: String
    
    init(id: UUID = UUID(), items: [ReceiptItem] = [], subtotal: Double = 0.0, tax: Double = 0.0, tip: Double = 0.0, total: Double = 0.0, date: Date = Date(), restaurantName: String = "") {
        self.id = id
        self.items = items
        self.subtotal = subtotal
        self.tax = tax
        self.tip = tip
        self.total = total
        self.date = date
        self.restaurantName = restaurantName
    }
    
    static func == (lhs: Receipt, rhs: Receipt) -> Bool {
        lhs.id == rhs.id
    }
}

struct ReceiptItem: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var price: Double
    var quantity: Int
    var sharedBy: [ItemShare]
    
    init(id: UUID = UUID(), name: String, price: Double, quantity: Int = 1, sharedBy: [ItemShare] = []) {
        self.id = id
        self.name = name
        self.price = price
        self.quantity = quantity
        self.sharedBy = sharedBy
    }
    
    var totalPrice: Double {
        price * Double(quantity)
    }
    
    var pricePerUnit: Double {
        price
    }
    
    var remainingQuantity: Int {
        let takenPortions = sharedBy.reduce(0) { total, share in
            if share.isShared {
                // For shared items, each person counts as 1 portion
                return total + 1
            } else {
                // For individual portions, count the actual portions taken
                return total + share.portions
            }
        }
        return max(0, quantity - takenPortions)
    }
    
    var sharingStatus: String {
        let sharedGroups = sharedBy.filter { $0.isShared }
        let individualShares = sharedBy.filter { !$0.isShared }
        
        var status = ""
        
        if !sharedGroups.isEmpty {
            let totalShared = sharedGroups.count // Count actual number of people sharing
            status += "Shared by \(totalShared) people"
        }
        
        if !individualShares.isEmpty {
            if !status.isEmpty {
                status += ", "
            }
            let totalIndividual = individualShares.reduce(0) { $0 + $1.portions }
            status += "\(totalIndividual) individual portions"
        }
        
        return status
    }
    
    static func == (lhs: ReceiptItem, rhs: ReceiptItem) -> Bool {
        lhs.id == rhs.id
    }
}

struct ItemShare: Identifiable, Codable, Equatable {
    let id: UUID
    var userId: UUID
    var userName: String
    var portions: Int // Number of portions this person is taking
    var isShared: Bool // Whether this is a shared item (like a platter)
    var dateAdded: Date // Track when the share was added
    
    init(id: UUID = UUID(), userId: UUID, userName: String, portions: Int = 1, isShared: Bool = false, dateAdded: Date = Date()) {
        self.id = id
        self.userId = userId
        self.userName = userName
        self.portions = portions
        self.isShared = isShared
        self.dateAdded = dateAdded
    }
    
    var shareAmount: Double {
        if isShared {
            return 1.0 / Double(portions) // Equal split for shared items
        } else {
            return Double(portions) // Direct portions for individual items
        }
    }
    
    static func == (lhs: ItemShare, rhs: ItemShare) -> Bool {
        lhs.id == rhs.id
    }
} 