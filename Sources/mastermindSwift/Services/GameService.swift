import Alamofire
import Foundation

protocol GameServiceProtocol {
    func createGame() async throws -> CreateGameResponse
    func makeGuess(request: GuessRequest) async throws -> GuessResponse
    func deleteGame(gameId: String) async throws
}

final class GameService: GameServiceProtocol {

    private let session: Session
    private let decoder: JSONDecoder
    private let paramEncoder: JSONParameterEncoder

    init(session: Session = Session.default) {
        self.session = session
        self.decoder = JSONDecoder()
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase
        self.paramEncoder = JSONParameterEncoder()
        self.paramEncoder.encoder.keyEncodingStrategy = .convertToSnakeCase

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'"
        self.decoder.dateDecodingStrategy = .formatted(dateFormatter)
        self.paramEncoder.encoder.dateEncodingStrategy = .formatted(dateFormatter)
    }

    func createGame() async throws -> CreateGameResponse {
        let endpoint = GameAPI.Endpoint.createGame

        let dataTask = session.request(
            endpoint.url,
            method: endpoint.method,
            headers: GameAPI.headers
        )

        let response = await dataTask.serializingData().response

        switch response.result {
        case .success(let data):
            do {
                let gameResponse = try decoder.decode(CreateGameResponse.self, from: data)

                log.info(
                    "create game successful",
                    context: [
                        "response_data": "\(data)",
                        "game_id": "\(gameResponse.gameId)",
                    ])

                return gameResponse
            } catch {
                log.error(
                    "failed to decode create game response",
                    context: [
                        "response_data": "\(data)"
                    ])
                throw ServiceError.decodingError(error)
            }
        case .failure(let error):
            log.error(
                "create game failure",
                context: [
                    "response": "\(response)",
                    "response_body": "\(String(describing: response.data))",
                ])
            throw ServiceError.networkError(error)
        }
    }

    func makeGuess(request: GuessRequest) async throws -> GuessResponse {
        let endpoint = GameAPI.Endpoint.makeGuess(request)

        let dataTask = session.request(
            endpoint.url,
            method: endpoint.method,
            parameters: request,
            encoder: paramEncoder,
            headers: GameAPI.headers
        )

        let response = await dataTask.serializingData().response

        switch response.result {
        case .success(let data):
            if response.response?.statusCode ?? 0 >= 400 {
                let errResponse = try decoder.decode(ErrorResponse.self, from: data)

                log.warning(
                    "make guess errored",
                    context: [
                        "response_data":
                            "\(String(data: data, encoding: .utf8) ?? "encoding resulted in null")",
                        "guess.guess": "\(request.guess)",
                        "guess.game_id": "\(request.gameId)",
                        "error_response.error": errResponse.error,
                    ])

                throw ServiceError.apiError(errResponse.error)
            }

            do {
                let guessResponse = try decoder.decode(GuessResponse.self, from: data)

                log.info(
                    "make guess successful",
                    context: [
                        "response_data": "\(data)",
                        "guess.guess": "\(request.guess)",
                        "guess.game_id": "\(request.gameId)",
                        "guess_response.black": "\(guessResponse.black)",
                        "guess_response.white": "\(guessResponse.white)",
                    ])

                return guessResponse
            } catch {
                log.error(
                    "make guess response decode failiure",
                    context: [
                        "response_data":
                            "\(String(data: data, encoding: .utf8) ?? "encoded to null")",
                        "guess.guess": "\(request.guess)",
                        "guess.game_id": "\(request.gameId)",
                    ])

                throw ServiceError.decodingError(error)
            }
        case .failure(let error):
            log.error(
                "make guess failure",
                context: [

                    "response": "\(response)",
                    "response_data":
                        "\(String(data: response.data!, encoding: .utf8) ?? "encoded to null")",
                    "guess.guess": "\(request.guess)",
                    "guess.game_id": "\(request.gameId)",
                ])

            throw ServiceError.networkError(error)

        }
    }

    func deleteGame(gameId: String) async throws {
        let endpoint = GameAPI.Endpoint.deleteGame(gameId: gameId)

        let dataTask = session.request(
            endpoint.url,
            method: endpoint.method,
            headers: GameAPI.headers
        )

        let response = await dataTask.serializingData().response

        switch response.result {
        case .success(_):
            return
        case .failure(let error):
            throw ServiceError.networkError(error)
        }
    }
}
