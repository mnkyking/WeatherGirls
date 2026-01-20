import SwiftUI

// MARK: - Semantic App Colors
struct AppColors: Equatable {
    // Core semantic colors used throughout the app
    var background: Color
    var surface: Color
    var primaryText: Color
    var secondaryText: Color
    var accent: Color
    var accentVariant: Color
    var warning: Color
    var success: Color
    var separator: Color
}

// MARK: - Theme container
struct AppTheme: Equatable {
    var light: AppColors
    var dark: AppColors

    // Resolve a color by scheme
    func colors(for scheme: ColorScheme) -> AppColors {
        scheme == .dark ? dark : light
    }
}

// MARK: - Default Vibrant Theme
extension AppTheme {
    static let vibrant = AppTheme(
        light: AppColors(
            background: Color(red: 0.97, green: 0.98, blue: 1.00),            // Soft sky tint
            surface: Color.white.opacity(0.85),                               // Translucent card over art
            primaryText: Color(red: 0.08, green: 0.12, blue: 0.18),           // Deep navy for contrast
            secondaryText: Color(red: 0.28, green: 0.36, blue: 0.48),         // Muted blue-gray
            accent: Color(red: 0.05, green: 0.56, blue: 0.98),                // Bright sky blue
            accentVariant: Color(red: 0.00, green: 0.72, blue: 0.83),         // Aqua/teal
            warning: Color(red: 1.00, green: 0.55, blue: 0.20),               // Warm orange
            success: Color(red: 0.22, green: 0.75, blue: 0.35),               // Fresh green
            separator: Color.black.opacity(0.08)
        ),
        dark: AppColors(
            background: Color(red: 0.05, green: 0.08, blue: 0.14),            // Deep indigo/space
            surface: Color(red: 0.11, green: 0.14, blue: 0.20).opacity(0.75), // Translucent card
            primaryText: Color.white,                                         // High contrast text
            secondaryText: Color(red: 0.76, green: 0.82, blue: 0.92),         // Cool light blue
            accent: Color(red: 0.28, green: 0.68, blue: 1.00),                // Electric blue
            accentVariant: Color(red: 0.18, green: 0.85, blue: 0.88),         // Cyan/teal
            warning: Color(red: 1.00, green: 0.60, blue: 0.35),               // Softer orange
            success: Color(red: 0.38, green: 0.86, blue: 0.52),               // Vivid green
            separator: Color.white.opacity(0.10)
        )
    )
}

// MARK: - Environment support
private struct AppThemeKey: EnvironmentKey {
    static let defaultValue: AppTheme = .vibrant
}

extension EnvironmentValues {
    var appTheme: AppTheme {
        get { self[AppThemeKey.self] }
        set { self[AppThemeKey.self] = newValue }
    }
}

// MARK: - View helpers
extension View {
    func appTheme(_ theme: AppTheme) -> some View {
        environment(\.appTheme, theme)
    }

    // Convenience surface styling for cards/overlays
    func surfaceStyle(_ colors: AppColors) -> some View {
        self
            .background(colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

// MARK: - Color access helper
struct ThemedColors {
    let colors: AppColors

    init(_ scheme: ColorScheme, theme: AppTheme) {
        self.colors = theme.colors(for: scheme)
    }
}
