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
            particle.fillColor = .white       // white for max alpha signal — filter sets colour
            particle.strokeColor = .clear     // no outline — filter handles visual
            particle.lineWidth = 0

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

            effectNode.addChild(particle)
        }
    }
}
