import SwiftUI

struct EditPropertyView: View {
    let property: Property
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var viewModel: PropertyViewModel
    
    @State private var title: String
    @State private var address: String
    @State private var city: String
    @State private var state: String
    @State private var zipCode: String
    @State private var propertyType: String
    @State private var transactionType: String
    @State private var sizeRange: String
    @State private var sizeMin: String
    @State private var sizeMax: String
    @State private var budget: String
    @State private var leaseTerm: String
    @State private var industry: String
    @State private var description: String
    @State private var features: String
    @State private var status: String
    @State private var isSubmitting = false
    
    // Same options as AddPropertyView
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
        "Custom"
    ]
    
    let sizeRangeOptions = [
        ("0-1000", "Less than 1,000 SF"),
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
    
    init(property: Property) {
        self.property = property
        _title = State(initialValue: property.title)
        _address = State(initialValue: property.address ?? "")
        _city = State(initialValue: property.city ?? "")
        _state = State(initialValue: property.state ?? "")
        _zipCode = State(initialValue: property.zipCode ?? "")
        _propertyType = State(initialValue: property.propertyType ?? "")
        _transactionType = State(initialValue: property.transactionType ?? "Lease")
        _sizeMin = State(initialValue: property.sizeMin ?? "")
        _sizeMax = State(initialValue: property.sizeMax ?? "")
        _budget = State(initialValue: property.budget ?? "")
        _leaseTerm = State(initialValue: property.leaseTerm ?? "")
        _industry = State(initialValue: property.industry ?? "")
        _description = State(initialValue: property.description ?? "")
        _features = State(initialValue: property.features ?? "")
        _status = State(initialValue: property.status)
        
        // Initialize size range from existing values
        let sizeMinVal = property.sizeMin ?? ""
        let sizeMaxVal = property.sizeMax ?? ""
        if !sizeMinVal.isEmpty && !sizeMaxVal.isEmpty {
            _sizeRange = State(initialValue: "\(sizeMinVal)-\(sizeMaxVal)")
        } else if !sizeMinVal.isEmpty {
            _sizeRange = State(initialValue: "\(sizeMinVal)+")
        } else {
            _sizeRange = State(initialValue: "")
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("PROPERTY INFORMATION") {
                    TextField("Property Title *", text: $title)
                    TextField("Address", text: $address)
                    TextField("City", text: $city)
                    TextField("State", text: $state)
                    TextField("Zip Code", text: $zipCode)
                        .keyboardType(.numberPad)
                }
                
                Section("PROPERTY DETAILS") {
                    Picker("Property Type", selection: $propertyType) {
                        Text("Select Type").tag("")
                        ForEach(propertyTypes, id: \.self) { type in
                            Text(type).tag(type)
                        }
                    }
                    
                    Picker("Transaction Type", selection: $transactionType) {
                        ForEach(transactionTypes, id: \.self) { type in
                            Text(type).tag(type)
                        }
                    }
                    
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
                    
                    Picker("Price Range", selection: $budget) {
                        Text("Select price...").tag("")
                        ForEach(budgetOptions, id: \.self) { option in
                            Text(option).tag(option)
                        }
                    }
                    
                    Picker("Lease Term", selection: $leaseTerm) {
                        Text("Select term...").tag("")
                        ForEach(leaseTermOptions, id: \.self) { option in
                            Text(option).tag(option)
                        }
                    }
                    
                    Picker("Best Suited For", selection: $industry) {
                        Text("Select industry...").tag("")
                        ForEach(industryOptions, id: \.self) { option in
                            Text(option).tag(option)
                        }
                    }
                }
                
                Section("DESCRIPTION") {
                    TextEditor(text: $description)
                        .frame(minHeight: 100)
                    
                    TextEditor(text: $features)
                        .frame(minHeight: 80)
                }
                
                Section("STATUS") {
                    Picker("Status", selection: $status) {
                        ForEach(statuses, id: \.self) { status in
                            Text(status).tag(status)
                        }
                    }
                }
            }
            .navigationTitle("Edit Property")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.primaryBlue)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        Task {
                            await saveProperty()
                        }
                    }
                    .foregroundColor(.primaryBlue)
                    .fontWeight(.semibold)
                    .disabled(title.isEmpty || isSubmitting)
                }
            }
        }
    }
    
    private func saveProperty() async {
        guard !title.isEmpty else { return }
        
        isSubmitting = true
        
        var updates = PropertyUpdatePayload()
        updates.title = title
        updates.address = address.isEmpty ? nil : address
        updates.city = city.isEmpty ? nil : city
        updates.state = state.isEmpty ? nil : state
        updates.zipCode = zipCode.isEmpty ? nil : zipCode
        updates.propertyType = propertyType.isEmpty ? nil : propertyType
        updates.transactionType = transactionType
        updates.sizeMin = sizeMin.isEmpty ? nil : sizeMin
        updates.sizeMax = sizeMax.isEmpty ? nil : sizeMax
        updates.budget = budget.isEmpty ? nil : budget
        updates.leaseTerm = leaseTerm.isEmpty ? nil : leaseTerm
        updates.industry = industry.isEmpty ? nil : industry
        updates.description = description.isEmpty ? nil : description
        updates.features = features.isEmpty ? nil : features
        updates.status = status
        
        do {
            try await viewModel.updateProperty(id: property.id, updates: updates)
            
            // Success haptic
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            
            withAnimation(.easeOut(duration: 0.3)) {
                dismiss()
            }
        } catch {
            print("❌ Failed to update property:", error)
            
            // Error haptic
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
        }
        
        isSubmitting = false
    }
}

