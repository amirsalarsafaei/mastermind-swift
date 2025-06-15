import Foundation
import SwiftTUI

enum MenuState {
    case mainMenu
    case game
    case help
}

struct MainMenu: View {
    @State private var currentView: MenuState = .mainMenu

    var body: some View {
        buildCurrentView().frame(minWidth: nil, maxWidth: Extended.infinity, minHeight: nil, maxHeight: Extended.infinity)
    }

    @ViewBuilder
    private func buildCurrentView() -> some View {
        switch currentView {
        case .mainMenu:
            buildMainMenuView()
        case .game:
            GameView(currentView: $currentView)
        case .help:
            Help(currentView: $currentView)
        }
    }

    @ViewBuilder
    private func buildMainMenuView() -> some View {
        VStack(alignment: HorizontalAlignment.center) {
            Text("=== MAIN MENU ===")
                .bold()
                .foregroundColor(Color.brightRed)
                .padding()

            VStack(alignment: HorizontalAlignment.center, spacing: 1) {
                Button("Start Game") {
                    currentView = .game
                }

                Button("Help") {
                    currentView = .help
                }

                Button("Exit") {
                    exit(0)
                }
            }
            .padding()
            Text("You can move up and down using arrow keys")
                .padding()
        }
        .border(BorderStyle.rounded)
        .background(Color.blue)
    }

    @ViewBuilder
    private func buildGameView() -> some View {
        VStack {
            Text("=== GAME VIEW ===")
                .padding()

            Text("Welcome to the game!")
                .padding()

            Text("Game content goes here...")
                .padding()

            buildBackButton()
        }
        .border()
    }

    @ViewBuilder
    private func buildSettingsView() -> some View {
        VStack {
            Text("=== SETTINGS ===")
                .padding()

            VStack(spacing: 1) {
                Text("• Sound: ON")
                Text("• Difficulty: Medium")
                Text("• Theme: Dark")
            }
            .padding()

            buildBackButton()
        }
        .border()
    }

    @ViewBuilder
    private func buildHelpView() -> some View {
        VStack {
            Text("=== HELP & INSTRUCTIONS ===")
                .padding()

            VStack(spacing: 1) {
                Text("How to play:")
                Text("• Use arrow keys to move")
                Text("• Press SPACE to interact")
                Text("• Press ESC to pause")
            }
            .padding()

            buildBackButton()
        }
        .border()
    }

    @ViewBuilder
    private func buildBackButton() -> some View {
        Button("Back to Main Menu") {
            currentView = .mainMenu
        }
        .padding()
    }
}
