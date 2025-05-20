import SwiftUI

struct ParticipantsView: View {
    @ObservedObject var viewModel: ReceiptViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var newParticipantName = ""
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Add Participant")) {
                    HStack {
                        TextField("Name", text: $newParticipantName)
                        Button("Add") {
                            if !newParticipantName.isEmpty {
                                viewModel.addParticipant(name: newParticipantName)
                                newParticipantName = ""
                            }
                        }
                        .disabled(newParticipantName.isEmpty)
                    }
                }
                
                Section(header: Text("Participants")) {
                    ForEach(viewModel.participants) { participant in
                        HStack {
                            Text(participant.name)
                            Spacer()
                            if participant.id == viewModel.currentUser?.id {
                                Text("(You)")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            let participant = viewModel.participants[index]
                            viewModel.removeParticipant(participant)
                        }
                    }
                }
            }
            .navigationTitle("Participants")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
} 