import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: ReceiptViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showingPrivacyPolicy = false
    
    // TODO: Replace with your actual App Store ID after app creation
    private let appStoreId = "YOUR_APP_STORE_ID"
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Bill Settings")) {
                    VStack(alignment: .leading) {
                        Text("Default Tip Percentage")
                        Slider(value: $viewModel.tipPercentage, in: 0...30, step: 1) {
                            Text("Default Tip")
                        } minimumValueLabel: {
                            Text("0%")
                        } maximumValueLabel: {
                            Text("30%")
                        }
                        Text("\(Int(viewModel.tipPercentage))%")
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 8)
                    
                    Toggle("Include Tax in Split", isOn: $viewModel.includeTax)
                }
                
                Section(header: Text("Privacy")) {
                    Button("Privacy Policy") {
                        showingPrivacyPolicy = true
                    }
                    
                    Link("App Privacy on App Store", 
                         destination: URL(string: "https://apps.apple.com/app/id\(appStoreId)/privacy")!)
                }
                
                Section(header: Text("About")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingPrivacyPolicy) {
                PrivacyPolicyView()
            }
        }
    }
}

#Preview {
    SettingsView(viewModel: ReceiptViewModel())
} 