import SwiftUI

struct AddProductView: View {
    @EnvironmentObject var vm: AppViewModel
    @Environment(\.dismiss) var dismiss
    @State private var step = 1
    
    // Step 1 - Crop type
    @State private var selectedCrop = ""
    // Step 2 - Details
    @State private var price = ""
    @State private var quantity = ""
    @State private var description = ""
    @State private var minOrder = ""
    @State private var category = "Vegetables"
    // Step 3 - Location
    @State private var city = ""
    @State private var market = ""
    @State private var pincode = ""
    @State private var showSuccess = false
    
    let crops = ["Tomato", "Onion", "Rice", "Wheat", "Chilli", "Potato", "Corn", "Sugarcane", "Soybean", "Other"]
    let categories = ["Vegetables", "Grains", "Spices", "Fruits", "Pulses", "Other"]
    
    var canProceedStep1: Bool { !selectedCrop.isEmpty }
    var canProceedStep2: Bool { !price.isEmpty && !quantity.isEmpty }
    var canProceedStep3: Bool { !city.isEmpty }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Progress bar
                VStack(spacing: 8) {
                    HStack(spacing: 0) {
                        ForEach(1...3, id: \.self) { s in
                            Rectangle()
                                .fill(step >= s ? Theme.primary : Color(.systemGray4))
                                .frame(height: 3)
                                .animation(.easeInOut, value: step)
                        }
                    }
                    .cornerRadius(2)
                    .padding(.horizontal)
                    
                    HStack {
                        ForEach(zip(1...3, ["Crop", "Details", "Location"]).map { $0 }, id: \.0) { num, title in
                            VStack(spacing: 4) {
                                ZStack {
                                    Circle()
                                        .fill(step >= num ? Theme.primary : Color(.systemGray4))
                                        .frame(width: 28, height: 28)
                                    if step > num {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.white)
                                            .font(.caption2)
                                    } else {
                                        Text("\(num)")
                                            .foregroundColor(step >= num ? .white : .gray)
                                            .font(.caption)
                                            .fontWeight(.bold)
                                    }
                                }
                                Text(title)
                                    .font(.caption2)
                                    .foregroundColor(step >= num ? Theme.primary : .gray)
                            }
                            if num < 3 { Spacer() }
                        }
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.vertical, 12)
                .background(Color.white)
                
                ScrollView {
                    VStack(spacing: 20) {
                        if step == 1 {
                            cropSelectionStep
                        } else if step == 2 {
                            detailsStep
                        } else {
                            locationStep
                        }
                    }
                    .padding()
                }
                
                // Bottom navigation
                HStack(spacing: 12) {
                    if step > 1 {
                        Button(action: { withAnimation { step -= 1 } }) {
                            Text("Back")
                                .font(.headline)
                                .foregroundColor(Theme.primary)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Theme.primary.opacity(0.1))
                                .cornerRadius(Theme.cornerRadius)
                        }
                    }
                    
                    Button(action: handleNext) {
                        Text(step == 3 ? "List Product" : "Next")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Theme.primary)
                            .cornerRadius(Theme.cornerRadius)
                            .opacity(stepValid ? 1.0 : 0.5)
                    }
                    .disabled(!stepValid)
                }
                .padding()
                .background(Color.white)
            }
            .background(Theme.background)
            .navigationTitle("List New Product")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
            .overlay {
                if showSuccess {
                    SuccessOverlay(message: "\(selectedCrop) listed successfully!") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    var stepValid: Bool {
        switch step {
        case 1: return canProceedStep1
        case 2: return canProceedStep2
        case 3: return canProceedStep3
        default: return true
        }
    }
    
    func handleNext() {
        if step < 3 {
            withAnimation { step += 1 }
        } else {
            vm.addCrop(
                name: selectedCrop,
                price: Double(price) ?? 0,
                quantity: Int(quantity) ?? 0,
                description: description.isEmpty ? "Fresh \(selectedCrop) from \(city)" : description,
                location: market.isEmpty ? city : "\(market), \(city)",
                category: category,
                minOrder: Int(minOrder) ?? 1
            )
            withAnimation { showSuccess = true }
        }
    }
    
    var cropSelectionStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("What are you selling?")
                .font(.title3).fontWeight(.bold)
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                ForEach(crops, id: \.self) { crop in
                    CropSelectionCard(title: crop, isSelected: selectedCrop == crop) {
                        selectedCrop = crop
                    }
                }
            }
        }
    }
    
    var detailsStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Listing Details")
                .font(.title3).fontWeight(.bold)
            
            Group {
                FormField(label: "Price per kg (₹)", placeholder: "e.g. 45", text: $price, keyboard: .decimalPad)
                FormField(label: "Quantity available (kg)", placeholder: "e.g. 200", text: $quantity, keyboard: .numberPad)
                FormField(label: "Minimum order (kg)", placeholder: "e.g. 5", text: $minOrder, keyboard: .numberPad)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Category").font(.subheadline).fontWeight(.semibold).foregroundColor(Theme.textLight)
                Picker("Category", selection: $category) {
                    ForEach(categories, id: \.self) { Text($0).tag($0) }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Description (optional)").font(.subheadline).fontWeight(.semibold).foregroundColor(Theme.textLight)
                TextField("Describe your produce...", text: $description, axis: .vertical)
                    .lineLimit(4...6)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(14)
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.gray.opacity(0.2)))
            }
        }
    }
    
    var locationStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Where are you located?")
                .font(.title3).fontWeight(.bold)
            
            FormField(label: "City / Village *", placeholder: "e.g. Pune", text: $city)
            FormField(label: "Market (APMC / Mandi)", placeholder: "e.g. Pune APMC", text: $market)
            FormField(label: "Pin Code", placeholder: "e.g. 411001", text: $pincode, keyboard: .numberPad)
            
            HStack(spacing: 12) {
                Image(systemName: "location.fill")
                    .foregroundColor(Theme.primary)
                Button("Use My Current Location") {}
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(Theme.primary)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.primary.opacity(0.05))
            .cornerRadius(14)
        }
    }
}

struct FormField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var keyboard: UIKeyboardType = .default
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label).font(.subheadline).fontWeight(.semibold).foregroundColor(Theme.textLight)
            TextField(placeholder, text: $text)
                .keyboardType(keyboard)
                .padding()
                .background(Color.white)
                .cornerRadius(14)
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.gray.opacity(0.2)))
        }
    }
}

struct CropSelectionCard: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: "leaf.fill")
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : Theme.primary)
                Text(title)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(isSelected ? .white : Theme.textDark)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(isSelected ? Theme.primary : Color.white)
            .cornerRadius(Theme.cornerRadius)
            .shadow(color: Color.black.opacity(0.05), radius: 5, y: 2)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cornerRadius)
                    .stroke(isSelected ? Theme.primary : Color.clear, lineWidth: 2)
            )
        }
    }
}

