import Foundation
import SwiftTUI

enum GameStage {
    case notInitialized
    case initiating
    case guessing
    case checkingGuess
    case finished
}

struct GameView: View {
    @Binding var currentView: MenuState

    @State var gameState: GameState? = nil
    @State var gameStage: GameStage = .notInitialized
    @State var currentGuess: String = ""
    @State var errorMessage: String = ""
    @State var isLoading: Bool = false

    var gameService: GameServiceProtocol = GameService()

    @ViewBuilder
    var body: some View {
        switch gameStage {
        case .notInitialized, .initiating:
            startNewGameView()
        case .guessing, .checkingGuess:
            gameView()
        case .finished:
            finishedView()
        }
    }

    @ViewBuilder
    private func startNewGameView() -> some View {
        VStack(alignment: HorizontalAlignment.center) {
            Text("=== NEW MASTERMIND GAME ===").bold().foregroundColor(Color.red).padding()

            Text("Guess the secret 4-digit code!").padding()
            Text("Black pegs = correct digit in correct position").foregroundColor(Color.gray)
            Text("White pegs = correct digit in wrong position").foregroundColor(Color.gray)

            if gameStage == .initiating {
                Text("Creating game...").foregroundColor(Color.yellow)
            } else {
                Button(
                    "START GAME",
                    action: {
                        gameStage = .initiating
                        Task {
                            do {
                                let gameResp = try await gameService.createGame()
                                gameState = GameState(gameId: gameResp.gameId)
                                gameStage = .guessing
                            } catch {
                                errorMessage = "Error creating game: \(error.localizedDescription)"
                                gameStage = .notInitialized
                            }
                        }
                    }
                ).background(Color.cyan).padding()
            }

            if !errorMessage.isEmpty {
                Text(errorMessage).foregroundColor(Color.red).padding()
            }

            Button("Back to Menu") {
                currentView = .mainMenu
            }.background(Color.gray).padding()
        }.padding().border(BorderStyle.rounded)
    }

    @ViewBuilder
    private func gameView() -> some View {
        VStack(alignment: HorizontalAlignment.center) {
            Text("=== MASTERMIND GAME ===")
                .bold().foregroundColor(Color.red).padding()

            if let gameState = gameState {
                // Display previous attempts
                if let lastAttempt = gameState.attempts.last {
                    Text("Previous Attempt:").bold().padding(.top)

                    HStack {
                        Text(lastAttempt.guess).bold().foregroundColor(Color.red)
                        Text("Black: \(lastAttempt.black)")
                        Text("White: \(lastAttempt.white)")
                    }.padding(.horizontal)
                }

                // Current guess input
                VStack(alignment: HorizontalAlignment.center) {
                    Text("Enter your 4-digit guess:").padding(.top)

                    HStack(alignment: VerticalAlignment.center) {
                        TextField(
                            placeholder: "Your Guess",
                            action: { newValue in
                                currentGuess = newValue
                                submitGuess()
                            }
                        )

                    }.frame(width: 25).padding(Edges.horizontal, 25)

                    if gameStage == .checkingGuess {
                        Text("Checking guess...").foregroundColor(Color.yellow)
                    }
                }

                if !errorMessage.isEmpty {
                    Text(errorMessage).foregroundColor(Color.red).padding()
                }
            }

            Button("Back to Menu") {
                Task {
                    if let gameState = gameState {
                        try? await gameService.deleteGame(gameId: gameState.gameId)
                    }
                    currentView = .mainMenu
                }
            }.background(Color.gray).padding()
        }.padding().border(BorderStyle.rounded)
    }

    @ViewBuilder
    private func finishedView() -> some View {
        VStack (alignment: HorizontalAlignment.center) {
            Text("=== GAME FINISHED ===")
                .bold().foregroundColor(Color.red).padding()

            if let gameState = gameState {
                let lastAttempt = gameState.attempts.last
                if lastAttempt?.black == 4 {
                    Text("🎉 CONGRATULATIONS! 🎉").bold().foregroundColor(Color.green).padding()
                    Text("You cracked the code!").padding()
                    Text("Secret code was: \(lastAttempt?.guess ?? "")").bold().padding()
                    Text("You solved it in \(gameState.attempts.count) attempts!").padding()
                } else {
                    Text("Game Over").bold().foregroundColor(Color.red).padding()
                    Text("Better luck next time!").padding()
                }
            }

            Button("Play Again") {
                resetGame()
            }.background(Color.green).padding()

            Button("Back to Menu") {
                currentView = .mainMenu
            }.background(Color.gray).padding()
        }.padding().border(BorderStyle.rounded)
    }

    private func isValidGuess(_ guess: String) -> Bool {
        return guess.allSatisfy { $0.isNumber } && guess.count == 4
    }

    private func submitGuess() {
        guard let gameState = gameState else { return }
        guard isValidGuess(currentGuess) else {
            errorMessage = "Please enter a valid 4-digit number"
            return
        }

        gameStage = .checkingGuess
        errorMessage = ""

        Task {
            do {
                let request = GuessRequest(gameId: gameState.gameId, guess: currentGuess)
                let response = try await gameService.makeGuess(request: request)

                // Add attempt to game state
                let attempt = GuessAttempt(
                    guess: currentGuess, black: response.black, white: response.white)
                self.gameState?.attempts.append(attempt)

                // Check if game is won
                if response.black == 4 {
                    self.gameState?.isCompleted = true
                    gameStage = .finished
                } else {
                    // Reset for next guess
                    currentGuess = ""
                    gameStage = .guessing
                }

            } catch {
                errorMessage = "Error making guess: \(error.localizedDescription)"
                gameStage = .guessing
            }
        }
    }

    private func resetGame() {
        gameState = nil
        gameStage = .notInitialized
        currentGuess = ""
        errorMessage = ""
        isLoading = false
    }
}
