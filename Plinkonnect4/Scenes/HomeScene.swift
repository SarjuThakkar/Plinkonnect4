import SwiftUI
import GameplayKit
import SpriteKit

class HomeScene: SKScene {

    static var isMuted: Bool = false

    private var currentPlayer: GameScene.Player = .red
    private var columnWidth: CGFloat { size.width / 7 }
    private var lastDropTime: TimeInterval = 0

    override func didMove(to view: SKView) {
        backgroundColor = .black

        let title = SKLabelNode(fontNamed: "AvenirNext-Bold")
        title.text = "Plinkonnect4"
        title.fontSize = 44
        title.position = CGPoint(x: size.width / 2, y: size.height * 0.75)
        title.zPosition = 10
        addChild(title)

        let playButton = createButton(withText: "Play", name: "playButton", position: CGPoint(x: size.width / 2, y: size.height * 0.55))
        addChild(playButton)

        let rulesButton = createButton(withText: "Rules", name: "rulesButton", position: CGPoint(x: size.width / 2, y: size.height * 0.45))
        addChild(rulesButton)

        let muteButton = createButton(withText: HomeScene.isMuted ? "Unmute" : "Mute", name: "muteButton", position: CGPoint(x: size.width / 2, y: size.height * 0.35))
        addChild(muteButton)
    }

    private func createButton(withText text: String, name: String, position: CGPoint) -> SKNode {
        let button = SKShapeNode(rectOf: CGSize(width: 150, height: 50), cornerRadius: 10)
        button.name = name
        button.fillColor = .white
        button.strokeColor = .gray
        button.position = position
        button.zPosition = 10

        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.name = name
        label.text = text
        label.fontSize = 20
        label.fontColor = .black
        label.verticalAlignmentMode = .center
        label.position = .zero
        button.addChild(label)

        return button
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: self) else { return }

        if let node = nodes(at: location).first(where: { $0.name == "playButton" }) {
            let gameScene = GameScene(size: size)
            gameScene.scaleMode = .resizeFill
            view?.presentScene(gameScene, transition: .fade(withDuration: 0.5))
            return
        }

        if let node = nodes(at: location).first(where: { $0.name == "rulesButton" }) {
            if let skView = self.view, let window = skView.window {
                let hosting = UIHostingController(rootView: RulesView())
                hosting.modalPresentationStyle = .fullScreen
                window.rootViewController?.present(hosting, animated: true)
            }
            return
        }

        if let node = nodes(at: location).first(where: { $0.name == "muteButton" }) {
            HomeScene.isMuted.toggle()
            node.removeFromParent()
            let updatedMuteButton = createButton(withText: HomeScene.isMuted ? "Unmute" : "Mute", name: "muteButton", position: CGPoint(x: size.width / 2, y: size.height * 0.35))
            addChild(updatedMuteButton)
            return
        }
    }

    override func update(_ currentTime: TimeInterval) {
        if currentTime - lastDropTime >= 1.0 {
            let x = CGFloat.random(in: 0...size.width)
            spawnBall(at: CGPoint(x: x, y: size.height - 10))
            lastDropTime = currentTime
        }
    }

    private func spawnBall(at position: CGPoint) {
        let radius = columnWidth * 0.45
        let ball = SKShapeNode(circleOfRadius: radius)
        ball.position = position
        ball.fillColor = currentPlayer == .red ? .red : .yellow
        ball.strokeColor = .white
        ball.lineWidth = 2
        ball.zPosition = 2

        let body = SKPhysicsBody(circleOfRadius: radius)
        body.restitution = 0.5
        body.friction = 0.2
        ball.physicsBody = body
        addChild(ball)

        currentPlayer = (currentPlayer == .red) ? .yellow : .red
    }
}
