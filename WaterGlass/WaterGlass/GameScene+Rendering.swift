//
//  GameScene+Rendering.swift
//  WaterGlass
//

import SpriteKit
import CoreImage

// MARK: - Metaball Filter

class MetaballFilter: CIFilter {
    @objc dynamic var inputImage: CIImage?

    override var outputImage: CIImage? {
        guard let input = inputImage else { return nil }

        // Step 1: Gaussian blur — spreads each particle into a soft glow
        guard let blur = CIFilter(name: "CIGaussianBlur") else { return nil }
        blur.setValue(input, forKey: kCIInputImageKey)
        blur.setValue(Physics.blurRadius, forKey: kCIInputRadiusKey)
        guard let blurred = blur.outputImage?.cropped(to: input.extent) else { return nil }

        // Step 2: Threshold via CIColorMatrix
        // - Zero out original RGB, replace with water colour via bias
        // - Boost alpha by alphaMultiplier to create hard liquid edges
        guard let colorMatrix = CIFilter(name: "CIColorMatrix") else { return nil }
        colorMatrix.setValue(blurred, forKey: kCIInputImageKey)
        colorMatrix.setValue(CIVector(x: 0, y: 0, z: 0, w: 0), forKey: "inputRVector")
        colorMatrix.setValue(CIVector(x: 0, y: 0, z: 0, w: 0), forKey: "inputGVector")
        colorMatrix.setValue(CIVector(x: 0, y: 0, z: 0, w: 0), forKey: "inputBVector")
        colorMatrix.setValue(CIVector(x: 0, y: 0, z: 0, w: CGFloat(Physics.alphaMultiplier)),
                             forKey: "inputAVector")
        colorMatrix.setValue(CIVector(x: 0.3, y: 0.6, z: 1.0, w: 0),
                             forKey: "inputBiasVector")

        return colorMatrix.outputImage
    }
}

// MARK: - Effect Node Setup

extension GameScene {

    func setupEffectNode() {
        effectNode.shouldEnableEffects = true
        effectNode.shouldRasterize = false
        effectNode.filter = MetaballFilter()
        addChild(effectNode)
    }
}
