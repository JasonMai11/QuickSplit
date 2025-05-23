import Foundation
import VisionKit
import Vision
import SwiftUI

@MainActor
class ReceiptViewModel: ObservableObject {
    @Published var receipts: [Receipt] = []
    @Published var currentReceipt: Receipt?
    @Published var isScanning = false
    @Published var errorMessage: String?
    @Published var tipPercentage: Double = 15.0
    @Published var includeTax: Bool = true
    @Published var currentUser: User?
    @Published var participants: [User] = []
    
    // MARK: - User Management
    
    func addParticipant(name: String) {
        let user = User(name: name)
        participants.append(user)
        if currentUser == nil {
            currentUser = user
        }
    }
    
    func removeParticipant(_ user: User) {
        participants.removeAll { $0.id == user.id }
        // Remove user's shares from all items
        if var receipt = currentReceipt {
            for i in 0..<receipt.items.count {
                receipt.items[i].sharedBy.removeAll { $0.userId == user.id }
            }
            currentReceipt = receipt
            calculateTotals()
        }
    }
    
    // MARK: - Item Sharing
    
    func shareItem(_ item: ReceiptItem, with user: User, portions: Int, isShared: Bool = false) {
        guard var receipt = currentReceipt else { return }
        
        if let index = receipt.items.firstIndex(where: { $0.id == item.id }) {
            if let existingShareIndex = receipt.items[index].sharedBy.firstIndex(where: { $0.userId == user.id }) {
                // If user already has a share, add to their portions
                let existingShare = receipt.items[index].sharedBy[existingShareIndex]
                let newPortions = existingShare.portions + portions
                let updatedShare = ItemShare(
                    id: existingShare.id,
                    userId: user.id,
                    userName: user.name,
                    portions: newPortions,
                    isShared: isShared,
                    dateAdded: existingShare.dateAdded
                )
                receipt.items[index].sharedBy[existingShareIndex] = updatedShare
            } else {
                // If user doesn't have a share, create a new one
                let share = ItemShare(userId: user.id, userName: user.name, portions: portions, isShared: isShared)
                receipt.items[index].sharedBy.append(share)
            }
            
            // Update both currentReceipt and the receipt in the receipts array
            currentReceipt = receipt
            if let receiptIndex = receipts.firstIndex(where: { $0.id == receipt.id }) {
                receipts[receiptIndex] = receipt
            }
            
            calculateTotals()
        }
    }
    
    func removeShare(_ share: ItemShare, from item: ReceiptItem) {
        guard var receipt = currentReceipt else { return }
        
        if let index = receipt.items.firstIndex(where: { $0.id == item.id }) {
            receipt.items[index].sharedBy.removeAll { $0.id == share.id }
            
            // Update both currentReceipt and the receipt in the receipts array
            currentReceipt = receipt
            if let receiptIndex = receipts.firstIndex(where: { $0.id == receipt.id }) {
                receipts[receiptIndex] = receipt
            }
            
            calculateTotals()
        }
    }
    
    // MARK: - Calculations
    
    func calculateTotals() {
        guard var receipt = currentReceipt else { return }
        
        // Calculate subtotal
        receipt.subtotal = receipt.items.reduce(0) { $0 + $1.totalPrice }
        
        // Calculate tax
        if includeTax {
            receipt.tax = receipt.subtotal * 0.08 // Assuming 8% tax rate
        } else {
            receipt.tax = 0
        }
        
        // Calculate tip
        receipt.tip = receipt.subtotal * (tipPercentage / 100.0)
        
        // Calculate total
        receipt.total = receipt.subtotal + receipt.tax + receipt.tip
        
        currentReceipt = receipt
    }
    
