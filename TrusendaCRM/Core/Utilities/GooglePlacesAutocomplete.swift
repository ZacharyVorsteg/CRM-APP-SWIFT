import SwiftUI
import UIKit
import GooglePlaces

// MARK: - Address Result Model
struct AddressComponents {
    let streetNumber: String
    let route: String
    let fullAddress: String
    let city: String
    let state: String
    let zipCode: String
    
    var isComplete: Bool {
        !fullAddress.isEmpty && !city.isEmpty && !state.isEmpty && !zipCode.isEmpty
    }
}

// MARK: - Google Places Autocomplete Coordinator
class PlacesAutocompleteCoordinator: NSObject, GMSAutocompleteViewControllerDelegate {
    var onAddressSelected: ((AddressComponents) -> Void)?
    var onError: ((String) -> Void)?
    var onCancel: (() -> Void)?
    
    func viewController(didAutocompleteWith place: GMSPlace) {
        extractAddressComponents(from: place)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("❌ Google Places Autocomplete Error: \(error.localizedDescription)")
        onError?("Failed to load address suggestions. Please try again.")
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        onCancel?()
    }
    
    private func extractAddressComponents(from place: GMSPlace) {
        guard let addressComponents = place.addressComponents else {
            onError?("Unable to extract address details. Please try another address.")
            return
        }
        
        var streetNumber = ""
        var route = ""
        var city = ""
        var state = ""
        var zipCode = ""
        
        // Extract individual components
        for component in addressComponents {
            let types = component.types
            
            if types.contains("street_number") {
                streetNumber = component.name
            }
            
            if types.contains("route") {
                route = component.name
            }
            
            if types.contains("locality") {
                city = component.name
            }
            
            if types.contains("administrative_area_level_1") {
                state = component.shortName ?? component.name
            }
            
            if types.contains("postal_code") {
                zipCode = component.name
            }
        }
        
        // Build full street address
        let fullAddress = [streetNumber, route]
            .filter { !$0.isEmpty }
            .joined(separator: " ")
        
        let address = AddressComponents(
            streetNumber: streetNumber,
            route: route,
            fullAddress: fullAddress.isEmpty ? (place.formattedAddress ?? "") : fullAddress,
            city: city,
            state: state,
            zipCode: zipCode
        )
        
        // Validate we have minimum required components
        if address.isComplete {
            onAddressSelected?(address)
        } else {
            var missing: [String] = []
            if address.fullAddress.isEmpty { missing.append("street address") }
            if address.city.isEmpty { missing.append("city") }
            if address.state.isEmpty { missing.append("state") }
            if address.zipCode.isEmpty { missing.append("ZIP code") }
            
            let missingText = missing.joined(separator: ", ")
            onError?("Selected address is missing: \(missingText). Please select a complete address.")
        }
    }
}

// MARK: - SwiftUI Wrapper for Google Places Autocomplete
struct GooglePlacesAutocomplete: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    let onAddressSelected: (AddressComponents) -> Void
    let onError: (String) -> Void
    
    func makeUIViewController(context: Context) -> GMSAutocompleteViewController {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = context.coordinator
        
        // Configure filters for US addresses only
        let filter = GMSAutocompleteFilter()
        filter.types = ["address", "geocode"] // Addresses and places, not businesses
        filter.countries = ["US"] // Restrict to United States
        
        autocompleteController.autocompleteFilter = filter
        
        // Create session token for billing optimization
        autocompleteController.autocompleteBoundsMode = .bias
        
        // Customize appearance to match app theme
        let primaryBlue = UIColor(red: 0, green: 0.44, blue: 0.82, alpha: 1.0)
        autocompleteController.primaryTextColor = .label
        autocompleteController.primaryTextHighlightColor = primaryBlue
        autocompleteController.secondaryTextColor = .secondaryLabel
        autocompleteController.tableCellBackgroundColor = .systemBackground
        autocompleteController.tableCellSeparatorColor = .separator
        
        return autocompleteController
    }
    
    func updateUIViewController(_ uiViewController: GMSAutocompleteViewController, context: Context) {
        // No updates needed
    }
    
    func makeCoordinator() -> PlacesAutocompleteCoordinator {
        let coordinator = PlacesAutocompleteCoordinator()
        
        coordinator.onAddressSelected = { address in
            onAddressSelected(address)
            isPresented = false
        }
        
        coordinator.onError = { error in
            onError(error)
            isPresented = false
        }
        
        coordinator.onCancel = {
            isPresented = false
        }
        
        return coordinator
    }
}

// MARK: - Simple Button View for Triggering Autocomplete
struct PlacesAutocompleteButton: View {
    let currentAddress: String
    let action: () -> Void
    let isRequired: Bool
    let hasValue: Bool
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(hasValue ? .successGreen : (isRequired ? .errorRed : .primaryBlue))
                    .font(.system(size: 18))
                    .frame(width: 24)
                
                Text(currentAddress.isEmpty ? "Search for address..." : currentAddress)
                    .foregroundColor(currentAddress.isEmpty ? .secondary : .primary)
                    .font(.body)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                if isRequired {
                    Text("*")
                        .foregroundColor(.errorRed)
                        .font(.title.bold())
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(UIColor.secondarySystemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(
                                hasValue ? Color.successGreen.opacity(0.4) : 
                                    (isRequired ? Color.errorRed.opacity(0.3) : Color.primaryBlue.opacity(0.2)),
                                lineWidth: hasValue ? 1.5 : 1
                            )
                    )
                    .shadow(color: Color.black.opacity(0.03), radius: 2, x: 0, y: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

