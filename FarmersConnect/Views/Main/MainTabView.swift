import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var vm: AppViewModel
    
    @State private var showAIChat = false
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            TabView {
                if vm.currentUser?.role == .farmer {
                    FarmerHomeView()
                        .tabItem {
                            Label("Home", systemImage: "house.fill")
                        }
                    
                    FarmerListingsView()
                        .tabItem {
                            Label("Listings", systemImage: "list.bullet.rectangle.fill")
                        }
                    
                    FarmerAnalyticsView()
                        .tabItem {
                            Label("Analytics", systemImage: "chart.bar.fill")
                        }
                    
                    FarmerProfileView()
                        .tabItem {
                            Label("Profile", systemImage: "person.fill")
                        }
                } else {
                    CustomerHomeView()
                        .tabItem {
                            Label("Home", systemImage: "house.fill")
                        }
                    
                    CustomerCropsView()
                        .tabItem {
                            Label("Crops", systemImage: "leaf.fill")
                        }
                    
                    MessagesView()
                        .tabItem {
                            Label("Messages", systemImage: "message.fill")
                        }
                    
                    CustomerProfileView()
                        .tabItem {
                            Label("Profile", systemImage: "person.fill")
                        }
                }
            }
            .accentColor(Theme.primary)
            
            // AI Chat Floating Button
            Button(action: { showAIChat.toggle() }) {
                Image(systemName: "sparkles")
                    .font(.title2.bold())
                    .foregroundColor(.white)
                    .padding(16)
                    .background(
                        LinearGradient(gradient: Gradient(colors: [.blue, .purple]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .clipShape(Circle())
                    .shadow(radius: 4)
            }
            .padding(.trailing, 20)
            .padding(.bottom, 70) // Place above tab bar
        }
        .sheet(isPresented: $showAIChat) {
            AIChatBotView()
                .environmentObject(vm)
        }
    }
}

