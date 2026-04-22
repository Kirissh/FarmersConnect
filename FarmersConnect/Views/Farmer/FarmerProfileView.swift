import SwiftUI

struct FarmerProfileView: View {
    @EnvironmentObject var vm: AppViewModel
    @State private var showEditProfile = false
    @State private var showPriceAlerts = false
    @State private var showOrdersView = false
    @State private var showLogoutAlert = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // MARK: - Header
                    ZStack(alignment: .bottomLeading) {
                        LinearGradient(
                            colors: [Theme.primary, Theme.primary.opacity(0.75)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                        .frame(height: 200)
                        
                        VStack(alignment: .leading, spacing: 6) {
                            HStack(alignment: .bottom) {
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Text(vm.currentUser?.name ?? "Farmer")
                                            .font(.title2).fontWeight(.bold).foregroundColor(.white)
                                        Image(systemName: "checkmark.seal.fill")
                                            .foregroundColor(Theme.accent)
                                    }
                                    Text(vm.currentUser?.location ?? "Pune, Maharashtra")
                                        .font(.subheadline).foregroundColor(.white.opacity(0.85))
                                    Text("Farmer · Verified Seller")
                                        .font(.caption).foregroundColor(.white.opacity(0.7))
                                }
                                Spacer()
                                Button(action: { showEditProfile = true }) {
                                    Image(systemName: "pencil.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(.white.opacity(0.8))
                                }
                            }
                        }
                        .padding(20)
                    }
                    .cornerRadius(0)
                    
                    // Stats
                    HStack(spacing: 0) {
                        StatBlock(title: "Total Sales", value: "₹45K", icon: "indianrupeesign.circle.fill", color: .green)
                        Divider().frame(height: 50)
                        StatBlock(title: "Products", value: "\(max(vm.farmerCrops.count, vm.availableCrops.count))", icon: "leaf.fill", color: Theme.primary)
                        Divider().frame(height: 50)
                        StatBlock(title: "Orders", value: "\(vm.myOrders.count)", icon: "shippingbox.fill", color: .orange)
                        Divider().frame(height: 50)
                        StatBlock(title: "Rating", value: "4.8★", icon: "star.fill", color: .yellow)
                    }
                    .padding(.vertical, 12)
                    .background(Color.white)
                    .cornerRadius(Theme.cornerRadius)
                    .shadow(color: Color.black.opacity(0.06), radius: 12, y: 6)
                    .padding(.horizontal, 16)
                    .offset(y: -24)
                    
                    // MARK: - Menu Sections
                    VStack(spacing: 12) {
                        ProfileSection(title: "My Business") {
                            NavigationLink(destination: FarmerListingsView()) {
                                ProfileRowItem(icon: "list.bullet.rectangle.fill", label: "My Listings", color: .green, value: "\(max(vm.farmerCrops.count, vm.availableCrops.count)) active")
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            NavigationLink(destination: FarmerOrdersView()) {
                                ProfileRowItem(icon: "shippingbox.fill", label: "Incoming Orders", color: .orange, value: "\(vm.myOrders.count > 0 ? "\(vm.myOrders.count) orders" : "None")")
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            NavigationLink(destination: FarmerAnalyticsView()) {
                                ProfileRowItem(icon: "chart.bar.fill", label: "Market Analytics", color: .blue, value: "")
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        
                        ProfileSection(title: "Communication") {
                            NavigationLink(destination: MessagesView()) {
                                ProfileRowItem(icon: "message.fill", label: "Chat", color: .purple, value: "\(vm.chatThreads.count) chats")
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            NavigationLink(destination: PriceAlertsView()) {
                                ProfileRowItem(icon: "bell.fill", label: "Price Alerts", color: .red, value: "\(vm.priceAlerts.count) active")
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            NavigationLink(destination: NotificationsView()) {
                                ProfileRowItem(icon: "app.badge.fill", label: "Notifications", color: .indigo, value: vm.unreadCount > 0 ? "\(vm.unreadCount) new" : "")
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        
                        ProfileSection(title: "Account") {
                            Button(action: { showEditProfile = true }) {
                                ProfileRowItem(icon: "person.fill", label: "Edit Profile", color: .teal, value: "")
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            ProfileRowItem(icon: "questionmark.circle.fill", label: "Help & Support", color: .gray, value: "")
                            
                            Button(action: { showLogoutAlert = true }) {
                                HStack {
                                    Image(systemName: "rectangle.portrait.and.arrow.right")
                                        .foregroundColor(.red)
                                        .frame(width: 32)
                                    Text("Logout")
                                        .foregroundColor(.red)
                                        .fontWeight(.semibold)
                                    Spacer()
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 14)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                }
            }
            .background(Theme.background.ignoresSafeArea())
            .navigationBarHidden(true)
            .sheet(isPresented: $showEditProfile) { EditProfileView() }
            .alert("Logout?", isPresented: $showLogoutAlert) {
                Button("Logout", role: .destructive) { vm.logout() }
                Button("Cancel", role: .cancel) {}
            }
        }
    }
}

// MARK: - Sub-views

struct FarmerOrdersView: View {
    @EnvironmentObject var vm: AppViewModel
    var body: some View {
        NavigationStack {
            Group {
                if vm.myOrders.isEmpty {
                    EmptyStateView(icon: "shippingbox", title: "No Orders Yet", subtitle: "Orders from customers will appear here.")
                } else {
                    List {
                        ForEach(vm.myOrders) { order in
                            OrderRowView(order: order)
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Orders")
            .background(Theme.background.ignoresSafeArea())
        }
    }
}

struct OrderRowView: View {
    @EnvironmentObject var vm: AppViewModel
    let order: Order
    
    var statusColor: Color {
        switch order.status {
        case .pending: return .orange
        case .confirmed: return .blue
        case .dispatched: return .indigo
        case .delivered: return .green
        case .cancelled: return .red
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(order.crop.name)
                    .font(.headline)
                Spacer()
                Text(order.status.rawValue)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(statusColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(statusColor.opacity(0.1))
                    .cornerRadius(8)
            }
            Text("\(order.quantity) kg · ₹\(order.totalAmount, specifier: "%.0f") · by \(order.buyerName)")
                .font(.subheadline)
                .foregroundColor(Theme.textLight)
            
            if order.status == .pending {
                HStack(spacing: 8) {
                    Button("Confirm") { vm.updateOrderStatus(order, status: .confirmed) }
                        .font(.caption).fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12).padding(.vertical, 6)
                        .background(Color.blue).cornerRadius(8)
                    Button("Reject") { vm.updateOrderStatus(order, status: .cancelled) }
                        .font(.caption).fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12).padding(.vertical, 6)
                        .background(Color.red).cornerRadius(8)
                }
            } else if order.status == .confirmed {
                Button("Mark Dispatched") { vm.updateOrderStatus(order, status: .dispatched) }
                    .font(.caption).fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12).padding(.vertical, 6)
                    .background(Color.indigo).cornerRadius(8)
            }
        }
        .padding(.vertical, 8)
    }
}

struct EditProfileView: View {
    @EnvironmentObject var vm: AppViewModel
    @Environment(\.dismiss) var dismiss
    @State private var name: String = ""
    @State private var location: String = ""
    @State private var farmName: String = ""
    @State private var bio: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("Personal Info") {
                    TextField("Full Name", text: $name)
                    TextField("Location (City, State)", text: $location)
                }
                Section("Farm Info") {
                    TextField("Farm Name", text: $farmName)
                }
                Section("Bio") {
                    TextField("Tell buyers about you...", text: $bio, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .onAppear {
                name = vm.currentUser?.name ?? ""
                location = vm.currentUser?.location ?? ""
                farmName = vm.currentUser?.farmName ?? ""
                bio = vm.currentUser?.bio ?? ""
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        if var user = vm.currentUser {
                            user.name = name
                            user.location = location
                            user.farmName = farmName
                            user.bio = bio
                            vm.updateUser(user)
                        }
                        dismiss()
                    }
                    .fontWeight(.bold)
                    .foregroundColor(Theme.primary)
                }
            }
        }
    }
}

