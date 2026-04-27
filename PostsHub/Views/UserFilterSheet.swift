import SwiftUI

struct UserFilterSheet: View {
    @EnvironmentObject var store: PostStore
    @Binding var selectedUserId: Int?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Button {
                    selectedUserId = nil
                    dismiss()
                } label: {
                    HStack {
                        Text("All Users")
                        Spacer()
                        if selectedUserId == nil {
                            Image(systemName: "checkmark")
                        }
                    }
                }

                ForEach(store.users) { user in
                    Button {
                        selectedUserId = user.id
                        dismiss()
                    } label: {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(user.name).foregroundStyle(.primary)
                                Text("@\(user.username)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            if selectedUserId == user.id {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            }
            .navigationTitle("Filter by User")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
