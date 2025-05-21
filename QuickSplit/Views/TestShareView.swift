import SwiftUI

struct TestShareView: View {
    @StateObject private var viewModel = ReceiptViewModel()
    @State private var showingReceiptDetail = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Share Functionality Test")
                .font(.title)
            
            Button("Create Test Receipt") {
                viewModel.createTestReceipt()
                showingReceiptDetail = true
            }
            .buttonStyle(.borderedProminent)
        }
        .sheet(isPresented: $showingReceiptDetail) {
            ReceiptDetailView(viewModel: viewModel)
        }
    }
}

#Preview {
    TestShareView()
} 