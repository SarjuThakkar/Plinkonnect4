//
//  PegNode.swift
//  Plinkonnect4
//
//  Created by Sarju Thakkar on 4/21/25.
//


import SpriteKit

class PegNode: SKShapeNode {

    init(position: CGPoint, radius: CGFloat = 1.0) {
        super.init()
        
        self.position = position
        self.path = CGPath(ellipseIn: CGRect(x: -radius, y: -radius, width: radius * 2, height: radius * 2), transform: nil)
        self.fillColor = .yellow
        self.strokeColor = .white
        self.lineWidth = 2
        self.zPosition = 1

        let physicsBody = SKPhysicsBody(circleOfRadius: radius)
        physicsBody.isDynamic = false
        physicsBody.categoryBitMask = PhysicsCategory.peg
        physicsBody.contactTestBitMask = PhysicsCategory.ball
        physicsBody.collisionBitMask = PhysicsCategory.ball
        self.physicsBody = physicsBody
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
