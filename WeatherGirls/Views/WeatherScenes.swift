import SpriteKit
import SwiftUI

// Helper to scale particle counts by intensity
fileprivate func scaled(_ base: CGFloat, for intensity: ParticleIntensity) -> CGFloat {
    switch intensity {
    case .background: return base
    case .foreground: return base * 0.3
    }
}

// MARK: - Starfield
final class StarfieldScene: SKScene {
    private var emitter: SKEmitterNode?

    override func didMove(to view: SKView) {
        createOrAttach()
        layout()
    }

    override func didChangeSize(_ oldSize: CGSize) { layout() }

    private func createOrAttach() {
        if emitter == nil {
            if let e = SKEmitterNode(fileNamed: "Starfield.sks") {
                emitter = e
                addChild(e)
            } else {
                print("[WeatherScenes] Missing SKS: Starfield.sks")
            }
        }
    }

    private func layout() {
        guard let emitter else { return }
        emitter.position = CGPoint(x: size.width/2, y: size.height)
        emitter.particlePositionRange = CGVector(dx: size.width + 40, dy: 0)
        emitter.zPosition = -10
    }

    static func make() -> SKScene {
        var s = StarfieldScene()
        s.backgroundColor = .clear
        s.scaleMode = .resizeFill
        return s
    }
}

// MARK: - Rain
final class RainScene: SKScene {
    private var emitter: SKEmitterNode?
    private var light = false
    private var intensity: ParticleIntensity = .background

    override func didMove(to view: SKView) {
        print("RainScene did move")
        createOrAttach()
        layout()
    }

    override func didChangeSize(_ oldSize: CGSize) { layout() }

    private func createOrAttach() {
        print("RainScene create or attach")
        if emitter == nil {
            let fileName = light ? "RainParticleLight.sks" : "RainParticle.sks"
            if let e = SKEmitterNode(fileNamed: fileName) {
                emitter = e
                addChild(e)
            } else {
                print("[WeatherScenes] Missing SKS: \(fileName)")
            }
        }
        applyIntensity()
    }

    private func applyIntensity() {
        guard let emitter else { return }
        emitter.particleBirthRate = scaled(emitter.particleBirthRate, for: intensity)
        emitter.alpha = intensity == .foreground ? 0.7 : 1.0
    }

    private func layout() {
        guard let emitter else { return }
        emitter.position = CGPoint(x: size.width / 2, y: size.height)
        //emitter.particlePositionRange = CGVector(dx: size.width + 40, dy: 0)
        emitter.zPosition = -1
    }

    static func make(light: Bool, intensity: ParticleIntensity) -> SKScene {
        let s = RainScene()
        s.light = light
        s.intensity = intensity
        s.backgroundColor = .clear
        s.scaleMode = .resizeFill
        return s
    }
}

// MARK: - Snow
final class SnowScene: SKScene {
    private var emitter: SKEmitterNode?
    private var intensity: ParticleIntensity = .background

    override func didMove(to view: SKView) {
        createOrAttach()
        layout()
    }

    override func didChangeSize(_ oldSize: CGSize) { layout() }

    private func createOrAttach() {
        if emitter == nil {
            if let e = SKEmitterNode(fileNamed: "SnowParticle.sks") {
                emitter = e
                addChild(e)
            } else {
                print("[WeatherScenes] Missing SKS: SnowParticle.sks")
            }
        }
        applyIntensity()
    }

    private func applyIntensity() {
        guard let emitter else { return }
        emitter.particleBirthRate = scaled(emitter.particleBirthRate, for: intensity)
        emitter.alpha = intensity == .foreground ? 0.7 : 1.0
    }

    private func layout() {
        guard let emitter else { return }
        emitter.position = CGPoint(x: size.width / 2, y: size.height)
        emitter.particlePositionRange = CGVector(dx: size.width + 80, dy: 0)
        emitter.zPosition = -1
    }

    static func make(intensity: ParticleIntensity) -> SKScene {
        let s = SnowScene()
        s.intensity = intensity
        s.backgroundColor = .clear
        s.scaleMode = .resizeFill
        return s
    }
}

// MARK: - Fog
final class FogScene: SKScene {
    private var emitter: SKEmitterNode?
    private var intensity: ParticleIntensity = .background

    override func didMove(to view: SKView) {
        createOrAttach()
        layout()
    }

    override func didChangeSize(_ oldSize: CGSize) { layout() }

    private func createOrAttach() {
        if emitter == nil {
            if let e = SKEmitterNode(fileNamed: "FogParticle.sks") {
                emitter = e
                addChild(e)
            } else {
                print("[WeatherScenes] Missing SKS: FogParticle.sks")
            }
        }
        applyIntensity()
    }

