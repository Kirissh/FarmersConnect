import SwiftUI

struct CustomerProductDetailView: View {
    @EnvironmentObject var vm: AppViewModel
    let crop: Crop
    @State private var quantity = 5
    @State private var showOrderSheet = false
    @State private var showPriceAlert = false
    @State private var orderPlaced = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Hero
                ZStack {
                    LinearGradient(colors: [Color.green.opacity(0.15), Color.green.opacity(0.05)],
                                   startPoint: .top, endPoint: .bottom)
                    Image(systemName: crop.imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 140, height: 140)
                        .foregroundColor(Theme.primary)
                }
                .frame(height: 260)
                .cornerRadius(30)
                .ignoresSafeArea(edges: .top)
                
                VStack(alignment: .leading, spacing: 20) {
                    // Title row
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(crop.name)
                                .font(.largeTitle).fontWeight(.bold)
                            Text(crop.category)
                                .font(.caption)
                                .foregroundColor(.white)
                                .padding(.horizontal, 10).padding(.vertical, 4)
                                .background(Theme.primary.opacity(0.8)).cornerRadius(8)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("₹\(crop.pricePerKg, specifier: "%.0f")")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(Theme.primary)
                            Text("per kg")
                                .font(.caption)
                                .foregroundColor(Theme.textLight)
                        }
                    }
                    
                    // Stock
                    HStack(spacing: 16) {
                        Label("\(crop.quantityAvailable) kg in stock", systemImage: "shippingbox.fill")
                            .font(.subheadline).foregroundColor(Theme.textLight)
                        Spacer()
                        Label("Min \(crop.minOrderKg) kg order", systemImage: "cart.fill")
                            .font(.subheadline).foregroundColor(Theme.textLight)
                    }
                    
                    Divider()
                    
                    // Farmer Card
                    HStack(spacing: 14) {
                        ZStack {
                            Circle().fill(Color.gray.opacity(0.15)).frame(width: 52, height: 52)
                            Image(systemName: "person.fill").foregroundColor(.gray).font(.title2)
                        }
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Farmer").font(.caption).foregroundColor(Theme.textLight)
                            Text(crop.farmerName).font(.headline)
                            HStack {
                                Image(systemName: "mappin.fill").font(.caption2).foregroundColor(.red)
                                Text(crop.location).font(.caption).foregroundColor(Theme.textLight)
                            }
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 4) {
                            HStack(spacing: 2) {
                                Image(systemName: "star.fill").foregroundColor(.yellow).font(.caption)
                                Text("4.8").fontWeight(.bold)
                            }
                            Text("Verified").font(.caption2).foregroundColor(.green)
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(Theme.cornerRadius)
                    .shadow(color: Color.black.opacity(0.05), radius: 6, y: 3)
                    
                    // Description
                    Text("Description")
                        .font(.headline)
                    Text(crop.description)
                        .foregroundColor(Theme.textLight)
                        .lineSpacing(6)
                    
                    Divider()
                    
                    // Quantity Picker
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Select Quantity").font(.headline)
                        HStack {
                            Button(action: { if quantity > crop.minOrderKg { quantity -= 1 } }) {
                                Image(systemName: "minus.circle.fill")
                                    .font(.title2).foregroundColor(Theme.primary)
                            }
                            Text("\(quantity) kg")
                                .font(.title3).fontWeight(.bold)
                                .frame(minWidth: 80)
                                .multilineTextAlignment(.center)
                            Button(action: { if quantity < crop.quantityAvailable { quantity += 1 } }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2).foregroundColor(Theme.primary)
                            }
                            Spacer()
                            Text("₹\(Double(quantity) * crop.pricePerKg, specifier: "%.0f")")
                                .font(.title2).fontWeight(.bold).foregroundColor(Theme.primary)
                        }
                    }
                    
                    // Action buttons
                    HStack(spacing: 12) {
                        NavigationLink(destination: ChatView(thread: vm.findOrCreateThread(with: crop.farmerName, role: .farmer, cropId: crop.id))) {
                            HStack {
                                Image(systemName: "message.fill")
                                Text("Message")
                            }
                            .font(.headline)
                            .foregroundColor(Theme.primary)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(Theme.cornerRadius)
                            .overlay(RoundedRectangle(cornerRadius: Theme.cornerRadius).stroke(Theme.primary, lineWidth: 2))
                        }
                        
                        Button(action: { showOrderSheet = true }) {
                            HStack {
                                Image(systemName: "bag.fill")
                                Text("Buy Now")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Theme.accent)
                            .cornerRadius(Theme.cornerRadius)
                        }
                    }
                    
                    // Price Alert button
                    Button(action: { showPriceAlert = true }) {
                        HStack {
                            Image(systemName: "bell.badge.fill")
                            Text("Set Price Alert")
                        }
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(Theme.primary)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Theme.primary.opacity(0.08))
                        .cornerRadius(Theme.cornerRadius)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 20)
                .offset(y: -20)
            }
        }
        .background(Theme.background.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { vm.toggleSaved(cropId: crop.id) }) {
                    Image(systemName: vm.isSaved(crop.id) ? "heart.fill" : "heart")
                        .foregroundColor(vm.isSaved(crop.id) ? .red : .primary)
                }
            }
        }
        .sheet(isPresented: $showOrderSheet) {
            PlaceOrderSheet(crop: crop, quantity: $quantity, onConfirm: { deliveryAddress in
                vm.placeOrder(crop: crop, quantity: quantity, address: deliveryAddress)
                orderPlaced = true
                showOrderSheet = false
            })
        }
        .sheet(isPresented: $showPriceAlert) {
            SetPriceAlertSheet(cropName: crop.name, currentPrice: crop.pricePerKg)
        }
        .overlay {
            if orderPlaced {
                SuccessOverlay(message: "Order placed for \(quantity) kg of \(crop.name)!") {
                    orderPlaced = false
                }
            }
        }
    }
}

