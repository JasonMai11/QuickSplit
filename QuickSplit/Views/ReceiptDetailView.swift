import SwiftUI

struct ReceiptDetailView: View {
    let receipt: Receipt
    @ObservedObject var viewModel: ReceiptViewModel
    @State private var showingShareSheet = false
    @State private var showingShareDialog = false
    @State private var selectedItem: ReceiptItem?
    
    var body: some View {
        List {
            Section(header: Text("Items")) {
                ForEach(receipt.items) { item in
                    ReceiptItemRow(item: item, viewModel: viewModel)
                        .onTapGesture {
                            selectedItem = item
                            showingShareDialog = true
                        }
                }
            }
            
            Section(header: Text("Summary")) {
                HStack {
                    Text("Subtotal")
                    Spacer()
                    Text("$\(String(format: "%.2f", receipt.subtotal))")
                }
                
                if viewModel.includeTax {
                    HStack {
                        Text("Tax")
                            .accessibilityIdentifier("Tax Label")
                        Spacer()
                        Text("$\(String(format: "%.2f", receipt.tax))")
                            .accessibilityIdentifier("Tax Amount")
                    }
                }
                
                HStack {
                    Text("Tip (\(Int(viewModel.tipPercentage))%)")
                        .accessibilityIdentifier("Tip Label")
                    Spacer()
                    Text("$\(String(format: "%.2f", receipt.tip))")
                        .accessibilityIdentifier("Tip Amount")
                }
                
                HStack {
                    Text("Total")
                        .fontWeight(.bold)
                    Spacer()
                    Text("$\(String(format: "%.2f", receipt.total))")
                        .fontWeight(.bold)
                }
            }
            
            if !viewModel.participants.isEmpty {
                Section(header: Text("Individual Totals")) {
                    ForEach(viewModel.participants) { participant in
                        HStack {
                            Text(participant.name)
                            Spacer()
                            Text("$\(String(format: "%.2f", viewModel.calculateUserTotal(participant)))")
                        }
                    }
                }
            }
            
            Section {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Tip Percentage")
                    Slider(value: $viewModel.tipPercentage, in: 0...30, step: 1)
                        .accessibilityIdentifier("Tip Percentage")
                        .onChange(of: viewModel.tipPercentage) { _ in
                            viewModel.calculateTotals()
                        }
                }
                
                Toggle("Include Tax", isOn: $viewModel.includeTax)
                    .accessibilityIdentifier("Include Tax")
                    .onChange(of: viewModel.includeTax) { _ in
                        viewModel.calculateTotals()
                    }
            }
            
            Section {
                Button(action: { showingShareSheet = true }) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("Share Split")
                    }
                }
                .accessibilityIdentifier("Share Split")
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(items: [generateShareText()])
                .accessibilityIdentifier("Share Sheet")
        }
        .sheet(isPresented: $showingShareDialog) {
            if let item = selectedItem {
                ShareItemView(item: item, viewModel: viewModel)
            }
        }
    }
    
    private func generateShareText() -> String {
        let itemsText = receipt.items.map { item in
            let sharesText = item.sharedBy.map { share in
                "  - \(share.userName): \(share.portions) portion\(share.portions > 1 ? "s" : "")"
            }.joined(separator: "\n")
            
            return """
            • \(item.name): $\(String(format: "%.2f", item.price)) × \(item.quantity)
            \(sharesText)
            """
        }.joined(separator: "\n\n")
        
        let taxText = viewModel.includeTax ? "\nTax: $\(String(format: "%.2f", receipt.tax))" : ""
        
        let individualTotals = viewModel.participants.map { participant in
            "• \(participant.name): $\(String(format: "%.2f", viewModel.calculateUserTotal(participant)))"
        }.joined(separator: "\n")
        
        return """
        QuickSplit Bill Breakdown
        
        Items:
        \(itemsText)
        
        Subtotal: $\(String(format: "%.2f", receipt.subtotal))\(taxText)
        Tip (\(Int(viewModel.tipPercentage))%): $\(String(format: "%.2f", receipt.tip))
        Total: $\(String(format: "%.2f", receipt.total))
        
        Individual Totals:
        \(individualTotals)
        """
    }
}

struct ReceiptItemRow: View {
    let item: ReceiptItem
    @ObservedObject var viewModel: ReceiptViewModel
    @State private var showingShareDialog = false
    @State private var selectedShare: ItemShare?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                VStack(alignment: .leading) {
                    Text(item.name)
                        .font(.headline)
                    Text("$\(String(format: "%.2f", item.price)) each")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if item.quantity > 1 {
                    Text("×\(item.quantity)")
                        .foregroundColor(.secondary)
                }
            }
            
