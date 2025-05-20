import SwiftUI
import VisionKit

struct ReceiptScannerView: View {
    @StateObject private var viewModel = ReceiptViewModel()
    @State private var showingScanner = false
    @State private var showingManualEntry = false
    @State private var showingTestView = false
    
    var body: some View {
        NavigationView {
            VStack {
                if let receipt = viewModel.currentReceipt {
                    ReceiptDetailView(receipt: receipt, viewModel: viewModel)
                } else {
                    welcomeView
                }
            }
            .navigationTitle("QuickSplit")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingScanner = true }) {
                        Image(systemName: "doc.text.viewfinder")
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showingTestView = true }) {
                        Image(systemName: "testtube.2")
                    }
                }
            }
            .sheet(isPresented: $showingScanner) {
                DocumentScannerView(viewModel: viewModel)
            }
            .sheet(isPresented: $showingManualEntry) {
                ManualEntryView(viewModel: viewModel)
            }
            .sheet(isPresented: $showingTestView) {
                TestShareView()
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: {
                if let error = viewModel.errorMessage {
                    Text(error)
                }
            }
        }
    }
    
    private var welcomeView: some View {
        VStack(spacing: 20) {
            Image(systemName: "receipt")
                .font(.system(size: 60))
                .foregroundColor(.blue)
                .accessibilityIdentifier("receipt")
            
            Text("Welcome to QuickSplit")
                .font(.title)
                .bold()
                .accessibilityIdentifier("Welcome to QuickSplit")
            
            Text("Scan a receipt to get started")
                .foregroundColor(.secondary)
                .accessibilityIdentifier("Scan a receipt to get started")
            
            Button(action: { showingScanner = true }) {
                Label("Scan Receipt", systemImage: "doc.text.viewfinder")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .accessibilityIdentifier("Scan Receipt")
            
            Button(action: { showingManualEntry = true }) {
                Label("Enter Manually", systemImage: "pencil")
                    .font(.headline)
                    .foregroundColor(.blue)
            }
            .accessibilityIdentifier("Enter Manually")
        }
        .padding()
    }
}

struct DocumentScannerView: UIViewControllerRepresentable {
    let viewModel: ReceiptViewModel
    
    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let scannerViewController = VNDocumentCameraViewController()
        scannerViewController.delegate = context.coordinator
        return scannerViewController
    }
    
    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        let parent: DocumentScannerView
        
        init(_ parent: DocumentScannerView) {
            self.parent = parent
        }
        
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            let image = scan.imageOfPage(at: 0)
            Task {
                await parent.viewModel.processReceiptImage(image)
            }
            controller.dismiss(animated: true)
        }
        
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
            Task { @MainActor in
                parent.viewModel.errorMessage = error.localizedDescription
            }
            controller.dismiss(animated: true)
        }
        
        func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
            controller.dismiss(animated: true)
        }
    }
} 