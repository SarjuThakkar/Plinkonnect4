//
//  GameScene.swift
//  Plinkonnect4
//
//  Created by Sarju Thakkar on 4/21/25.
//

import SpriteKit
import GameplayKit

enum GameState {
    case waitingForInput, ballFalling, checkingWin, gameOver
}

class GameScene: SKScene, SKPhysicsContactDelegate {

    private var boardManager = BoardManager()

    typealias Player = BoardManager.Player
    private var messageLabel: SKLabelNode?

    private var currentPlayer: Player = .red
    private var columnWidth: CGFloat { size.width / 7 }
    private var lastBall: SKNode?
    private var ballDropTime: TimeInterval?
    private var gameState: GameState = .waitingForInput

    override func didMove(to view: SKView) {
        anchorPoint = CGPoint(x: 0, y: 0)
        backgroundColor = .black
        // Set gravity and world bounds
        physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsWorld.contactDelegate = self
        setupBoard()
        PegGenerator.regeneratePegs(in: self, columnWidth: columnWidth)
        messageLabel = UIManager.createMessageLabel(in: self)

        let backArrow = SKLabelNode(fontNamed: "AvenirNext-Bold")
        backArrow.name = "backButton"
        backArrow.text = "←"
        backArrow.fontSize = 24
        backArrow.fontColor = .white
        backArrow.position = CGPoint(x: 30, y: size.height - 30)
        backArrow.zPosition = 101
        addChild(backArrow)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        if let node = nodes(at: location).first(where: { $0.name == "backButton" }) {
            let homeScene = HomeScene(size: size)
            homeScene.scaleMode = .resizeFill
            view?.presentScene(homeScene, transition: .fade(withDuration: 0.5))
            return
        }

        if let node = nodes(at: location).first(where: { $0.name == "replayButton" }) {
            restartGame()
            return
        }

        guard gameState != .gameOver else { return }
        guard gameState == .waitingForInput else { return }

        // Clamp y to just below the top edge
        let yPosition = size.height - 10
        let xPosition = location.x
        finalizeBallPositions()
        checkForWin()
        spawnBall(at: CGPoint(x: xPosition, y: yPosition))
    }

    private func spawnBall(at position: CGPoint) {
        let radius = columnWidth * 0.4
        let ball = BallNode(position: position, radius: radius)

        switch currentPlayer {
        case .red:
            ball.fillColor = .red
        case .yellow:
            ball.fillColor = .yellow
        }

        // already configured in BallNode

        gameState = .ballFalling
        addChild(ball)
        lastBall = ball
        ballDropTime = nil
        currentPlayer = (currentPlayer == .red) ? .yellow : .red
        ballDropTime = CACurrentMediaTime()
    }
    
    private func setupBoard(columns: Int = 7, rows: Int = 6) {
        let wallWidth: CGFloat = 4
        let boardHeight = columnWidth * CGFloat(rows) * 0.8
        let columnWidth: CGFloat = columnWidth

        for col in 0...columns {
            let x = CGFloat(col) * columnWidth

            let wall = SKNode()
            wall.position = CGPoint(x: x, y: boardHeight / 2)
            wall.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: wallWidth, height: boardHeight))
            wall.physicsBody?.isDynamic = false
            wall.physicsBody?.categoryBitMask = PhysicsCategory.slot

            // Visual aid
            let visual = SKShapeNode(rectOf: CGSize(width: wallWidth, height: boardHeight))
            visual.fillColor = .blue
            wall.addChild(visual)

            addChild(wall)
        }

        // Floor
        let floor = SKNode()
        floor.position = CGPoint(x: size.width / 2, y: 0)
        floor.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: size.width, height: 10))
        floor.physicsBody?.isDynamic = false
        floor.physicsBody?.categoryBitMask = PhysicsCategory.slot

        addChild(floor)
    }
    
    override func update(_ currentTime: TimeInterval) {
        guard gameState == .ballFalling,
              let dropTime = ballDropTime else { return }

        let elapsed = currentTime - dropTime
        guard elapsed > 0.5 else { return }

        let ballsAtRest = children.compactMap { $0 as? BallNode }.allSatisfy {
            guard let body = $0.physicsBody else { return false }
            return body.velocity.length() < 5 && abs(body.angularVelocity) < 0.1
        }

        if ballsAtRest {
            finalizeBallPositions()
            checkForWin()
            gameState = .waitingForInput
            PegGenerator.regeneratePegs(in: self, columnWidth: columnWidth)
        }
    }
    
    private func finalizeBallPositions() {
        boardManager.finalizeBallPositions(in: self, columnWidth: columnWidth)
    }

    private func checkForWin() {
        if boardManager.checkForWin(showMessage: { showMessage($0) }) {
            gameState = .gameOver
        }
    }

    private func showMessage(_ text: String) {
        if let messageLabel = messageLabel {
            UIManager.showMessage(text, in: messageLabel, on: self)
        }
    }

    private func restartGame() {
        removeAllChildren()
        boardManager.gameGrid = Array(repeating: Array(repeating: nil, count: 6), count: 7)
        gameState = .waitingForInput
        lastBall = nil
        ballDropTime = nil
        currentPlayer = .red
        didMove(to: view!)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let pegMask = PhysicsCategory.peg
        let ballMask = PhysicsCategory.ball

        let isPegBallContact = (contact.bodyA.categoryBitMask == pegMask && contact.bodyB.categoryBitMask == ballMask) ||
                               (contact.bodyB.categoryBitMask == pegMask && contact.bodyA.categoryBitMask == ballMask)

        if isPegBallContact {
            let ballBody = (contact.bodyA.categoryBitMask == PhysicsCategory.ball) ? contact.bodyA : contact.bodyB
            SoundManager.shared.playPegHitSound(on: self, velocity: ballBody.velocity.length())
        }
    }
}
