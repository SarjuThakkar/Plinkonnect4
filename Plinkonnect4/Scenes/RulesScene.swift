import SwiftUI
import SpriteKit

struct RulesView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 20) {
            Text("How to Play")
                .font(.largeTitle)
                .bold()
                .padding(.top)

            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    Text("🎮 **Plinkonnect4 Rules**")
                        .font(.headline)

                    Group {
                        Text("• Tap to drop a ball from the top of the board.")
                        Text("• Balls fall through a field of pegs that regenerate each turn.")
                        Text("• Players take turns dropping red and yellow balls.")
                        Text("• Balls bounce and roll based on physics, adding unpredictability.")
                        Text("• Get 4 in a row vertically, horizontally, or diagonally to win!")
                        Text("• Balls can get stuck and fall in later — even after the next turn!")
                        Text("• Both players can win in the same round due to chain reactions.")
                        Text("• If the board fills up with no winners, it's a tie.")
                    }
                    .font(.body)
                }
                .padding(.horizontal)
            }

            Button(action: {
                dismiss()
            }) {
                Text("Back")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .foregroundColor(.black)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .padding()
        .background(Color.black.ignoresSafeArea())
        .foregroundColor(.white)
    }
}
