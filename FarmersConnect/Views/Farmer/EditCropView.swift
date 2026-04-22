import SwiftUI

struct EditCropView: View {
    @EnvironmentObject var vm: AppViewModel
    @Environment(\.dismiss) var dismiss
    var crop: Crop

    @State private var price: String
    @State private var quantity: String
    @State private var description: String
    @State private var location: String
    @State private var minOrder: String

    init(crop: Crop) {
        self.crop = crop
        _price = State(initialValue: String(format: "%.0f", crop.pricePerKg))
        _quantity = State(initialValue: "\(crop.quantityAvailable)")
        _description = State(initialValue: crop.description)
        _location = State(initialValue: crop.location)
        _minOrder = State(initialValue: "\(crop.minOrderKg)")
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    FormField(label: "Price per kg (₹)", placeholder: "Price", text: $price, keyboard: .decimalPad)
                    FormField(label: "Quantity (kg)", placeholder: "qty", text: $quantity, keyboard: .numberPad)
                    FormField(label: "Min Order (kg)", placeholder: "min", text: $minOrder, keyboard: .numberPad)
                    FormField(label: "Location / Market", placeholder: "e.g. Pune APMC", text: $location)
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Description").font(.subheadline).fontWeight(.semibold).foregroundColor(Theme.textLight)
                        TextField("Description", text: $description, axis: .vertical)
                            .lineLimit(4...6)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(14)
                            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.gray.opacity(0.2)))
                    }
                    
                    Button(action: save) {
                        Text("Save Changes")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Theme.primary)
                            .cornerRadius(Theme.cornerRadius)
                    }
                }
                .padding()
            }
            .background(Theme.background)
            .navigationTitle("Edit \(crop.name)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
    
    func save() {
        var updated = crop
        updated.pricePerKg = Double(price) ?? crop.pricePerKg
        updated.quantityAvailable = Int(quantity) ?? crop.quantityAvailable
        updated.description = description
        updated.location = location
        updated.minOrderKg = Int(minOrder) ?? crop.minOrderKg
        vm.updateCrop(updated)
        dismiss()
    }
}
