import Alamofire
import Foundation

struct GameAPI {
    static let baseURL = "https://mastermind.darkube.app"
    
    static let headers: HTTPHeaders = [
        "Content-Type": "application/json",
        "Accept": "application/json"
    ]
    
    enum Endpoint {
        case createGame
        case deleteGame(gameId: String)
        case makeGuess(GuessRequest)
        
        var path: String {
            switch self {
            case .createGame:
                return "/game"
            case .deleteGame(let gameId):
                return "/game/\(gameId)"
            case .makeGuess:
                return "/guess"
            }
        }
        
        var method: HTTPMethod {
            switch self {
            case .createGame, .makeGuess:
                return .post
            case .deleteGame:
                return .delete
            }
        }
        
        var url: String {
            return GameAPI.baseURL + path
        }
    }
}
