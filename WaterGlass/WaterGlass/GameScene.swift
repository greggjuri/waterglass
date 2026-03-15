//
//  GameScene.swift
//  WaterGlass
//

import SpriteKit
import CoreMotion

// MARK: - Physics Constants

enum Physics {
    static let gravityMultiplier: Double = 20.0
    static let particleRadius: CGFloat = 5.0
    static let particleCount: Int = 80
    static let particleDensity: CGFloat = 0.3
    static let restitution: CGFloat = 0.0
    static let friction: CGFloat = 0.0
    static let linearDamping: CGFloat = 0.9
    static let angularDamping: CGFloat = 1.0
    static let glassInset: CGFloat = 60.0
    static let blurRadius: Double = 14.0             // Phase 2: metaball blur spread
    static let alphaMultiplier: Double = 10.0        // Phase 2: threshold sharpness
}

// MARK: - GameScene

class GameScene: SKScene {

    let motionManager = CMMotionManager()
    let effectNode = SKEffectNode()

    override func didMove(to view: SKView) {
        backgroundColor = .black
        setupPhysicsWorld()
        setupEffectNode()
        createGlass()
        createWaterParticles()
        startMotionUpdates()
    }

    override func update(_ currentTime: TimeInterval) {
        // CoreMotion updates gravity in its own closure
    }

    override func willMove(from view: SKView) {
        stopMotionUpdates()
    }
}
