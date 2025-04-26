//
//  GameScene.swift
//  Plinkonnect4
//
//  Created by Sarju Thakkar on 4/21/25.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {

    private let pegHitSounds = ["aNote.wav", "cNote.wav", "dNote.wav", "eNote.wav", "gNote.wav"]
    private var gameGrid: [[Player?]] = Array(repeating: Array(repeating: nil, count: 6), count: 7)
    private var isGameOver = false
    private var messageLabel: SKLabelNode?

    enum Player {
        case red, yellow
    }

    private var currentPlayer: Player = .red
    private var columnWidth: CGFloat { size.width / 7 }
    private var hasRegeneratedPegs = false
    private var lastBall: SKNode?
    private var ballDropTime: TimeInterval?
    private var canDropBall = true

    override func didMove(to view: SKView) {
        anchorPoint = CGPoint(x: 0, y: 0)
        backgroundColor = .black
        // Set gravity and world bounds
        physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsWorld.contactDelegate = self
        setupBoard()
        regeneratePegs()
        messageLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        messageLabel?.fontSize = 32
        messageLabel?.position = CGPoint(x: size.width / 2, y: size.height / 2 + 40)
        messageLabel?.zPosition = 100
        messageLabel?.isHidden = true
        addChild(messageLabel!)

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

        guard !isGameOver else { return }
        guard canDropBall else { return }

        // Clamp y to just below the top edge
        let yPosition = size.height - 10
        let xPosition = location.x
        finalizeBallPositions()
        checkForWin()
        spawnBall(at: CGPoint(x: xPosition, y: yPosition))
    }

    private func spawnPeg(at position: CGPoint) {
        let peg = PegNode(position: position)
        addChild(peg)
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

        ball.physicsBody?.categoryBitMask = PhysicsCategory.ball
        ball.physicsBody?.collisionBitMask = PhysicsCategory.ball | PhysicsCategory.slot | PhysicsCategory.peg
        ball.physicsBody?.contactTestBitMask = PhysicsCategory.slot | PhysicsCategory.peg

        canDropBall = false
        addChild(ball)
        lastBall = ball
        ballDropTime = nil
        currentPlayer = (currentPlayer == .red) ? .yellow : .red
        hasRegeneratedPegs = false
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
    
    private func regeneratePegs() {
        enumerateChildNodes(withName: "peg") { node, _ in
            node.removeFromParent()
        }

        let totalAvailableHeight = size.height - (columnWidth * 7 * 0.8)
        let rows = Int(totalAvailableHeight / columnWidth)
        let cols = 7
        let pegRadius: CGFloat = 1.0
        let xSpacing: CGFloat = columnWidth
        let ySpacing: CGFloat = columnWidth
        let xOffset = xSpacing / 2
        let rng = GKLinearCongruentialRandomSource()

        for row in 0..<rows {
            for col in 0..<cols {
                var xPos = (size.width - CGFloat(cols - 1) * xSpacing) / 2 + CGFloat(col) * xSpacing
                if row % 2 == 1 {
                    xPos += xOffset
                }
                let yPos = CGFloat(row) * ySpacing + (columnWidth * 7 * 0.8)

                if rng.nextUniform() < 0.1 {
                    continue
                }

                let jitterX = (rng.nextUniform() - 0.5) * 10.0
                let jitterY = (rng.nextUniform() - 0.5) * 10.0
                let pegPosition = CGPoint(x: xPos + CGFloat(jitterX), y: yPos + CGFloat(jitterY))

                let peg = SKShapeNode(circleOfRadius: pegRadius)
                peg.name = "peg"
                peg.fillColor = .orange
                peg.position = pegPosition

                let body = SKPhysicsBody(circleOfRadius: pegRadius)
                body.isDynamic = false
                body.categoryBitMask = PhysicsCategory.peg
                body.collisionBitMask = PhysicsCategory.ball
                peg.physicsBody = body

                addChild(peg)
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        guard !hasRegeneratedPegs,
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
            hasRegeneratedPegs = true
            regeneratePegs()
            canDropBall = true
        }
    }
    
    private func finalizeBallPositions() {
        // Recalculate the entire grid based on ball positions
        gameGrid = Array(repeating: Array(repeating: nil, count: 6), count: 7)

        for node in children where node is BallNode {
            guard let body = node.physicsBody else { continue }
            let position = node.position

            // Only consider balls that are within the board area
            let boardHeight = columnWidth * 6 * 0.8
            guard position.y <= boardHeight else { continue }

            let column = Int(position.x / columnWidth)
            let row = gameGrid[column].firstIndex(where: { $0 == nil }) ?? -1
            guard row >= 0 && column >= 0 && column < gameGrid.count && row < gameGrid[column].count else { continue }

            let player: Player = (node is BallNode && (node as! BallNode).fillColor == .red) ? .red : .yellow
            gameGrid[column][row] = player
        }
    }

    private func checkForWin() {
        
        var redWins = false
        var yellowWins = false


        for col in 0..<gameGrid.count {
            for row in 0..<gameGrid[col].count {
                guard let player = gameGrid[col][row] else { continue }

                if checkDirection(player: player, col: col, row: row, deltaCol: 1, deltaRow: 0) || // Horizontal
                   checkDirection(player: player, col: col, row: row, deltaCol: 0, deltaRow: 1) || // Vertical
                   checkDirection(player: player, col: col, row: row, deltaCol: 1, deltaRow: 1) || // Diagonal /
                   checkDirection(player: player, col: col, row: row, deltaCol: 1, deltaRow: -1) { // Diagonal \
                    if player == .red {
                        redWins = true
                    } else {
                        yellowWins = true
                    }
                }
            }
        }
        
        if redWins && yellowWins {
            showMessage("🤝 You both win!")
            isGameOver = true
        } else if redWins {
            showMessage("🎉 Red wins!")
            isGameOver = true
        } else if yellowWins {
            showMessage("🎉 Yellow wins!")
            isGameOver = true
        }

        if !isGameOver {
            let isTie = gameGrid.allSatisfy { column in
                column.allSatisfy { $0 != nil }
            }

            if isTie {
                showMessage("😐 It's a tie!")
                isGameOver = true
            }
        }
    }

    private func checkDirection(player: Player, col: Int, row: Int, deltaCol: Int, deltaRow: Int) -> Bool {
        let endCol = col + 3 * deltaCol
        let endRow = row + 3 * deltaRow

        if endCol < 0 || endCol >= gameGrid.count || endRow < 0 || endRow >= gameGrid[0].count {
            return false
        }

        for i in 1..<4 {
            let c = col + i * deltaCol
            let r = row + i * deltaRow
            if gameGrid[c][r] != player {
                return false
            }
        }
        return true
    }

    private func showMessage(_ text: String) {
        messageLabel?.text = text
        messageLabel?.isHidden = false
        addReplayButton()
    }

    private func addReplayButton() {
        let buttonBackground = SKShapeNode(rectOf: CGSize(width: 120, height: 40), cornerRadius: 8)
        buttonBackground.name = "replayButton"
        buttonBackground.fillColor = .white
        buttonBackground.strokeColor = .gray
        buttonBackground.position = CGPoint(x: size.width / 2, y: size.height / 2 - 20)
        buttonBackground.zPosition = 100

        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.name = "replayButton"
        label.text = "Replay"
        label.fontSize = 20
        label.fontColor = .black
        label.verticalAlignmentMode = .center
        label.position = CGPoint.zero
        buttonBackground.addChild(label)

        addChild(buttonBackground)
    }

    private func restartGame() {
        removeAllChildren()
        gameGrid = Array(repeating: Array(repeating: nil, count: 6), count: 7)
        isGameOver = false
        lastBall = nil
        ballDropTime = nil
        canDropBall = true
        hasRegeneratedPegs = false
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
            if ballBody.velocity.length() > 100 {
                let soundName = pegHitSounds.randomElement() ?? "aNote.wav"
                if !HomeScene.isMuted {
                    run(SKAction.playSoundFileNamed(soundName, waitForCompletion: false))
                }
            }
        }
    }
}

private extension CGVector {
    func length() -> CGFloat {
        return sqrt(dx * dx + dy * dy)
    }
}