            if !item.sharedBy.isEmpty {
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.sharingStatus)
                        .font(.caption)
                        .foregroundColor(.blue)
                        .padding(.bottom, 2)
                    
                    ForEach(item.sharedBy) { share in
                        HStack {
                            Text("• \(share.userName)")
                                .font(.caption)
                            if share.isShared {
                                Text("(shared)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            } else {
                                Text("(\(share.portions) portion\(share.portions > 1 ? "s" : ""))")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                selectedShare = share
                                showingShareDialog = true
                            }) {
                                Image(systemName: "pencil")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                viewModel.removeShare(share, from: item)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
                .padding(.leading)
            }
            
            if item.remainingQuantity > 0 {
                HStack {
                    Spacer()
                    Text("\(item.remainingQuantity) portion\(item.remainingQuantity > 1 ? "s" : "") remaining")
                        .font(.caption)
                        .foregroundColor(.green)
                        .padding(.top, 2)
                }
            } else {
                HStack {
                    Spacer()
                    Text("All portions accounted for")
                        .font(.caption)
                        .foregroundColor(.green)
                        .padding(.top, 2)
                }
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onTapGesture {
            showingShareDialog = true
        }
        .sheet(isPresented: $showingShareDialog) {
            if let share = selectedShare {
                EditShareView(item: item, share: share, viewModel: viewModel)
            } else {
                ShareItemView(item: item, viewModel: viewModel)
            }
        }
    }
}

struct EditShareView: View {
    let item: ReceiptItem
    let share: ItemShare
    @ObservedObject var viewModel: ReceiptViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var portions: Int
    @State private var isShared: Bool
    
    init(item: ReceiptItem, share: ItemShare, viewModel: ReceiptViewModel) {
        self.item = item
        self.share = share
        self.viewModel = viewModel
        _portions = State(initialValue: share.portions)
        _isShared = State(initialValue: share.isShared)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Item Details")) {
                    Text(item.name)
                    Text("$\(String(format: "%.2f", item.price)) each")
                    Text("Quantity: \(item.quantity)")
                }
                
                Section(header: Text("Edit Share")) {
                    Text("Shared by: \(share.userName)")
                    
                    Toggle("Shared Item", isOn: $isShared)
                    
                    if isShared {
                        Stepper("Number of People: \(portions)", value: $portions, in: 2...max(2, item.quantity))
                    } else {
                        Stepper("Portions: \(portions)", value: $portions, in: 1...item.quantity)
                    }
                }
                
                Section {
                    Button("Update Share") {
                        if let user = viewModel.participants.first(where: { $0.id == share.userId }) {
                            viewModel.shareItem(item, with: user, portions: portions, isShared: isShared)
                        }
                        dismiss()
                    }
                }
            }
            .navigationTitle("Edit Share")
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
}

struct ShareItemView: View {
    let item: ReceiptItem
    @ObservedObject var viewModel: ReceiptViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedUser: User?
    @State private var portions: Int = 1
    @State private var isShared: Bool = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Item Details")) {
                    Text(item.name)
                    Text("$\(String(format: "%.2f", item.price)) each")
                    Text("Quantity: \(item.quantity)")
                }
                
                Section(header: Text("Share With")) {
                    if !viewModel.participants.isEmpty {
                        Picker("Select Person", selection: $selectedUser) {
                            Text("Select a person").tag(nil as User?)
                            ForEach(viewModel.participants) { user in
                                Text(user.name).tag(user as User?)
                            }
                        }
                    } else {
                        Text("No participants added")
                            .foregroundColor(.secondary)
                    }
                    
                    if selectedUser != nil {
                        Toggle("Shared Item", isOn: $isShared)
                        
                        if isShared {
                            Stepper("Number of People: \(portions)", value: $portions, in: 2...viewModel.participants.count)
                        } else {
                            Stepper("Portions: \(portions)", value: $portions, in: 1...item.quantity)
                        }
                    }
                }
                
                if let user = selectedUser {
                    Section {
                        Button("Share") {
                            viewModel.shareItem(item, with: user, portions: portions, isShared: isShared)
                            dismiss()
                        }
                    }
                }
            }
            .navigationTitle("Share Item")
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
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
} 