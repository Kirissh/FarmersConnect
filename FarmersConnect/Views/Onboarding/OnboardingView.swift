import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var vm: AppViewModel
    @State private var currentTab = 0
    
    let pages = [
        OnboardingPage(
            title: "Everything in one app",
            subtitle: "List your produce, get price trends, and chat with buyers directly. A true companion for your agribusiness needs.",
            icon: "leaf.circle.fill",
            color: Theme.primary,
            features: [
                ("tag.fill", "List your produce with ease"),
                ("chart.line.uptrend.xyaxis", "Get real-time price trends"),
                ("message.fill", "Direct buyer-to-seller chat")
            ]
        ),
        OnboardingPage(
            title: "Fair Market Prices",
            subtitle: "Empowering you with AI-driven demand predictions and nearby market updates to ensure the best value.",
            icon: "chart.bar.xaxis",
            color: Theme.accent,
            features: [
                ("bolt.fill", "Instant price drop alerts"),
                ("magnifyingglass.circle.fill", "Demand forecasting"),
                ("mappin.and.ellipse", "Local market comparisons")
            ]
        ),
        OnboardingPage(
            title: "Secure & Transparent",
            subtitle: "A trusted platform linking verified farmers and customers with a seamless, intuitive experience.",
            icon: "shield.checkerboard",
            color: .blue,
            features: [
                ("person.badge.shield.checkmark.fill", "Verified profiles"),
                ("star.fill", "Trust ratings & reviews"),
                ("lock.shield.fill", "Safe data handling")
            ]
        )
    ]
    
    var body: some View {
        VStack {
            TabView(selection: $currentTab) {
                ForEach(0..<pages.count, id: \.self) { index in
                    OnboardingPageView(page: pages[index])
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
            
            PrimaryButton(title: currentTab == pages.count - 1 ? "Get Started" : "Next") {
                withAnimation {
                    if currentTab < pages.count - 1 {
                        currentTab += 1
                    } else {
                        vm.completeOnboarding()
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .background(Theme.background.ignoresSafeArea())
    }
}

struct OnboardingPage {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let features: [(String, String)]
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: page.icon)
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .foregroundColor(page.color)
                .padding(.bottom, 20)
            
            Text(page.title)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(Theme.textDark)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Text(page.subtitle)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(Theme.textLight)
                .padding(.horizontal, 40)
            
            VStack(alignment: .leading, spacing: 16) {
                ForEach(page.features, id: \.0) { feature in
                    FeatureRow(icon: feature.0, text: feature.1, color: page.color)
                }
            }
            .padding(.top, 20)
            .padding(.horizontal, 30)
            
            Spacer()
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.system(size: 24))
                .frame(width: 32)
            
            Text(text)
                .font(.headline)
                .foregroundColor(Theme.textDark)
            
            Spacer()
        }
    }
}
