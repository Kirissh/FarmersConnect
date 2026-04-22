import SwiftUI

struct CustomerHomeView: View {
    @EnvironmentObject var vm: AppViewModel
    @State private var searchText = ""
    @State private var selectedCategory: String? = nil
    
    let categories = ["All", "Vegetables", "Grains", "Spices", "Fruits", "Pulses"]
    
    var filteredCrops: [Crop] {
        var crops = vm.availableCrops
        if !searchText.isEmpty {
            crops = crops.filter { $0.name.localizedCaseInsensitiveContains(searchText) || $0.farmerName.localizedCaseInsensitiveContains(searchText) }
        }
        if let cat = selectedCategory, cat != "All" {
            crops = crops.filter { $0.category == cat }
        }
        return crops
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Good \(greeting)!")
                                .font(.caption)
                                .foregroundColor(Theme.textLight)
                            Text(vm.currentUser?.name ?? "Customer")
                                .font(.headline)
                                .fontWeight(.bold)
                        }
                        Spacer()
                        NavigationLink(destination: NotificationsView()) {
                            ZStack(alignment: .topTrailing) {
                                Image(systemName: "bell.fill")
                                    .font(.title2)
                                    .foregroundColor(Theme.textDark)
                                if vm.unreadCount > 0 {
                                    Circle().fill(Color.red)
                                        .frame(width: 10, height: 10)
                                        .offset(x: 2, y: -2)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .padding(.bottom, 16)
                    
                    // AI Market Insight
                    if let firstPred = vm.livePredictions.first {
                        HStack(spacing: 12) {
                            Image(systemName: "sparkles")
                                .font(.title2)
                                .foregroundColor(.purple)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("AI Market Insight")
                                    .font(.caption.bold())
                                    .foregroundColor(.purple)
                                Text(firstPred.text)
                                    .font(.system(size: 13))
                                    .foregroundColor(Theme.textDark)
                                    .lineLimit(2)
                            }
                            Spacer()
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: Theme.cornerRadius)
                                .fill(LinearGradient(gradient: Gradient(colors: [Color.purple.opacity(0.1), Color.blue.opacity(0.05)]), startPoint: .topLeading, endPoint: .bottomTrailing))
                        )
                        .padding(.horizontal)
                        .padding(.bottom, 16)
                    }
                    
                    // Search bar
                    HStack {
                        Image(systemName: "magnifyingglass").foregroundColor(.gray)
                        TextField("Search crops, farmers...", text: $searchText)
                        if !searchText.isEmpty {
                            Button(action: { searchText = "" }) {
                                Image(systemName: "xmark.circle.fill").foregroundColor(.gray)
                            }
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(Theme.cornerRadius)
                    .shadow(color: Color.black.opacity(0.04), radius: 8, y: 3)
                    .padding(.horizontal)
                    
                    // Quick Actions
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 14) {
                            NavigationLink(destination: CustomerCropsView()) {
                                CustomerActionCard(title: "Browse Crops", icon: "leaf.fill", color: Theme.primary)
                            }.buttonStyle(PlainButtonStyle())
                            
                            NavigationLink(destination: NearbyFarmersView()) {
                                CustomerActionCard(title: "Nearby\nFarmers", icon: "person.2.fill", color: Theme.accent)
                            }.buttonStyle(PlainButtonStyle())
                            
                            NavigationLink(destination: MarketPricesView()) {
                                CustomerActionCard(title: "Market\nPrices", icon: "chart.bar.fill", color: .blue)
                            }.buttonStyle(PlainButtonStyle())
                            
                            NavigationLink(destination: MessagesView()) {
                                CustomerActionCard(title: "Messages", icon: "message.fill", color: .purple)
                            }.buttonStyle(PlainButtonStyle())
                            
                            NavigationLink(destination: CustomerOrdersView()) {
                                CustomerActionCard(title: "My Orders", icon: "bag.fill", color: .orange)
                            }.buttonStyle(PlainButtonStyle())
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 16)
                    }
                    
                    // Category filter
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(categories, id: \.self) { cat in
                                FilterChip(label: cat, isSelected: (selectedCategory ?? "All") == cat) {
                                    selectedCategory = cat == "All" ? nil : cat
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 8)
                    }
                    
                    // Crops list
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text(searchText.isEmpty && selectedCategory == nil ? "Fresh Arrivals" : "Results (\(filteredCrops.count))")
                                .font(.headline)
                            Spacer()
                            NavigationLink("See All", destination: CustomerCropsView())
                                .font(.subheadline)
                                .foregroundColor(Theme.primary)
                        }
                        .padding(.horizontal)
                        
                        if filteredCrops.isEmpty {
                            EmptyStateView(icon: "leaf", title: "No Results", subtitle: "Try a different search or category.")
                                .frame(height: 200)
                        } else {
                            LazyVStack(spacing: 14) {
                                ForEach(filteredCrops) { crop in
                                    NavigationLink(destination: CustomerProductDetailView(crop: crop)) {
                                        CustomerCropCard(crop: crop)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.bottom, 24)
                }
            }
            .background(Theme.background.ignoresSafeArea())
            .navigationBarHidden(true)
        }
    }
    
    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 { return "Morning" }
        if hour < 17 { return "Afternoon" }
        return "Evening"
    }
}

struct CustomerActionCard: View {
    let title: String
    let icon: String
    let color: Color
    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle().fill(color.opacity(0.12)).frame(width: 52, height: 52)
                Image(systemName: icon).font(.title2).foregroundColor(color)
            }
            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(Theme.textDark)
                .multilineTextAlignment(.center)
        }
        .frame(width: 90, height: 100)
        .background(Color.white)
        .cornerRadius(Theme.cornerRadius)
        .shadow(color: Color.black.opacity(0.05), radius: 6, y: 3)
    }
}

struct CustomerCropCard: View {
    @EnvironmentObject var vm: AppViewModel
    let crop: Crop
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.green.opacity(0.1))
                    .frame(width: 75, height: 75)
                Image(systemName: crop.imageName)
                    .resizable().scaledToFit()
                    .frame(width: 38, height: 38)
                    .foregroundColor(Theme.primary)
            }
            VStack(alignment: .leading, spacing: 5) {
                Text(crop.name).font(.headline)
                HStack {
                    Image(systemName: "person.fill").font(.caption2).foregroundColor(.gray)
                    Text(crop.farmerName).font(.caption).foregroundColor(.gray)
                    Text("·").foregroundColor(.gray)
                    Image(systemName: "mappin.fill").font(.caption2).foregroundColor(.gray)
                    Text(crop.location).font(.caption).foregroundColor(.gray).lineLimit(1)
                }
                HStack {
                    Text("₹\(crop.pricePerKg, specifier: "%.0f")/kg")
                        .font(.headline).foregroundColor(Theme.primary)
                    Spacer()
                    Text("Min \(crop.minOrderKg) kg")
                        .font(.caption2)
                        .foregroundColor(Theme.textLight)
                        .padding(.horizontal, 8).padding(.vertical, 4)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(6)
                }
            }
            .padding(.vertical, 8)
            
            // Wishlish heart
            Button(action: { vm.toggleSaved(cropId: crop.id) }) {
                Image(systemName: vm.isSaved(crop.id) ? "heart.fill" : "heart")
                    .foregroundColor(vm.isSaved(crop.id) ? .red : .gray.opacity(0.4))
                    .font(.title3)
            }
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(Theme.cornerRadius)
        .shadow(color: Color.black.opacity(0.05), radius: 8, y: 4)
    }
}
