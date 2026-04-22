import SwiftUI
import UIKit

// MARK: - Shared Layout Components

struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(Color.gray.opacity(0.3))
            Text(title).font(.title3).fontWeight(.bold).foregroundColor(Theme.textDark)
            Text(subtitle).font(.subheadline).foregroundColor(Theme.textLight).multilineTextAlignment(.center).padding(.horizontal, 40)
            Spacer()
        }
    }
}

struct ProfileSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(Theme.textLight)
                .padding(.horizontal)
                .padding(.bottom, 6)
            
            VStack(spacing: 0) {
                content
            }
            .background(Color.white)
            .cornerRadius(Theme.cornerRadius)
            .shadow(color: Color.black.opacity(0.03), radius: 6, y: 3)
        }
    }
}

struct ProfileRowItem: View {
    let icon: String
    let label: String
    let color: Color
    let value: String
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(color.opacity(0.15))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.subheadline)
            }
            Text(label)
                .foregroundColor(Theme.textDark)
                .fontWeight(.medium)
            Spacer()
            if !value.isEmpty {
                Text(value)
                    .font(.caption)
                    .foregroundColor(Theme.textLight)
            }
            Image(systemName: "chevron.right")
                .foregroundColor(.gray.opacity(0.4))
                .font(.caption)
        }
        .padding(.horizontal)
        .padding(.vertical, 14)
        .overlay(Divider().padding(.leading, 60), alignment: .bottom)
    }
}

struct StatBlock: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.caption)
            Text(value)
                .font(.subheadline)
                .fontWeight(.bold)
            Text(title)
                .font(.caption2)
                .foregroundColor(Theme.textLight)
        }
        .frame(maxWidth: .infinity)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    var body: some View {
        VStack(spacing: 8) {
            Text(value).font(.title3).fontWeight(.bold).foregroundColor(Theme.textDark)
            Text(title).font(.caption).foregroundColor(Theme.textLight)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.white)
        .cornerRadius(Theme.cornerRadius)
        .shadow(color: Color.black.opacity(0.05), radius: 8, y: 4)
    }
}


// MARK: - Placeholder Views (Cleared Out)

struct PriceAlertsView: View {
    var body: some View {
        Text("Price Alerts Placeholder")
            .navigationTitle("Price Alerts")
    }
}

struct NearbyFarmersView: View {
    var body: some View {
        Text("Nearby Farmers Placeholder")
            .navigationTitle("Nearby Farmers")
    }
}

struct MarketPricesView: View {
    var body: some View {
        Text("Market Prices Placeholder")
            .navigationTitle("Market Prices")
    }
}


struct SuccessOverlay: View {
    let message: String
    let onDismiss: () -> Void
    var body: some View {
        ZStack {
            Color.black.opacity(0.4).ignoresSafeArea()
            VStack(spacing: 20) {
                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .foregroundColor(Theme.primary)
                Text(message)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                Button("Done") { onDismiss() }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width: 160)
                    .padding()
                    .background(Theme.primary)
                    .cornerRadius(Theme.cornerRadius)
            }
            .padding(32)
            .background(Color.white)
            .cornerRadius(24)
            .padding(40)
        }
    }
}
