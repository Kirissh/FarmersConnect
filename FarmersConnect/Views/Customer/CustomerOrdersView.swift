import SwiftUI

struct CustomerOrdersView: View {
    @EnvironmentObject var vm: AppViewModel
    var body: some View {
        NavigationStack {
            Group {
                if vm.myOrders.isEmpty {
                    EmptyStateView(icon: "bag", title: "No Orders Yet", subtitle: "Browse crops and place your first order!")
                } else {
                    List {
                        ForEach(vm.myOrders) { order in
                            CustomerOrderRow(order: order)
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("My Orders")
            .background(Theme.background.ignoresSafeArea())
        }
    }
}

struct CustomerOrderRow: View {
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
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(order.crop.name).font(.headline)
                Spacer()
                Text(order.status.rawValue)
                    .font(.caption).fontWeight(.bold).foregroundColor(statusColor)
                    .padding(.horizontal, 8).padding(.vertical, 4)
                    .background(statusColor.opacity(0.1)).cornerRadius(8)
            }
            Text("\(order.quantity) kg · ₹\(order.totalAmount, specifier: "%.0f") · \(order.farmerName)")
                .font(.subheadline).foregroundColor(Theme.textLight)
            Text(order.deliveryAddress)
                .font(.caption).foregroundColor(Theme.textLight)
        }
        .padding(.vertical, 8)
    }
}
