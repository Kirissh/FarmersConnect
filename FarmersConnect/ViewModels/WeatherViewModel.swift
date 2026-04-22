import Foundation
import Combine

class WeatherViewModel: ObservableObject {
    @Published var temperature: Double? = 28.0
    @Published var description: String = "Clear sky"
    @Published var weatherIcon: String = "sun.max.fill"
    
    init() {
        // Placeholders only for presentation
    }
}
