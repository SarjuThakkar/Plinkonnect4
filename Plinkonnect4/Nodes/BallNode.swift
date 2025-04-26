//
//  BallNode.swift
//  Plinkonnect4
//
//  Created by Sarju Thakkar on 4/21/25.
//


import SpriteKit

class BallNode: SKShapeNode {

    init(position: CGPoint, radius: CGFloat = 10.0) {
        super.init()

        self.position = position
        self.path = CGPath(ellipseIn: CGRect(x: -radius, y: -radius, width: radius * 2, height: radius * 2), transform: nil)
        self.fillColor = .red
        self.strokeColor = .white
        self.lineWidth = 2
        self.zPosition = 2

        let physicsBody = SKPhysicsBody(circleOfRadius: radius)
        physicsBody.restitution = 0.5
        physicsBody.friction = 0.2
        physicsBody.categoryBitMask = PhysicsCategory.ball
        physicsBody.contactTestBitMask = PhysicsCategory.peg
        physicsBody.collisionBitMask = PhysicsCategory.peg
        self.physicsBody = physicsBody
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
