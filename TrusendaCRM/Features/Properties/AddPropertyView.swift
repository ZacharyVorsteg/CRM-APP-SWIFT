import SwiftUI
import PhotosUI

struct AddPropertyView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var viewModel: PropertyViewModel
    
    @State private var title = ""
    @State private var address = ""
    @State private var city = ""
    @State private var state = ""
    @State private var zipCode = ""
    @State private var propertyType = ""
    @State private var transactionType = "Lease"
    @State private var sizeRange = ""
    @State private var sizeMin = ""
    @State private var sizeMax = ""
    @State private var price = ""
    @State private var budget = ""
    @State private var leaseTerm = ""
    @State private var industry = ""
    @State private var availableDate = ""
    @State private var description = ""
    @State private var features = ""
    @State private var status = "Available"
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var images: [String] = []
    @State private var isSubmitting = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    // Same options as Lead form (consistency)
    let propertyTypes = ["Warehouse", "Manufacturing", "Land", "Office", "Retail", "Mixed Use", "Industrial", "Flex", "Other"]
    let transactionTypes = ["Lease", "Purchase", "Lease-Purchase", "Other"]
    let statuses = ["Available", "Under Contract", "Leased", "Sold"]
    
    let budgetOptions = [
        "Under $2,000/mo",
        "$2,000 - $5,000/mo",
        "$5,000 - $10,000/mo",
        "$10,000 - $20,000/mo",
        "$20,000 - $50,000/mo",
        "$50,000+/mo",
        "Custom (enter in notes)"
    ]
    
    let sizeRangeOptions = [
        ("1000-2500", "1,000 - 2,500 SF"),
        ("2500-5000", "2,500 - 5,000 SF"),
        ("5000-10000", "5,000 - 10,000 SF"),
        ("10000-25000", "10,000 - 25,000 SF"),
        ("25000-50000", "25,000 - 50,000 SF"),
        ("50000+", "50,000+ SF")
    ]
    
    let industryOptions = [
        "Automotive & Transportation",
        "Construction & Contracting",
        "Distribution & Logistics",
        "E-commerce & Fulfillment",
        "Food & Beverage Production",
        "Healthcare & Medical",
        "Manufacturing",
        "Professional Services",
        "Retail Operations",
        "Technology & Software",
        "Warehousing & Storage",
        "Wholesale Trade",
        "Other"
    ]
    
    let leaseTermOptions = [
        "Month-to-Month",
        "3-6 Months",
        "1 Year",
        "2 Years",
        "3 Years",
        "5 Years",
        "7-10 Years",
        "10+ Years",
        "Flexible/TBD"
    ]
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    // Title - Required
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 8) {
                            Image(systemName: "building.2.fill")
                                .foregroundColor(.primaryBlue)
                                .font(.system(size: 18))
                                .frame(width: 24)
                            TextField("Property Title", text: $title)
                                .font(.body)
                            Text("*")
                                .foregroundColor(.errorRed)
                                .font(.title.bold())
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(UIColor.secondarySystemBackground))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(
                                            title.isEmpty ? Color.errorRed.opacity(0.3) : Color.primaryBlue.opacity(0.2),
                                            lineWidth: 1
                                        )
                                )
                                .shadow(color: Color.black.opacity(0.03), radius: 2, x: 0, y: 1)
                        )
                    }
                    
                    // Address
                    HStack(spacing: 8) {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundColor(.primaryBlue)
                            .font(.system(size: 18))
                            .frame(width: 24)
                        TextField("Address", text: $address)
                            .font(.body)
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(UIColor.secondarySystemBackground))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                            .shadow(color: Color.black.opacity(0.03), radius: 2, x: 0, y: 1)
                    )
                    
                    // City, State, Zip (compact row)
                    HStack(spacing: 8) {
                        TextField("City", text: $city)
                            .font(.body)
                        TextField("State", text: $state)
                            .font(.body)
                            .frame(maxWidth: 60)
                        TextField("Zip", text: $zipCode)
                            .font(.body)
                            .frame(maxWidth: 80)
                            .keyboardType(.numberPad)
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(UIColor.secondarySystemBackground))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                            .shadow(color: Color.black.opacity(0.03), radius: 2, x: 0, y: 1)
                    )
                } header: {
                    Label("PROPERTY LOCATION", systemImage: "location.fill")
                        .font(.system(size: 13, weight: .heavy))
                        .foregroundColor(.primaryBlue)
                        .textCase(.uppercase)
                        .tracking(1.0)
                }
                
                Section {
                    // Property Type
                    Picker("Property Type", selection: $propertyType) {
                        Text("Select property type").tag("").foregroundColor(.secondary)
                        ForEach(propertyTypes, id: \.self) { type in
                            Text(type).tag(type)
                        }
                    }
                    .tint(.primaryBlue)
                    
                    // Transaction Type
                    Picker("Transaction Type", selection: $transactionType) {
                        ForEach(transactionTypes, id: \.self) { type in
                            Text(type).tag(type)
                        }
                    }
                    .tint(.primaryBlue)
                    
                    // Size Range
                    Picker("Size Range (SF)", selection: $sizeRange) {
                        Text("Select size...").tag("")
                        ForEach(sizeRangeOptions, id: \.0) { value, label in
                            Text(label).tag(value)
                        }
                    }
                    .tint(.primaryBlue)
                    .onChange(of: sizeRange) { newValue in
                        if newValue.contains("-") {
                            let parts = newValue.split(separator: "-")
                            sizeMin = String(parts[0])
                            sizeMax = String(parts[1])
                        } else if newValue.contains("+") {
                            sizeMin = newValue.replacingOccurrences(of: "+", with: "")
                            sizeMax = ""
                        }
                    }
                    
                    // Price/Budget
                    Picker("Price Range", selection: $budget) {
                        Text("Select price range...").tag("")
                        ForEach(budgetOptions, id: \.self) { option in
                            Text(option).tag(option)
                        }
                    }
                    .tint(.primaryBlue)
                    
                    // Lease Term
                    Picker("Lease Term", selection: $leaseTerm) {
                        Text("Select term...").tag("")
                        ForEach(leaseTermOptions, id: \.self) { option in
                            Text(option).tag(option)
                        }
                    }
                    .tint(.primaryBlue)
                    
                    // Best Suited Industry
                    Picker("Best Suited For", selection: $industry) {
                        Text("Select industry...").tag("")
                        ForEach(industryOptions, id: \.self) { option in
                            Text(option).tag(option)
                        }
                    }
                    .tint(.primaryBlue)
                } header: {
                    Label("PROPERTY DETAILS", systemImage: "building.2.fill")
                        .font(.system(size: 13, weight: .heavy))
                        .foregroundColor(.primaryBlue)
                        .textCase(.uppercase)
                        .tracking(1.0)
                }
                
                Section {
                    // Photos picker
                    PhotosPicker(selection: $selectedPhotos, maxSelectionCount: 6, matching: .images) {
                        HStack {
                            Image(systemName: "photo.on.rectangle.angled")
                                .foregroundColor(.primaryBlue)
                            Text("Add Photos")
                                .foregroundColor(.primaryBlue)
                            Spacer()
                            if !images.isEmpty {
                                Text("\(images.count) photos")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    // Description
                    TextEditor(text: $description)
                        .frame(minHeight: 100)
                        .overlay(
                            Group {
                                if description.isEmpty {
                                    Text("Property description, key highlights, recent improvements...")
                                        .foregroundColor(.gray.opacity(0.5))
                                        .padding(.top, 8)
                                        .padding(.leading, 4)
                                        .allowsHitTesting(false)
                                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                                }
                            }
                        )
                    
                    // Features
                    TextEditor(text: $features)
                        .frame(minHeight: 80)
                        .overlay(
                            Group {
                                if features.isEmpty {
                                    Text("Key features: Loading docks, office space, parking, etc.")
                                        .foregroundColor(.gray.opacity(0.5))
                                        .padding(.top, 8)
                                        .padding(.leading, 4)
                                        .allowsHitTesting(false)
                                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                                }
                            }
                        )
                } header: {
                    Label("DESCRIPTION & MEDIA", systemImage: "text.alignleft")
                        .font(.system(size: 13, weight: .heavy))
                        .foregroundColor(.primaryBlue)
                        .textCase(.uppercase)
                        .tracking(1.0)
                }
                
                Section {
                    Picker("Status", selection: $status) {
                        ForEach(statuses, id: \.self) { status in
                            Text(status).tag(status)
                        }
                    }
                    .tint(.primaryBlue)
                } header: {
                    Label("AVAILABILITY", systemImage: "calendar.circle.fill")
                        .font(.system(size: 13, weight: .heavy))
                        .foregroundColor(.primaryBlue)
                        .textCase(.uppercase)
                        .tracking(1.0)
                }
                
                // Submit button
                Section {
                    Button {
                        Task {
                            await submitProperty()
                        }
                    } label: {
                        HStack {
                            if isSubmitting {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                Text("Adding Property...")
                            } else {
                                Image(systemName: "plus.circle.fill")
                                Text("Add Property")
                            }
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(
                                    LinearGradient(
                                        colors: [Color.primaryBlue, Color.primaryBlue.opacity(0.8)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .shadow(color: Color.primaryBlue.opacity(0.3), radius: 8, x: 0, y: 4)
                        )
                    }
                    .disabled(title.isEmpty || isSubmitting)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())
                    .padding(.horizontal)
                    .padding(.top, 8)
                }
            }
            .navigationTitle("Add Property")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.primaryBlue)
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func submitProperty() async {
        guard !title.isEmpty else { return }
        
        isSubmitting = true
        
        let payload = PropertyCreatePayload(
            title: title,
            address: address.isEmpty ? nil : address,
            city: city.isEmpty ? nil : city,
            state: state.isEmpty ? nil : state,
            zipCode: zipCode.isEmpty ? nil : zipCode,
            propertyType: propertyType.isEmpty ? nil : propertyType,
            transactionType: transactionType.isEmpty ? nil : transactionType,
            size: nil,
            sizeMin: sizeMin.isEmpty ? nil : sizeMin,
            sizeMax: sizeMax.isEmpty ? nil : sizeMax,
            price: price.isEmpty ? nil : price,
            budget: budget.isEmpty ? nil : budget,
            leaseTerm: leaseTerm.isEmpty ? nil : leaseTerm,
            industry: industry.isEmpty ? nil : industry,
            availableDate: availableDate.isEmpty ? nil : availableDate,
            images: images.isEmpty ? nil : images,
            primaryImage: images.first,
            description: description.isEmpty ? nil : description,
            features: features.isEmpty ? nil : features,
            status: status
        )
        
        do {
            try await viewModel.addProperty(payload)
            
            // Success haptic
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                dismiss()
            }
        } catch {
            print("❌ Failed to add property:", error)
            errorMessage = error.localizedDescription
            showError = true
            
            // Error haptic
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
        }
        
        isSubmitting = false
    }
}

