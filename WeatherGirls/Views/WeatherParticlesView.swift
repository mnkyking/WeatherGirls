import SwiftUI
import SpriteKit

enum WeatherEffectKind: Equatable {
    case none
    case rain(light: Bool) // light=true for light rain
    case snow
    case fog
    case leaves
    case thunderstorm // rain + lightning overlay
}

struct WeatherEffectMapping {
    static func effect(for weatherID: Int?) -> WeatherEffectKind {
        guard let id = weatherID else { return .none }
        switch id {
        case 200...232:
            return .thunderstorm
        case 300...321:
            return .rain(light: true)
        case 500...504:
            return .rain(light: false)
        case 511:
            return .snow
        case 520...531:
            return .rain(light: false)
        case 600...622:
            return .snow
        case 700...781:
            return .fog
        case 800:
            return .none
        case 801...804:
            return .leaves // optional subtle effect for clouds; can be changed
        default:
            return .none
        }
    }

    // Optional mapping from preview asset names to an effect, used when swiping art previews.
    static func effect(forPreviewAsset asset: String?) -> WeatherEffectKind? {
        guard let asset else { return nil }
        switch asset {
        case "rain": return .rain(light: false)
        case "snow": return .snow
        case "fog": return .fog
        case "partly_cloudy", "cloudy": return .leaves
        case "clear": return .none
        default: return nil
        }
    }

    static func isNight(for date: Date = Date()) -> Bool {
        // Simple heuristic: night between 8pm and 6am. Replace with real sunrise/sunset if available.
        let hour = Calendar.current.component(.hour, from: date)
        return hour >= 20 || hour < 6
    }
}

// MARK: - SwiftUI Wrappers

struct WeatherParticlesView: View {
    let weatherID: Int?
    let intensity: ParticleIntensity?

    var body: some View {
        SpriteView(scene: scene(), options: [.allowsTransparency])
            .ignoresSafeArea()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .background(Color.clear)
    }

    private func scene() -> SKScene {
        let kind = WeatherEffectMapping.effect(for: weatherID)
        return makeScene(kind: kind, intensity: intensity ?? .foreground)
    }
}

struct StarfieldBackgroundView: View {
    let isNight: Bool

    var body: some View {
        Group {
            if isNight {
                SpriteView(scene: StarfieldScene.make(), options: [.allowsTransparency])
                    .ignoresSafeArea()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .background(Color.clear)
            }
        }
        .accessibilityHidden(true)
    }
}

// MARK: - Scene Factory and Intensity

enum ParticleIntensity {
    case background // denser, more visible
    case foreground // sparse overlay
}

private func makeScene(kind: WeatherEffectKind, intensity: ParticleIntensity) -> SKScene {
    switch kind {
    case .none:
        return EmptyWeatherScene.make()
    case .rain(let light):
        return RainScene.make(light: light, intensity: intensity)
    case .snow:
        return SnowScene.make(intensity: intensity)
    case .fog:
        return FogScene.make(intensity: intensity)
    case .leaves:
        return LeavesScene.make(intensity: intensity)
    case .thunderstorm:
        // Compose rain; lightning will be an overlay handled within the scene
        return ThunderstormScene.make(intensity: intensity)
    }
}

// MARK: - Empty scene placeholder

final class EmptyWeatherScene: SKScene {
    override func didMove(to view: SKView) {
        backgroundColor = .clear
        scaleMode = .resizeFill
        isUserInteractionEnabled = false
    }

    static func make() -> SKScene {
        let s = EmptyWeatherScene()
        s.backgroundColor = .clear
        s.scaleMode = .resizeFill
        return s
    }
}

// - MARK: Previews

#Preview("Empty Scene") {
    SpriteView(scene: EmptyWeatherScene.make(), options: [.allowsTransparency])
        .ignoresSafeArea()
        .background(Color.clear)
}

#Preview("Rain - Light (Foreground)") {
    let scene = RainScene.make(light: true, intensity: .foreground)
    if let skScene = scene as? SKScene {
        skScene.scaleMode = .resizeFill
    }
    return SpriteView(scene: scene, options: [.allowsTransparency])
        .ignoresSafeArea()
        .background(Color.clear)
}

#Preview("Rain - Heavy (Background)") {
    let scene = RainScene.make(light: false, intensity: .background)
    if let skScene = scene as? SKScene {
        skScene.scaleMode = .resizeFill
    }
    return SpriteView(scene: scene, options: [.allowsTransparency])
        .ignoresSafeArea()
        .background(Color.clear)
}

#Preview("Snow") {
    let scene = SnowScene.make(intensity: .background)
    if let skScene = scene as? SKScene {
        skScene.scaleMode = .resizeFill
    }
    return SpriteView(scene: scene, options: [.allowsTransparency])
}

#Preview("Fog") {
    let scene = FogScene.make(intensity: .background)
    if let skScene = scene as? SKScene {
        skScene.scaleMode = .resizeFill
    }
    return SpriteView(scene: scene, options: [.allowsTransparency])
        .ignoresSafeArea()
        .background(Color.clear)
}

#Preview("Leaves") {
    let scene = LeavesScene.make(intensity: .background)
    if let skScene = scene as? SKScene {
        skScene.scaleMode = .resizeFill
    }
    return SpriteView(scene: scene, options: [.allowsTransparency])
        .ignoresSafeArea()
        .background(Color.clear)
}

#Preview("Thunderstorm") {
    let scene = ThunderstormScene.make(intensity: .background)
    if let skScene = scene as? SKScene {
        skScene.scaleMode = .resizeFill
    }
    return SpriteView(scene: scene, options: [.allowsTransparency])
        .ignoresSafeArea()
        .background(Color.clear)
}

#Preview("Starfield (Night)") {
    SpriteView(scene: StarfieldScene.make(), options: [.allowsTransparency])
        .ignoresSafeArea()
        .background(Color.clear)
}
