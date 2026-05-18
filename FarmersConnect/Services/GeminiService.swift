import Foundation

enum GeminiError: Error {
    case invalidURL
    case requestFailed
    case decodingError
}

class GeminiService {
    static let shared = GeminiService()
    
    private let apiKey = "GeminiKeyEntry"
    private let model = "gemini-flash-latest"
    
    private var baseURL: URL? {
        URL(string: "https://generativelanguage.googleapis.com/v1beta/models/\(model):generateContent?key=\(apiKey)")
    }
    
    func generateContent(prompt: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = baseURL else {
            completion(.failure(GeminiError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        print("Gemini API: Sending request to \(url.absoluteString.replacingOccurrences(of: apiKey, with: "REDACTED"))")
        
        let body: [String: Any] = [
            "contents": [
                [
                    "parts": [
                        ["text": prompt]
                    ]
                ]
            ]
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Gemini API Error: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                print("Gemini API Error: No data received")
                completion(.failure(GeminiError.requestFailed))
                return
            }
            
            // Log response for debugging (truncated)
            if let responseString = String(data: data, encoding: .utf8) {
                print("Gemini API Response: \(responseString.prefix(200))...")
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    if let error = json["error"] as? [String: Any] {
                        print("Gemini API Server Error: \(error["message"] ?? "Unknown error")")
                        completion(.failure(GeminiError.requestFailed))
                        return
                    }
                    
                    if let candidates = json["candidates"] as? [[String: Any]],
                       let firstCandidate = candidates.first,
                       let content = firstCandidate["content"] as? [String: Any],
                       let parts = content["parts"] as? [[String: Any]],
                       let text = parts.first?["text"] as? String {
                        completion(.success(text.trimmingCharacters(in: .whitespacesAndNewlines)))
                    } else {
                        print("Gemini API Error: Unexpected JSON structure")
                        completion(.failure(GeminiError.decodingError))
                    }
                } else {
                    completion(.failure(GeminiError.decodingError))
                }
            } catch {
                print("Gemini API Error: Decoding failed - \(error.localizedDescription)")
                completion(.failure(error))
            }
        }.resume()
    }
    
    // Specific Helpers
    func getPriceAnalysis(crop: String, completion: @escaping (String) -> Void) {
        let prompt = "Act as an agricultural market expert. Provide a concise 2-sentence market price prediction and trend for \(crop) in India for the next 30 days. Be specific about potential price changes."
        generateContent(prompt: prompt) { result in
            switch result {
            case .success(let text): completion(text)
            case .failure: completion("Unable to fetch price prediction for \(crop).")
            }
        }
    }
    
    func getWeatherForecast(location: String, completion: @escaping (String) -> Void) {
        let prompt = "Act as an agrometeorologist. Provide a concise 2-sentence weather forecast for farmers in \(location) for the next 7 days. Mention if it's a good time for sowing or harvesting."
        generateContent(prompt: prompt) { result in
            switch result {
            case .success(let text): completion(text)
            case .failure: completion("Weather data unavailable for \(location).")
            }
        }
    }
}
