//
//  GameScene+Motion.swift
//  WaterGlass
//

import SpriteKit
import CoreMotion

// MARK: - CoreMotion

extension GameScene {

    func startMotionUpdates() {
        guard motionManager.isDeviceMotionAvailable else {
            print("Device motion not available (Simulator?) — using default gravity")
            return
        }

        motionManager.deviceMotionUpdateInterval = 1.0 / 60.0
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, error in
            if let error = error {
                print("Motion error: \(error.localizedDescription)")
                return
            }
            guard let motion = motion, let self = self else { return }
            self.physicsWorld.gravity = CGVector(
                dx: motion.gravity.x * Physics.gravityMultiplier,
                dy: motion.gravity.y * Physics.gravityMultiplier
            )
        }
    }

    func stopMotionUpdates() {
        motionManager.stopDeviceMotionUpdates()
    }
}
