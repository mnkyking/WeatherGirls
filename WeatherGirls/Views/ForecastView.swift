import SwiftUI

struct ForecastView: View {
    let day: String
    let icon: String
    let temperature: String
    let isFahrenheit: Bool
    let isSelected: Bool

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
                .fill(isSelected ? Color.accentColor.opacity(0.15) : Color.secondary.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(isSelected ? Color.accentColor : Color.secondary.opacity(0.2), lineWidth: isSelected ? 1.5 : 1)
                )
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
        ForecastView(day: "Mon", icon: "cloud.fill", temperature: "28", isFahrenheit: false, isSelected: false)
        ForecastView(day: "Tue", icon: "sun.max.fill", temperature: "75", isFahrenheit: true, isSelected: true)
    }
    .padding()
}
