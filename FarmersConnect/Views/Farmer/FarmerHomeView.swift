import SwiftUI

struct FarmerHomeView: View {
    @EnvironmentObject var vm: AppViewModel
    @StateObject private var weatherVM = WeatherViewModel()
    @State private var searchText = ""
    @State private var showAddProduct = false
    
    var columns: [GridItem] = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .font(.largeTitle)
                            .foregroundColor(Theme.primary)
                        
                        VStack(alignment: .leading) {
                            Text("Welcome")
                                .font(.caption)
                                .foregroundColor(Theme.textLight)
                            Text(vm.currentUser?.name ?? "Farmer")
                                .font(.headline)
                        }
                        
                        Spacer()
                        
                        NavigationLink(destination: NotificationsView()) {
                            ZStack(alignment: .topTrailing) {
                                Image(systemName: "bell.fill")
                                    .font(.title2)
                                    .foregroundColor(Theme.textDark)
                                .overlay(
                                    Group {
                                        if vm.unreadCount > 0 {
                                            Circle()
                                                .fill(Color.red)
                                                .frame(width: 10, height: 10)
                                                .offset(x: 2, y: -2)
                                        }
                                    }, alignment: .topTrailing
                                )
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Search
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("Search buyers or products", text: $searchText)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(Theme.cornerRadius)
                    .padding(.horizontal)
                    
                    // Quick Actions
                    LazyVGrid(columns: columns, spacing: 16) {
                        QuickActionCard(title: "List New Product", icon: "plus.circle.fill", color: Theme.primary) {
                            showAddProduct = true
                        }
                        
                        NavigationLink(destination: FarmerAnalyticsView()) {
                            QuickActionCard(title: "Market Prices", icon: "indianrupeesign.circle.fill", color: Theme.accent) {}
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        NavigationLink(destination: FarmerOrdersView()) {
                            QuickActionCard(title: "My Orders", icon: "shippingbox.fill", color: Color.blue) {}
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        NavigationLink(destination: MessagesView()) {
                            QuickActionCard(title: "Messages", icon: "message.fill", color: Color.purple) {}
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.horizontal)
                    
                    // Real-Time Local Weather + AI Insight
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Weather & Farmer Advice")
                            .font(.headline)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 20) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Local Area")
                                        .font(.title3)
                                        .fontWeight(.bold)
                                    Text(weatherVM.description)
                                        .foregroundColor(Theme.textLight)
                                }
                                Spacer()
                                VStack(spacing: 4) {
                                    Image(systemName: weatherVM.weatherIcon)
                                        .foregroundColor(weatherVM.weatherIcon.contains("sun") ? .orange : .blue)
                                        .font(.title2)
                                    if let temp = weatherVM.temperature {
                                        Text("\(temp, specifier: "%.1f")°C")
                                    } else {
                                        ProgressView()
                                    }
                                }
                            }
                            
                            Divider()
                            
                            HStack(alignment: .top) {
                                Image(systemName: "sparkles")
                                    .foregroundColor(.purple)
                                Text(vm.aiWeatherForecast)
                                    .font(.subheadline)
                                    .italic()
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(Theme.cornerRadius)
                        .shadow(color: Color.black.opacity(0.05), radius: 8, y: 4)

                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("Farmers Connect")
            .navigationBarHidden(true)
            .sheet(isPresented: $showAddProduct) {
                AddProductView()
            }
        }
    }
}

struct QuickActionCard: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.largeTitle)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(Theme.textDark)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
            .background(Color.white)
            .cornerRadius(Theme.cornerRadius)
            .shadow(color: Color.black.opacity(0.05), radius: 8, y: 4)
        }
    }
}
