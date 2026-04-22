import SwiftUI

struct NotificationsView: View {
    var body: some View {
        List {
            NotificationRow(icon: "bell.fill", color: Theme.accent, title: "Price Alert", subtitle: "Tomato prices are up by 12% in Pune APMC.", time: "1 hr ago")
            NotificationRow(icon: "shippingbox.fill", color: .blue, title: "New Order", subtitle: "Amit Kumar placed an order for 100kg Wheat.", time: "3 hrs ago")
            NotificationRow(icon: "message.fill", color: .purple, title: "New Message", subtitle: "You have a new message from Suresh Patil.", time: "Yesterday")
        }
        .listStyle(PlainListStyle())
        .navigationTitle("Notifications")
    }
}

struct NotificationRow: View {
    let icon: String
    let color: Color
    let title: String
    let subtitle: String
    let time: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Circle()
                .fill(color.opacity(0.2))
                .frame(width: 50, height: 50)
                .overlay(Image(systemName: icon).foregroundColor(color))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.headline)
                Text(subtitle).font(.subheadline).foregroundColor(.gray)
                Text(time).font(.caption).foregroundColor(.gray).padding(.top, 2)
            }
        }
        .padding(.vertical, 8)
    }
}
