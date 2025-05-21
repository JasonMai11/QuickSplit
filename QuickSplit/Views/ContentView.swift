import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ReceiptViewModel()
    @State private var showingSettings = false
    @State private var showingScanner = false
    @State private var showingManualEntry = false
    @State private var showingParticipants = false
    
    var body: some View {
        NavigationView {
            List {
                if viewModel.receipts.isEmpty {
                    ContentUnavailableView(
                        "No Receipts",
                        systemImage: "receipt",
                        description: Text("Add a receipt to get started")
                    )
                } else {
                    ForEach(viewModel.receipts) { receipt in
                        NavigationLink(destination: ReceiptDetailView(viewModel: viewModel)) {
                            ReceiptRow(receipt: receipt)
                        }
                    }
                }
            }
            .onChange(of: viewModel.receipts) { receipts in
                print("Receipts array changed: \(receipts.count) receipts")
            }
            .navigationTitle("QuickSplit")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gear")
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack {
                        Button {
                            showingParticipants = true
                        } label: {
                            Image(systemName: "person.2")
                        }
                        
                        Button {
                            viewModel.createTestReceipt()
                        } label: {
                            Image(systemName: "testtube.2")
                        }
                    }
                }
                
                ToolbarItem(placement: .bottomBar) {
                    HStack {
                        Button {
                            showingScanner = true
                        } label: {
                            Label("Scan", systemImage: "camera")
                        }
                        
                        Spacer()
                        
                        Button {
                            showingManualEntry = true
                        } label: {
                            Label("Manual", systemImage: "pencil")
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView(viewModel: viewModel)
            }
            .sheet(isPresented: $showingScanner) {
                ReceiptScannerView(viewModel: viewModel)
            }
            .sheet(isPresented: $showingManualEntry) {
                ManualEntryView(viewModel: viewModel)
            }
            .sheet(isPresented: $showingParticipants) {
                ParticipantsView(viewModel: viewModel)
            }
        }
    }
}

struct ReceiptRow: View {
    let receipt: Receipt
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(receipt.date.formatted(date: .abbreviated, time: .shortened))
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack {
                Text(receipt.restaurantName)
                    .font(.headline)
                Spacer()
                Text(receipt.total.formatted(.currency(code: "USD")))
                    .font(.headline)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ContentView()
} 