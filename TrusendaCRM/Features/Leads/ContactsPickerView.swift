import SwiftUI
import Contacts

/// Contacts Picker - Import from iPhone Contacts
struct ContactsPickerView: View {
    @Environment(\.dismiss) private var dismiss
    var onContactSelected: (String, String?, String?) -> Void
    
    @State private var contacts: [CNContact] = []
    @State private var searchText = ""
    @State private var permissionDenied = false
    
    var filteredContacts: [CNContact] {
        if searchText.isEmpty {
            return contacts
        }
        return contacts.filter { contact in
            let fullName = "\(contact.givenName) \(contact.familyName)".lowercased()
            return fullName.contains(searchText.lowercased())
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if contacts.isEmpty && !permissionDenied {
                    // Loading state
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Loading contacts...")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if permissionDenied {
                    // Permission denied state
                    VStack(spacing: 20) {
                        Image(systemName: "person.crop.circle.badge.xmark")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        
                        Text("Contacts Access Required")
                            .font(.title3.bold())
                        
                        Text("To import from your contacts, please enable access in Settings")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        
                        Button {
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(url)
                            }
                        } label: {
                            Label("Open Settings", systemImage: "gear")
                        }
                        .buttonStyle(.bordered)
                        .tint(.primaryBlue)
                    }
                    .padding()
                } else {
                    List {
                        ForEach(filteredContacts, id: \.identifier) { contact in
                            Button {
                                selectContact(contact)
                            } label: {
                                HStack(spacing: 12) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.primaryBlue.opacity(0.1))
                                            .frame(width: 40, height: 40)
                                        Text(getInitials(contact))
                                            .font(.headline)
                                            .foregroundColor(.primaryBlue)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("\(contact.givenName) \(contact.familyName)")
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                        
                                        if let email = contact.emailAddresses.first?.value as String? {
                                            Text(email)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                    .searchable(text: $searchText, prompt: "Search contacts")
                }
            }
            .navigationTitle("Import Contact")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                requestContactsAccess()
            }
        }
    }
    
    private func requestContactsAccess() {
        let store = CNContactStore()
        
        // Move to background thread to avoid UI unresponsiveness
        DispatchQueue.global(qos: .userInitiated).async {
            store.requestAccess(for: .contacts) { granted, error in
                if granted {
                    fetchContacts()
                } else {
                    DispatchQueue.main.async {
                        permissionDenied = true
                    }
                }
            }
        }
    }
    
    private func fetchContacts() {
        // Run on background thread
        DispatchQueue.global(qos: .userInitiated).async {
            let store = CNContactStore()
            let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactEmailAddressesKey, CNContactPhoneNumbersKey] as [CNKeyDescriptor]
            let request = CNContactFetchRequest(keysToFetch: keys)
            
            var fetchedContacts: [CNContact] = []
            
            do {
                try store.enumerateContacts(with: request) { contact, _ in
                    fetchedContacts.append(contact)
                }
                
                // Update UI on main thread
                DispatchQueue.main.async {
                    self.contacts = fetchedContacts.sorted { c1, c2 in
                        c1.givenName < c2.givenName
                    }
                }
            } catch {
                print("Failed to fetch contacts:", error)
                DispatchQueue.main.async {
                    permissionDenied = true
                }
            }
        }
    }
    
    private func selectContact(_ contact: CNContact) {
        let name = "\(contact.givenName) \(contact.familyName)".trimmingCharacters(in: .whitespaces)
        let email = contact.emailAddresses.first?.value as String?
        let phone = contact.phoneNumbers.first?.value.stringValue
        
        print("📱 Contact selected:")
        print("   Name: \(name)")
        print("   Email: \(email ?? "none")")
        print("   Phone: \(phone ?? "none")")
        
        // Haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        // Call the callback with contact data
        onContactSelected(name, email, phone)
        
        // Dismiss contacts picker
        dismiss()
    }
    
    private func getInitials(_ contact: CNContact) -> String {
        let first = contact.givenName.prefix(1)
        let last = contact.familyName.prefix(1)
        return "\(first)\(last)".uppercased()
    }
}

