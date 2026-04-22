import SwiftUI

struct CustomerProfileView: View {
    @EnvironmentObject var vm: AppViewModel
    @State private var showEditProfile = false
    @State private var showLogoutAlert = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Header
                    ZStack(alignment: .bottomLeading) {
                        LinearGradient(
                            colors: [Theme.accent, Theme.accent.opacity(0.7)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                        .frame(height: 200)
                        
                        HStack(alignment: .bottom) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(vm.currentUser?.name ?? "Customer")
                                    .font(.title2).fontWeight(.bold).foregroundColor(.white)
                                Text(vm.currentUser?.location ?? "Bangalore, Karnataka")
                                    .font(.subheadline).foregroundColor(.white.opacity(0.85))
                                Text("Customer · Buyer")
                                    .font(.caption).foregroundColor(.white.opacity(0.7))
                            }
                            Spacer()
                            Button(action: { showEditProfile = true }) {
                                Image(systemName: "pencil.circle.fill")
                                    .font(.title2).foregroundColor(.white.opacity(0.8))
                            }
                        }
                        .padding(20)
                    }
                    
                    // Stats
                    HStack(spacing: 0) {
                        StatBlock(title: "Orders", value: "\(vm.myOrders.count)", icon: "bag.fill", color: .orange)
                        Divider().frame(height: 50)
                        StatBlock(title: "Saved", value: "\(vm.savedCrops.count)", icon: "heart.fill", color: .red)
                        Divider().frame(height: 50)
                        StatBlock(title: "Farmers", value: "\(vm.chatThreads.count)", icon: "person.2.fill", color: Theme.primary)
                    }
                    .padding(.vertical, 12)
                    .background(Color.white)
                    .cornerRadius(Theme.cornerRadius)
                    .shadow(color: Color.black.opacity(0.06), radius: 12, y: 6)
                    .padding(.horizontal, 16)
                    .offset(y: -24)
                    
                    VStack(spacing: 12) {
                        ProfileSection(title: "Shopping") {
                            NavigationLink(destination: CustomerOrdersView()) {
                                ProfileRowItem(icon: "bag.fill", label: "My Orders", color: .orange, value: "\(vm.myOrders.count) orders")
                            }.buttonStyle(PlainButtonStyle())
                            
                            NavigationLink(destination: WishlistView()) {
                                ProfileRowItem(icon: "heart.fill", label: "Saved Produce", color: .red, value: "\(vm.savedCrops.count) saved")
                            }.buttonStyle(PlainButtonStyle())
                            
                            NavigationLink(destination: CustomerCropsView()) {
                                ProfileRowItem(icon: "leaf.fill", label: "Browse Crops", color: .green, value: "")
                            }.buttonStyle(PlainButtonStyle())
                        }
                        
                        ProfileSection(title: "Connect") {
                            NavigationLink(destination: MessagesView()) {
                                ProfileRowItem(icon: "message.fill", label: "Messages", color: .purple, value: "\(vm.chatThreads.count) chats")
                            }.buttonStyle(PlainButtonStyle())
                            
                            NavigationLink(destination: PriceAlertsView()) {
                                ProfileRowItem(icon: "bell.fill", label: "Price Alerts", color: .red, value: "\(vm.priceAlerts.count) set")
                            }.buttonStyle(PlainButtonStyle())
                            
                            NavigationLink(destination: NotificationsView()) {
                                ProfileRowItem(icon: "app.badge.fill", label: "Notifications", color: .indigo, value: vm.unreadCount > 0 ? "\(vm.unreadCount) new" : "")
                            }.buttonStyle(PlainButtonStyle())
                        }
                        
                        ProfileSection(title: "Account") {
                            Button(action: { showEditProfile = true }) {
                                ProfileRowItem(icon: "person.fill", label: "Edit Profile", color: .teal, value: "")
                            }.buttonStyle(PlainButtonStyle())
                            
                            NavigationLink(destination: NearbyFarmersView()) {
                                ProfileRowItem(icon: "mappin.and.ellipse", label: "Nearby Farmers", color: .orange, value: "")
                            }.buttonStyle(PlainButtonStyle())
                            
                            Button(action: { showLogoutAlert = true }) {
                                HStack {
                                    Image(systemName: "rectangle.portrait.and.arrow.right")
                                        .foregroundColor(.red).frame(width: 32)
                                    Text("Logout").foregroundColor(.red).fontWeight(.semibold)
                                    Spacer()
                                }
                                .padding(.horizontal).padding(.vertical, 14)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                }
            }
            .background(Theme.background.ignoresSafeArea())
            .navigationBarHidden(true)
            .sheet(isPresented: $showEditProfile) { CustomerEditProfileView() }
            .alert("Logout?", isPresented: $showLogoutAlert) {
                Button("Logout", role: .destructive) { vm.logout() }
                Button("Cancel", role: .cancel) {}
            }
        }
    }
}

struct CustomerEditProfileView: View {
    @EnvironmentObject var vm: AppViewModel
    @Environment(\.dismiss) var dismiss
    @State private var name = ""
    @State private var location = ""
    @State private var email = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("Personal Info") {
                    TextField("Full Name", text: $name)
                    TextField("Location", text: $location)
                    TextField("Email (optional)", text: $email)
                        .keyboardType(.emailAddress)
                }
            }
            .onAppear {
                name = vm.currentUser?.name ?? ""
                location = vm.currentUser?.location ?? ""
                email = vm.currentUser?.email ?? ""
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        if var user = vm.currentUser {
                            user.name = name; user.location = location; user.email = email
                            vm.updateUser(user)
                        }
                        dismiss()
                    }.fontWeight(.bold).foregroundColor(Theme.accent)
                }
            }
        }
    }
}

// MARK: - Wishlist

struct WishlistView: View {
    @EnvironmentObject var vm: AppViewModel
    var body: some View {
        NavigationStack {
            Group {
                if vm.savedCrops.isEmpty {
                    EmptyStateView(icon: "heart", title: "Nothing Saved", subtitle: "Tap the heart on any crop to save it here.")
                } else {
                    ScrollView {
                        LazyVStack(spacing: 14) {
                            ForEach(vm.savedCrops) { crop in
                                NavigationLink(destination: CustomerProductDetailView(crop: crop)) {
                                    CustomerCropCard(crop: crop)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Saved Produce")
            .background(Theme.background.ignoresSafeArea())
        }
    }
}