// MARK: - Place Order Sheet

struct PlaceOrderSheet: View {
    @EnvironmentObject var vm: AppViewModel
    @Environment(\.dismiss) var dismiss
    let crop: Crop
    @Binding var quantity: Int
    let onConfirm: (String) -> Void
    @State private var address = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("Order Summary") {
                    HStack {
                        Text("Crop"); Spacer(); Text(crop.name).foregroundColor(Theme.textLight)
                    }
                    HStack {
                        Text("Quantity"); Spacer()
                        Stepper("\(quantity) kg", value: $quantity, in: crop.minOrderKg...crop.quantityAvailable)
                    }
                    HStack {
                        Text("Price/kg"); Spacer(); Text("₹\(crop.pricePerKg, specifier: "%.0f")").foregroundColor(Theme.textLight)
                    }
                    HStack {
                        Text("Total").fontWeight(.bold)
                        Spacer()
                        Text("₹\(Double(quantity) * crop.pricePerKg, specifier: "%.0f")").fontWeight(.bold).foregroundColor(Theme.primary)
                    }
                }
                Section("Delivery Address") {
                    TextField("Enter your delivery address", text: $address, axis: .vertical)
                        .lineLimit(3...4)
                }
                Section {
                    Button(action: { onConfirm(address) }) {
                        Text("Confirm Order")
                            .font(.headline).foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Theme.accent)
                            .cornerRadius(Theme.cornerRadius)
                    }
                    .disabled(address.isEmpty)
                }
            }
            .navigationTitle("Place Order")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) { Button("Cancel") { dismiss() } }
            }
        }
    }
}

// MARK: - Set Price Alert Sheet

struct SetPriceAlertSheet: View {
    @EnvironmentObject var vm: AppViewModel
    @Environment(\.dismiss) var dismiss
    let cropName: String
    let currentPrice: Double
    @State private var targetPrice: String = ""
    @State private var condition: AlertCondition = .below
    
    var body: some View {
        NavigationView {
            Form {
                Section("Crop") {
                    Text(cropName)
                    Text("Current Price: ₹\(currentPrice, specifier: "%.0f")/kg").foregroundColor(Theme.textLight)
                }
                Section("Alert Condition") {
                    Picker("When price is", selection: $condition) {
                        Text("Falls Below").tag(AlertCondition.below)
                        Text("Rises Above").tag(AlertCondition.above)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    TextField("Target price (₹/kg)", text: $targetPrice)
                        .keyboardType(.decimalPad)
                }
                Section {
                    Button(action: {
                        if let price = Double(targetPrice) {
                            vm.addPriceAlert(cropName: cropName, targetPrice: price, condition: condition)
                            dismiss()
                        }
                    }) {
                        Text("Set Alert")
                            .font(.headline).foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Theme.primary)
                            .cornerRadius(Theme.cornerRadius)
                    }
                    .disabled(targetPrice.isEmpty)
                }
            }
            .navigationTitle("Price Alert")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) { Button("Cancel") { dismiss() } }
            }
        }
    }
}
