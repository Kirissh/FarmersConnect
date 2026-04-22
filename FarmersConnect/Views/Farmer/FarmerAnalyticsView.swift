import SwiftUI

struct FarmerAnalyticsView: View {
    @EnvironmentObject var vm: AppViewModel
    let crops = ["Tomato", "Onion", "Rice", "Wheat"]
    @State private var selectedCrop = "Tomato"
    let times = ["7 days", "30 days", "90 days"]
    @State private var selectedTime = "30 days"
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Selectors
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(crops, id: \.self) { crop in
                                ChipSelection(title: crop, isSelected: selectedCrop == crop) {
                                    selectedCrop = crop
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    HStack {
                        ForEach(times, id: \.self) { time in
                            Text(time)
                                .font(.caption)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(selectedTime == time ? Theme.primary : Color.white)
                                .foregroundColor(selectedTime == time ? .white : Theme.textDark)
                                .cornerRadius(20)
                                .onTapGesture {
                                    withAnimation { selectedTime = time }
                                }
                        }
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    // Chart Placeholder
                    VStack(alignment: .leading) {
                        Text("Price Trend")
                            .font(.headline)
                        
                        ZStack {
                            Color.white
                            VStack {
                                Spacer()
                                // Fake Line Chart
                                Path { path in
                                    path.move(to: CGPoint(x: 0, y: 100))
                                    path.addLine(to: CGPoint(x: 50, y: 80))
                                    path.addLine(to: CGPoint(x: 100, y: 110))
                                    path.addLine(to: CGPoint(x: 150, y: 60))
                                    path.addLine(to: CGPoint(x: 200, y: 70))
                                    path.addLine(to: CGPoint(x: 250, y: 30))
                                    path.addLine(to: CGPoint(x: 300, y: 40))
                                }
                                .stroke(Theme.primary, lineWidth: 3)
                                .frame(height: 120)
                                .padding()
                                Spacer()
                            }
                        }
                        .frame(height: 200)
                        .cornerRadius(Theme.cornerRadius)
                    }
                    .padding(.horizontal)
                    
                    // AI Predictions
                    VStack(alignment: .leading, spacing: 12) {
                        Text("AI Insights")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ForEach(vm.predictions) { prediction in
                            HStack(spacing: 16) {
                                Image(systemName: prediction.type == .priceUp ? "arrow.up.right.circle.fill" : "chart.line.uptrend.xyaxis.circle.fill")
                                    .foregroundColor(Theme.accent)
                                    .font(.title)
                                Text(prediction.text)
                                    .font(.subheadline)
                                Spacer()
                            }
                            .cardStyle()
                            .padding(.horizontal)
                        }
                    }
                    
                    // Nearby Markets
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Nearby Markets")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ForEach(vm.marketPrices) { market in
                            HStack {
                                Text(market.marketName)
                                Spacer()
                                Text("₹\(market.price, specifier: "%.0f")/kg")
                                    .fontWeight(.bold)
                                    .foregroundColor(Theme.primary)
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(Theme.cornerRadius)
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical)
            }
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("Market Analytics")
        }
    }
}

struct ChipSelection: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Text(title)
            .fontWeight(.semibold)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(isSelected ? Theme.primary.opacity(0.1) : Color.white)
            .foregroundColor(isSelected ? Theme.primary : Theme.textDark)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? Theme.primary : Color.clear, lineWidth: 1)
            )
            .onTapGesture(perform: action)
    }
}
