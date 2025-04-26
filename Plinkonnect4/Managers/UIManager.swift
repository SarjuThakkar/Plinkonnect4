//
//  UIManager.swift
//  Plinkonnect4
//
//  Created by Sarju Thakkar on 4/25/25.
//

import SpriteKit

class UIManager {
    static func createMessageLabel(in scene: SKScene) -> SKLabelNode {
        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.fontSize = 32
        label.position = CGPoint(x: scene.size.width / 2, y: scene.size.height / 2 + 40)
        label.zPosition = 100
        label.isHidden = true
        scene.addChild(label)
        return label
    }

    static func showMessage(_ text: String, in label: SKLabelNode, on scene: SKScene) {
        label.text = text
        label.isHidden = false
        addReplayButton(to: scene)
    }

    static func addReplayButton(to scene: SKScene) {
        let buttonBackground = SKShapeNode(rectOf: CGSize(width: 120, height: 40), cornerRadius: 8)
        buttonBackground.name = "replayButton"
        buttonBackground.fillColor = .white
        buttonBackground.strokeColor = .gray
        buttonBackground.position = CGPoint(x: scene.size.width / 2, y: scene.size.height / 2 - 20)
        buttonBackground.zPosition = 100

        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.name = "replayButton"
        label.text = "Replay"
        label.fontSize = 20
        label.fontColor = .black
        label.verticalAlignmentMode = .center
        label.position = .zero
        buttonBackground.addChild(label)

        scene.addChild(buttonBackground)
    }
}
