import SwiftUI

struct CustomerCropsView: View {
    @EnvironmentObject var vm: AppViewModel
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(vm.availableCrops) { crop in
                        NavigationLink(destination: CustomerProductDetailView(crop: crop)) {
                            CustomerCropCard(crop: crop)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding()
            }
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("All Crops")
        }
    }
}
