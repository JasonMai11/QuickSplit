import SwiftUI

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss
    
    // TODO: Replace with your actual support email
    private let supportEmail = "support@quicksplit.app"
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Group {
                        Text("Privacy Policy")
                            .font(.title)
                            .bold()
                        
                        Text("Last updated: \(Date().formatted(date: .long, time: .omitted))")
                            .foregroundColor(.secondary)
                        
                        Text("Introduction")
                            .font(.headline)
                        Text("QuickSplit is committed to protecting your privacy. This Privacy Policy explains how we collect, use, and safeguard your information when you use our app.")
                        
                        Text("Information We Collect")
                            .font(.headline)
                        Text("• Camera Access: We use your device's camera to scan receipts for bill splitting.\n• Photo Library Access: We access your photo library to let you select receipt photos.\n• Receipt Data: We process and store receipt information locally on your device to help you split bills.")
                        
                        Text("How We Use Your Information")
                            .font(.headline)
                        Text("• To provide bill splitting functionality\n• To process and store receipt information\n• To calculate and display bill splits\n• To share bill information with your selected contacts")
                        
                        Text("Data Storage")
                            .font(.headline)
                        Text("All your data is stored locally on your device. We do not upload or store your information on external servers.")
                        
                        Text("Third-Party Services")
                            .font(.headline)
                        Text("We use Apple's Vision framework for receipt scanning. This processing is done locally on your device.")
                        
                        Text("Your Rights")
                            .font(.headline)
                        Text("You can:\n• Access your data through the app\n• Delete your data by uninstalling the app\n• Control camera and photo library access through your device settings")
                        
                        Text("Contact Us")
                            .font(.headline)
                        Text("If you have any questions about this Privacy Policy, please contact us at:\n\(supportEmail)")
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    PrivacyPolicyView()
} 