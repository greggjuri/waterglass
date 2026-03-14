//
//  GameScene.swift
//  WaterGlass
//

import SpriteKit
import CoreMotion

// MARK: - Physics Constants

enum Physics {
    static let gravityMultiplier: Double = 20.0
    static let particleRadius: CGFloat = 12.0
    static let particleCount: Int = 50
    static let restitution: CGFloat = 0.3
    static let friction: CGFloat = 0.05
    static let linearDamping: CGFloat = 0.4
    static let angularDamping: CGFloat = 0.4
    static let glassInset: CGFloat = 60.0
}

// MARK: - GameScene

class GameScene: SKScene {

    let motionManager = CMMotionManager()

    override func didMove(to view: SKView) {
        backgroundColor = .black
        setupPhysicsWorld()
        createGlass()
        createWaterParticles()
        startMotionUpdates()
    }

    override func update(_ currentTime: TimeInterval) {
        // Per-frame updates — empty for Phase 1
        // CoreMotion updates gravity in its own closure
    }

    override func willMove(from view: SKView) {
        stopMotionUpdates()
    }
}
