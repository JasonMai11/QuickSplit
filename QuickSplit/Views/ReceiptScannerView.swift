import SwiftUI
import VisionKit

struct ReceiptScannerView: View {
    @ObservedObject var viewModel: ReceiptViewModel
    @State private var showingScanner = false
    @State private var showingManualEntry = false
    @State private var showingTestView = false
    
    var body: some View {
        NavigationView {
            VStack {
                if let receipt = viewModel.currentReceipt {
                    ReceiptDetailView(viewModel: viewModel)
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
            Image(systemName: "doc.text.viewfinder")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text("Scan a Receipt")
                .font(.title)
            
            Text("Take a photo of your receipt to get started")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: { showingScanner = true }) {
                Label("Scan Receipt", systemImage: "camera")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal)
            
            Button(action: { showingManualEntry = true }) {
                Label("Manual Entry", systemImage: "pencil")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .padding(.horizontal)
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