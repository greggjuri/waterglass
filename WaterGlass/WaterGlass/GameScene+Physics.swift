//
//  GameScene+Physics.swift
//  WaterGlass
//

import SpriteKit

// MARK: - Physics Setup

extension GameScene {

    func setupPhysicsWorld() {
        physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
    }

    func createGlass() {
        let glassRect = CGRect(
            x: Physics.glassInset,
            y: Physics.glassInset,
            width: size.width - Physics.glassInset * 2,
            height: size.height - Physics.glassInset * 2
        )

        // Invisible physics boundary — particles cannot escape
        physicsBody = SKPhysicsBody(edgeLoopFrom: glassRect)
        physicsBody?.friction = 0.1

        // Visible outline so you can see the glass
        let outline = SKShapeNode(rect: glassRect)
        outline.strokeColor = SKColor(white: 0.4, alpha: 0.6)
        outline.lineWidth = 2.0
        outline.fillColor = .clear
        outline.zPosition = 10  // render above effectNode so outline stays sharp
        addChild(outline)
    }
}
