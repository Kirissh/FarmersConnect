import SwiftUI

struct RoleSelectionView: View {
    @EnvironmentObject var vm: AppViewModel
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [Theme.primary.opacity(0.08), Theme.background], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                VStack(spacing: 12) {
                    Image(systemName: "leaf.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(Theme.primary)
                        .padding(.top, 60)
                    
                    Text("Farmers Connect")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(Theme.textDark)
                    
                    Text("Who are you?")
                        .font(.subheadline)
                        .foregroundColor(Theme.textLight)
                }
                .padding(.bottom, 48)
                
                VStack(spacing: 20) {
                    RoleCard(
                        title: "I'm a Farmer",
                        subtitle: "List my produce, track market prices, and connect with buyers across India.",
                        icon: "tractor.fill",
                        color: Theme.primary,
                        badges: ["Sell Produce", "Price Analytics", "Orders"]
                    ) {
                        withAnimation(.spring()) {
                            vm.selectRole(.farmer)
                        }
                    }
                    
                    RoleCard(
                        title: "I'm a Customer",
                        subtitle: "Buy fresh produce directly from verified farmers at fair market prices.",
                        icon: "cart.fill",
                        color: Theme.accent,
                        badges: ["Browse Crops", "Direct Purchase", "Chat"]
                    ) {
                        withAnimation(.spring()) {
                            vm.selectRole(.customer)
                        }
                    }
                }
                .padding(.horizontal, 24)
                
                Spacer()
                
                Text("By continuing, you agree to our Terms of Service & Privacy Policy")
                    .font(.caption2)
                    .foregroundColor(Theme.textLight)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .padding(.bottom, 32)
            }
        }
    }
}

struct RoleCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let badges: [String]
    let action: () -> Void
    @State private var pressed = false
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 16) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(color.opacity(0.15))
                            .frame(width: 60, height: 60)
                        Image(systemName: icon)
                            .font(.title)
                            .foregroundColor(color)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(Theme.textDark)
                        Text(subtitle)
                            .font(.caption)
                            .foregroundColor(Theme.textLight)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(color.opacity(0.6))
                        .font(.subheadline)
                }
                
                HStack(spacing: 8) {
                    ForEach(badges, id: \.self) { badge in
                        Text(badge)
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundColor(color)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(color.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
            }
            .padding(20)
            .background(Color.white)
            .cornerRadius(Theme.cornerRadius)
            .shadow(color: Color.black.opacity(0.07), radius: 12, y: 6)
            .scaleEffect(pressed ? 0.97 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(DragGesture(minimumDistance: 0)
            .onChanged { _ in withAnimation(.spring(response: 0.2)) { pressed = true } }
            .onEnded { _ in withAnimation(.spring(response: 0.2)) { pressed = false } }
        )
    }
}