    private func applyIntensity() {
        guard let emitter else { return }
        emitter.particleBirthRate = scaled(emitter.particleBirthRate, for: intensity)
        emitter.alpha = intensity == .foreground ? 0.35 : 0.6
    }

    private func layout() {
        guard let emitter else { return }
        emitter.position = CGPoint(x: size.width / 2, y: size.height)
        emitter.particlePositionRange = CGVector(dx: size.width + 200, dy: 0)
        emitter.zPosition = -1
    }

    static func make(intensity: ParticleIntensity) -> SKScene {
        let s = FogScene()
        s.intensity = intensity
        s.backgroundColor = .clear
        s.scaleMode = .resizeFill
        return s
    }
}

// MARK: - Leaves
final class LeavesScene: SKScene {
    private var emitter: SKEmitterNode?
    private var intensity: ParticleIntensity = .background

    override func didMove(to view: SKView) {
        createOrAttach()
        layout()
    }

    override func didChangeSize(_ oldSize: CGSize) { layout() }

    private func createOrAttach() {
        if emitter == nil {
            if let e = SKEmitterNode(fileNamed: "LeavesParticle.sks") {
                emitter = e
                addChild(e)
            } else {
                print("[WeatherScenes] Missing SKS: LeavesParticle.sks")
            }
        }
        applyIntensity()
    }

    private func applyIntensity() {
        guard let emitter else { return }
        emitter.particleBirthRate = scaled(emitter.particleBirthRate, for: intensity)
        emitter.alpha = intensity == .foreground ? 0.8 : 1.0
    }

    private func layout() {
        guard let emitter else { return }
        emitter.position = CGPoint(x: size.width / 2, y: size.height)
        emitter.particlePositionRange = CGVector(dx: size.width + 120, dy: 0)
        emitter.zPosition = -1
    }

    static func make(intensity: ParticleIntensity) -> SKScene {
        let s = LeavesScene()
        s.intensity = intensity
        s.backgroundColor = .clear
        s.scaleMode = .resizeFill
        return s
    }
}

// MARK: - Thunderstorm (rain + lightning flashes)
final class ThunderstormScene: SKScene {
    private var rainEmitter: SKEmitterNode?
    private var lightningNode: SKShapeNode?
    private var intensity: ParticleIntensity = .background

    override func didMove(to view: SKView) {
        createOrAttach()
        layout()
        scheduleLightning()
    }

    override func didChangeSize(_ oldSize: CGSize) { layout() }

    private func createOrAttach() {
        if rainEmitter == nil {
            if let e = SKEmitterNode(fileNamed: "RainParticle.sks") {
                rainEmitter = e
                addChild(e)
            } else {
                print("[WeatherScenes] Missing SKS: RainParticle.sks")
            }
            applyIntensity()
        }

        if lightningNode == nil {
            let node = SKShapeNode(rectOf: CGSize(width: 4, height: 60), cornerRadius: 2)
            node.fillColor = .white
            node.strokeColor = .clear
            node.alpha = 0.0
            node.zPosition = 5
            lightningNode = node
            addChild(node)
        }
    }

    private func applyIntensity() {
        guard let rainEmitter else { return }
        rainEmitter.particleBirthRate = scaled(rainEmitter.particleBirthRate, for: intensity)
        rainEmitter.alpha = intensity == .foreground ? 0.7 : 1.0
    }

    private func layout() {
        if let rainEmitter {
            rainEmitter.position = CGPoint(x: size.width / 2, y: size.height)
            //rainEmitter.particlePositionRange = CGVector(dx: size.width + 40, dy: 0)
            rainEmitter.zPosition = -1
        }
    }

    private func scheduleLightning() {
        let wait = SKAction.wait(forDuration: Double.random(in: 2.5...6.0))
        let flash = SKAction.run { [weak self] in self?.performLightningFlash() }
        let seq = SKAction.sequence([wait, flash])
        run(SKAction.repeatForever(seq))
    }

    private func performLightningFlash() {
        guard let lightningNode else { return }
        let x = CGFloat.random(in: 20...(size.width - 20))
        let y = CGFloat.random(in: size.height * 0.4...size.height * 0.9)
        lightningNode.position = CGPoint(x: x, y: y)
        let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.05)
        let wait = SKAction.wait(forDuration: 0.08)
        let fadeOut = SKAction.fadeAlpha(to: 0.0, duration: 0.2)
        let seq = SKAction.sequence([fadeIn, wait, fadeOut])
        lightningNode.run(seq)
    }

    static func make(intensity: ParticleIntensity) -> SKScene {
        let s = ThunderstormScene()
        s.intensity = intensity
        s.backgroundColor = .clear
        s.scaleMode = .resizeFill
        return s
    }
}
