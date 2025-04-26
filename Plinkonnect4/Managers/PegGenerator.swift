//
//  PegGenerator.swift
//  Plinkonnect4
//
//  Created by Sarju Thakkar on 4/25/25.
//

import SpriteKit
import GameplayKit

class PegGenerator {
    static func regeneratePegs(in scene: SKScene, columnWidth: CGFloat) {
        scene.enumerateChildNodes(withName: "peg") { node, _ in
            node.removeFromParent()
        }

        let totalAvailableHeight = scene.size.height - (columnWidth * 7 * 0.8)
        let rows = Int(totalAvailableHeight / columnWidth)
        let cols = 7
        let pegRadius: CGFloat = 1.0
        let xSpacing: CGFloat = columnWidth
        let ySpacing: CGFloat = columnWidth
        let xOffset = xSpacing / 2
        let rng = GKLinearCongruentialRandomSource()

        for row in 0..<rows {
            for col in 0..<cols {
                var xPos = (scene.size.width - CGFloat(cols - 1) * xSpacing) / 2 + CGFloat(col) * xSpacing
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

                scene.addChild(peg)
            }
        }
    }
}
