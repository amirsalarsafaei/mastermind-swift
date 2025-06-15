import Foundation

// Response Models
struct CreateGameResponse: Codable {
    let gameId: String
}

struct GuessResponse: Codable {
    let black: Int
    let white: Int
}

struct ErrorResponse: Codable {
    let error: String
}

// Request Models
struct GuessRequest: Codable {
    let gameId: String
    let guess: String
}

// Game State Models
struct GameState {
    var gameId: String
    var attempts: [GuessAttempt] = []
    var isCompleted: Bool = false
}

struct GuessAttempt {
    let guess: String
    let black: Int
    let white: Int
}
