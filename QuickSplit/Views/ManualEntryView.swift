import SwiftUI

struct ManualEntryView: View {
    @ObservedObject var viewModel: ReceiptViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var itemName = ""
    @State private var itemPrice = ""
    @State private var itemQuantity = 1
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Add Item")) {
                    TextField("Item Name", text: $itemName)
                        .accessibilityIdentifier("Item Name")
                    
                    TextField("Price", text: $itemPrice)
                        .accessibilityIdentifier("Price")
                        .keyboardType(.decimalPad)
                    
                    Stepper("Quantity: \(itemQuantity)", value: $itemQuantity, in: 1...99)
                        .accessibilityIdentifier("Quantity")
                }
                
                Section {
                    Button(action: addItem) {
                        Text("Add Item")
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                    }
                    .accessibilityIdentifier("Add Item")
                    .listRowBackground(Color.blue)
                    .disabled(itemName.isEmpty || itemPrice.isEmpty)
                }
            }
            .navigationTitle("Manual Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func addItem() {
        guard let price = Double(itemPrice) else { return }
        
        let item = ReceiptItem(
            name: itemName,
            price: price,
            quantity: itemQuantity
        )
        
        viewModel.addItem(item)
        
        // Reset fields
        itemName = ""
        itemPrice = ""
        itemQuantity = 1
    }
} 