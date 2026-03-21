import SwiftUI

struct ForecastView: View {
    let day: String
    let icon: String
    let temperature: String
    let isFahrenheit: Bool
    let isSelected: Bool
    var tintColor: Color?

    // Layout constants mirrored from FourDayView
    private let cornerRadius: CGFloat = 14
    private let cardWidth: CGFloat = 80

    var body: some View {
        VStack(spacing: 8) {
            Text(day)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
            Image(systemName: icon)
                .symbolRenderingMode(.hierarchical)
                .font(.title2)
                .frame(height: 24)
                .foregroundStyle(isSelected ? .primary : .secondary)
                .contentTransition(.symbolEffect)
            Text(formattedTemp)
                .font(.headline)
                .monospacedDigit()
        }
        .padding(.vertical, 12)
        .frame(width: cardWidth)
        .background(
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(tintColor?.opacity(0.3) ?? Color.clear)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius))
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(isSelected ? Color.accentColor.opacity(0.2) : Color.clear)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(isSelected ? Color.accentColor : Color.white.opacity(0.3), lineWidth: isSelected ? 2 : 1)
                )
                .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
        )
        .scaleEffect(isSelected ? 1.03 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }

    private var formattedTemp: String {
        // If incoming temperature already includes a degree symbol, respect it
        if temperature.contains("°") { return temperature }
        if isFahrenheit {
            return "\(temperature)°F"
        } else {
            return "\(temperature)°C"
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        ForecastView(day: "Mon", icon: "cloud.fill", temperature: "28", isFahrenheit: false, isSelected: false, tintColor: TimeOfDay.dominantColor())
        ForecastView(day: "Tue", icon: "sun.max.fill", temperature: "75", isFahrenheit: true, isSelected: true, tintColor: TimeOfDay.dominantColor())
    }
    .padding()
}
