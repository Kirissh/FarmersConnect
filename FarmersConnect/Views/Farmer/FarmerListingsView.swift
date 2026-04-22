import SwiftUI

struct FarmerListingsView: View {
    @EnvironmentObject var vm: AppViewModel
    @State private var showAddProduct = false
    @State private var editingCrop: Crop? = nil
    @State private var filter: CropStatus? = nil
    
    var displayedCrops: [Crop] {
        let base = vm.farmerCrops.isEmpty ? vm.availableCrops : vm.farmerCrops
        if let f = filter { return base.filter { $0.status == f } }
        return base
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Filter chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        FilterChip(label: "All", isSelected: filter == nil) { filter = nil }
                        FilterChip(label: "Active", isSelected: filter == .active) { filter = .active }
                        FilterChip(label: "Sold Out", isSelected: filter == .soldOut) { filter = .soldOut }
                        FilterChip(label: "Draft", isSelected: filter == .draft) { filter = .draft }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                }
                .background(Color.white)
                
                if displayedCrops.isEmpty {
                    EmptyStateView(
                        icon: "list.bullet.rectangle",
                        title: "No Listings Yet",
                        subtitle: "Tap the + button to list your first produce."
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(displayedCrops) { crop in
                                ListingCard(crop: crop, onEdit: { editingCrop = crop }, onDelete: {
                                    withAnimation { vm.deleteCrop(crop) }
                                }, onToggleStatus: {
                                    var updated = crop
                                    updated.status = crop.status == .active ? .soldOut : .active
                                    vm.updateCrop(updated)
                                })
                            }
                        }
                        .padding()
                    }
                }
            }
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("My Listings")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAddProduct = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(Theme.primary)
                    }
                }
            }
            .sheet(isPresented: $showAddProduct) { AddProductView() }
            .sheet(item: $editingCrop) { crop in EditCropView(crop: crop) }
        }
    }
}

struct FilterChip: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.subheadline)
                .fontWeight(isSelected ? .bold : .regular)
                .foregroundColor(isSelected ? .white : Theme.textDark)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Theme.primary : Color(.systemGray5))
                .cornerRadius(20)
        }
    }
}

struct ListingCard: View {
    let crop: Crop
    let onEdit: () -> Void
    let onDelete: () -> Void
    let onToggleStatus: () -> Void
    @State private var showDeleteAlert = false
    
    var statusColor: Color {
        switch crop.status {
        case .active: return .green
        case .soldOut: return .red
        case .draft: return .orange
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.green.opacity(0.1))
                        .frame(width: 64, height: 64)
                    Image(systemName: crop.imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 34, height: 34)
                        .foregroundColor(Theme.primary)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(crop.name)
                            .font(.headline)
                        Spacer()
                        Text(crop.status.rawValue)
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(statusColor)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(statusColor.opacity(0.12))
                            .cornerRadius(8)
                    }
                    
                    Text("\(crop.quantityAvailable) kg available  ·  \(crop.category)")
                        .font(.caption)
                        .foregroundColor(Theme.textLight)
                    
                    Text("₹\(crop.pricePerKg, specifier: "%.0f")/kg")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(Theme.primary)
                }
            }
            .padding()
            
            Divider().padding(.horizontal)
            
            HStack(spacing: 0) {
                ListingActionBtn(icon: "pencil", label: "Edit", color: .blue, action: onEdit)
                Divider().frame(height: 36)
                ListingActionBtn(icon: crop.status == .active ? "xmark.circle" : "checkmark.circle", label: crop.status == .active ? "Mark Sold" : "Mark Active", color: crop.status == .active ? .orange : .green, action: onToggleStatus)
                Divider().frame(height: 36)
                ListingActionBtn(icon: "trash", label: "Delete", color: .red, action: { showDeleteAlert = true })
            }
        }
        .background(Color.white)
        .cornerRadius(Theme.cornerRadius)
        .shadow(color: Color.black.opacity(0.05), radius: 8, y: 4)
        .alert("Delete Listing?", isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive, action: onDelete)
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will permanently remove \(crop.name) from your listings.")
        }
    }
}

struct ListingActionBtn: View {
    let icon: String
    let label: String
    let color: Color
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: icon).font(.caption)
                Text(label).font(.caption).fontWeight(.semibold)
            }
            .foregroundColor(color)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
        }
    }
}
