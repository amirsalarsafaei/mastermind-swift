import Foundation

enum ServiceError: Error, LocalizedError {
    case networkError(Error)
    case decodingError(Error)
    case apiError(String)
    case invalidResponse
    case noData
    
    var errorDescription: String? {
        switch self {
        case .apiError(let errorDescription):
            return "API Error: \(errorDescription)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Decoding error: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response received"
        case .noData:
            return "No data received"
        }
    }
}
