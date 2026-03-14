//
//  GameScene+Water.swift
//  WaterGlass
//

import SpriteKit

// MARK: - Water Particles

extension GameScene {

    func createWaterParticles() {
        let glassMinX = Physics.glassInset + Physics.particleRadius * 2
        let glassMaxX = size.width - Physics.glassInset - Physics.particleRadius * 2
        let glassMinY = size.height * 0.4
        let glassMaxY = size.height - Physics.glassInset - Physics.particleRadius * 2

        for _ in 0..<Physics.particleCount {
            let particle = SKShapeNode(circleOfRadius: Physics.particleRadius)
            particle.fillColor = SKColor(red: 0.3, green: 0.6, blue: 1.0, alpha: 0.8)
            particle.strokeColor = SKColor(red: 0.2, green: 0.4, blue: 0.8, alpha: 0.6)
            particle.lineWidth = 1.0

            // Random position in upper half of glass — loose scatter avoids overlap explosion
            let x = CGFloat.random(in: glassMinX...glassMaxX)
            let y = CGFloat.random(in: glassMinY...glassMaxY)
            particle.position = CGPoint(x: x, y: y)

            let body = SKPhysicsBody(circleOfRadius: Physics.particleRadius)
            body.isDynamic = true
            body.restitution = Physics.restitution
            body.friction = Physics.friction
            body.linearDamping = Physics.linearDamping
            body.angularDamping = Physics.angularDamping
            body.allowsRotation = false
            particle.physicsBody = body

            addChild(particle)
        }
    }
}