    func calculateUserTotal(_ user: User) -> Double {
        guard let receipt = currentReceipt else { return 0 }
        
        var userTotal: Double = 0
        
        // Calculate item shares
        for item in receipt.items {
            if let share = item.sharedBy.first(where: { $0.userId == user.id }) {
                if share.isShared {
                    // For shared items, divide the total price by the number of people sharing
                    userTotal += (item.totalPrice / Double(share.portions))
                } else {
                    // For individual portions, calculate based on the number of portions taken
                    userTotal += (item.price * Double(share.portions))
                }
            }
        }
        
        // Calculate proportional tax and tip
        let userSubtotal = userTotal
        let taxShare = (userSubtotal / receipt.subtotal) * receipt.tax
        let tipShare = (userSubtotal / receipt.subtotal) * receipt.tip
        
        return userSubtotal + taxShare + tipShare
    }
    
    // MARK: - Receipt Processing
    
    func processReceiptImage(_ image: UIImage) async {
        guard let cgImage = image.cgImage else {
            errorMessage = "Failed to process image"
            return
        }
        
        let requestHandler = VNImageRequestHandler(cgImage: cgImage)
        let request = VNRecognizeTextRequest()
        
        do {
            try await requestHandler.perform([request])
            if let observations = request.results {
                await processTextObservations(observations)
            }
        } catch {
            errorMessage = "Failed to process receipt: \(error.localizedDescription)"
        }
    }
    
    private func processTextObservations(_ observations: [VNRecognizedTextObservation]) async {
        let items = observations.compactMap { observation -> ReceiptItem? in
            guard let text = observation.topCandidates(1).first?.string else { return nil }
            let components = text.components(separatedBy: " ")
            if components.count >= 2,
               let price = Double(components.last?.replacingOccurrences(of: "$", with: "") ?? "") {
                let name = components.dropLast().joined(separator: " ")
                return ReceiptItem(name: name, price: price)
            }
            return nil
        }
        
        currentReceipt = Receipt(items: items)
        calculateTotals()
    }
    
    // MARK: - Item Management
    
    func addItem(_ item: ReceiptItem) {
        guard var receipt = currentReceipt else {
            currentReceipt = Receipt(items: [item])
            return
        }
        receipt.items.append(item)
        currentReceipt = receipt
        calculateTotals()
    }
    
    func removeItem(at index: Int) {
        guard var receipt = currentReceipt else { return }
        receipt.items.remove(at: index)
        currentReceipt = receipt
        calculateTotals()
    }
    
    // MARK: - Sharing
    
    func generateShareableLink() -> URL? {
        // TODO: Implement sharing functionality
        return nil
    }
    
    func generateQRCode() -> UIImage? {
        // TODO: Implement QR code generation
        return nil
    }
    
    // MARK: - Receipt Management
    
    func addReceipt(_ receipt: Receipt) {
        print("Adding receipt: \(receipt.restaurantName) with \(receipt.items.count) items")
        receipts.append(receipt)
        currentReceipt = receipt
        print("Total receipts: \(receipts.count)")
    }
    
    func removeReceipt(_ receipt: Receipt) {
        receipts.removeAll { $0.id == receipt.id }
        if currentReceipt?.id == receipt.id {
            currentReceipt = nil
        }
    }
    
    // MARK: - Testing
    
    func createTestReceipt() {
        print("Creating test receipt...")
        
        // Add test participants
        addParticipant(name: "John")
        addParticipant(name: "Sarah")
        addParticipant(name: "Mike")
        print("Added participants: \(participants.count)")
        
        // Create test items
        let items = [
            ReceiptItem(name: "Beef Skewers", price: 5.00, quantity: 3),
            ReceiptItem(name: "Big Platter", price: 30.00, quantity: 1),
            ReceiptItem(name: "Drinks", price: 3.50, quantity: 2)
        ]
        print("Created test items: \(items.count)")
        
        let testReceipt = Receipt(
            items: items,
            restaurantName: "Test Restaurant"
        )
        
        // Add the receipt to the receipts array
        addReceipt(testReceipt)
        
        // Calculate totals
        calculateTotals()
        print("Test receipt created and added to receipts array")
    }
}

struct User: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    
    init(id: UUID = UUID(), name: String) {
        self.id = id
        self.name = name
    }
    
    // Implement Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: User, rhs: User) -> Bool {
        lhs.id == rhs.id
    }
} 