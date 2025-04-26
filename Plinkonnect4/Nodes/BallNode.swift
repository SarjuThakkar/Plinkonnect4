//
//  BallNode.swift
//  Plinkonnect4
//
//  Created by Sarju Thakkar on 4/21/25.
//


import SpriteKit


class BallNode: SKShapeNode {
    let owner: BoardManager.Player

    init(position: CGPoint, radius: CGFloat = 10.0, owner: BoardManager.Player) {
        self.owner = owner
        super.init()

        self.position = position
        self.path = CGPath(ellipseIn: CGRect(x: -radius, y: -radius, width: radius * 2, height: radius * 2), transform: nil)
        self.fillColor = owner == .red ? .red : .yellow
        self.strokeColor = .white
        self.lineWidth = 2
        self.zPosition = 2

        let body = SKPhysicsBody(circleOfRadius: radius)
        body.restitution = 0.5
        body.friction = 0.2
        body.categoryBitMask = PhysicsCategory.ball
        body.contactTestBitMask = PhysicsCategory.slot | PhysicsCategory.peg
        body.collisionBitMask = PhysicsCategory.ball | PhysicsCategory.slot | PhysicsCategory.peg
        self.physicsBody = body
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
