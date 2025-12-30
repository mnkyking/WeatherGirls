import SwiftUI

struct FourDayView: View {
    let forecasts: [WeatherDataModel]
    @Binding var selectedIndex: Int?

    // Layout constants
    private let cornerRadius: CGFloat = 14
    private let cardWidth: CGFloat = 80

    var body: some View {
        if forecasts.isEmpty {
            emptyState
        } else {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Array(forecasts.enumerated()), id: \.offset) { index, item in
                        dayCard(for: item, isSelected: selectedIndex == index)
                            .onTapGesture {
                                select(index: index)
                            }
                            .accessibilityElement(children: .ignore)
                            .accessibilityLabel(accessibilityLabel(for: item, index: index))
                            .accessibilityAddTraits(selectedIndex == index ? [.isSelected, .isButton] : [.isButton])
                            .accessibilityAction(named: Text("Select")) {
                                select(index: index)
                            }
                    }
                }
                .padding(.vertical, 8)
            }
        }
    }

    private var emptyState: some View {
        HStack(spacing: 8) {
            Image(systemName: "cloud.slash")
            Text("No forecast data")
        }
        .foregroundStyle(.secondary)
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.vertical, 12)
        .accessibilityLabel("No forecast data available")
    }

    private func dayCard(for item: WeatherDataModel, isSelected: Bool) -> some View {
        VStack(spacing: 8) {
            Text(item.day)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
            Image(systemName: item.icon)
                .symbolRenderingMode(.hierarchical)
                .font(.title2)
                .frame(height: 24)
                .foregroundStyle(isSelected ? .primary : .secondary)
                .contentTransition(.symbolEffect)
            Text(formattedTemp(item))
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

    private func formattedTemp(_ item: WeatherDataModel) -> String {
        let value = item.temperature
        if item.isFahrenheit {
            return "\(value)°F"
        } else {
            return "\(value)°C"
        }
    }

    private func accessibilityLabel(for item: WeatherDataModel, index: Int) -> Text {
        let temp = formattedTemp(item)
        let selectedText = selectedIndex == index ? ", selected" : ""
        return Text("\(item.day), \(temp)\(selectedText)")
    }

    private func select(index: Int) {
        guard index >= 0 && index < forecasts.count else { return }
        if selectedIndex != index {
            let generator = UISelectionFeedbackGenerator()
            generator.selectionChanged()
            withAnimation {
                selectedIndex = index
            }
        }
    }
}

#Preview {
    @Previewable @State var selected: Int? = 0
    FourDayView(
        forecasts: [
            WeatherDataModel(day: "Mon", temperature: "28", icon: "cloud.fill", isFahrenheit: false),
            WeatherDataModel(day: "Tue", temperature: "30", icon: "cloud.rain.fill", isFahrenheit: false),
            WeatherDataModel(day: "Wed", temperature: "26", icon: "sun.max.fill", isFahrenheit: false),
            WeatherDataModel(day: "Thu", temperature: "27", icon: "cloud.fill", isFahrenheit: false)
        ],
        selectedIndex: $selected
    )
    .padding()
}
