import SwiftTUI

struct Help: View {
    @Binding var currentView: MenuState

    @ViewBuilder
    var body: some View {
        VStack {
            Text("=== MASTERMIND HELP ===")
                .bold()
                .foregroundColor(Color.red)
                .padding()

            VStack(spacing: 1) {
                Text("How to play Mastermind:")
                Text("• The computer generates a secret 4-digit code")
                Text("• Each digit is between 1-6")
                Text("• You have to guess the secret code")
                Text("")
                Text("Feedback after each guess:")
                Text("• Black peg = correct digit in correct position")
                Text("• White peg = correct digit in wrong position")
                Text("")
                Text("Goal: Get 4 black pegs to win!")
            }
            .padding()

            buildBackButton()
        }.padding()
            .border(BorderStyle.rounded)
            .background(Color.blue)
    }

    @ViewBuilder
    private func buildBackButton() -> some View {
        Button("Back to Main Menu") {
            currentView = .mainMenu
        }
        .padding()
    }
}
