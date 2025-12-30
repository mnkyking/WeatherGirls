import SwiftUI

struct WeekView: View {
    let forecasts: [WeatherDataModel]
    @Binding var selectedIndex: Int
    let isFahrenheit: Bool

    // Layout constants
    private let cornerRadius: CGFloat = 14
    private let cardWidth: CGFloat = 80

    var body: some View {
        GeometryReader { geo in
            let cappedForecasts = Array(forecasts.prefix(7))
            let spacing: CGFloat = 12
            let count = cappedForecasts.count
            let totalWidth = CGFloat(max(count, 0)) * cardWidth + CGFloat(max(count - 1, 0)) * spacing

            Group {
                if forecasts.isEmpty {
                    EmptyState()
                } else if totalWidth <= geo.size.width {
                    // Content fits: center it without scrolling
                    HStack(spacing: spacing) {
                        ForEach(Array(cappedForecasts.enumerated()), id: \.offset) { index, item in
                            ForecastView(day: item.day, icon: item.sfSymbolName, temperature: convertedTemperatureString(item: item), isFahrenheit: isFahrenheit, isSelected: selectedIndex == index)
                                .onTapGesture { select(index: index) }
                                .accessibilityElement(children: .ignore)
                                .accessibilityLabel(accessibilityLabel(for: item, index: index))
                                .accessibilityAddTraits(selectedIndex == index ? [.isSelected, .isButton] : [.isButton])
                                .accessibilityAction(named: Text("Select")) { select(index: index) }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 20)
                } else {
                    // Too wide: allow horizontal scrolling
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: spacing) {
                            ForEach(Array(cappedForecasts.enumerated()), id: \.offset) { index, item in
                                ForecastView(day: item.day, icon: item.sfSymbolName, temperature: convertedTemperatureString(item: item), isFahrenheit: isFahrenheit, isSelected: selectedIndex == index)
                                    .onTapGesture { select(index: index) }
                                    .accessibilityElement(children: .ignore)
                                    .accessibilityLabel(accessibilityLabel(for: item, index: index))
                                    .accessibilityAddTraits(selectedIndex == index ? [.isSelected, .isButton] : [.isButton])
                                    .accessibilityAction(named: Text("Select")) { select(index: index) }
                            }
                        }
                        .padding(EdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20))
                    }
                }
            }
            .frame(width: geo.size.width, height: geo.size.height, alignment: .bottom)
        }
        .frame(height: 120, alignment: .bottom)
        .padding(.bottom, 20)
    }

    private func formattedTemp(_ item: WeatherDataModel) -> String {
        let value = item.temperature
        if item.isFahrenheit {
            return "\(value)°F"
        } else {
            return "\(value)°C"
        }
    }
    
    private func convertedTemperatureString(item: WeatherDataModel) -> String {
        guard let value = Double(item.temperature) else { return item.temperature }
        if item.isFahrenheit == isFahrenheit { return String(Int(round(value))) }
        if isFahrenheit {
            // C -> F
            let f = value * 9.0 / 5.0 + 32.0
            return String(Int(round(f)))
        } else {
            // F -> C
            let c = (value - 32.0) * 5.0 / 9.0
            return String(Int(round(c)))
        }
    }

    private func accessibilityLabel(for item: WeatherDataModel, index: Int) -> Text {
        let temp = formattedTemp(item)
        let selectedText = selectedIndex == index ? ", selected" : ""
        return Text("\(item.day), \(temp)\(selectedText)")
    }

    private func select(index: Int) {
        guard index >= 0 && index < min(forecasts.count, 7) else { return }
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
    @Previewable @State var selected: Int = 0
    WeekView(
        forecasts: [
            WeatherDataModel(day: "Mon", temperature: "28", openWeatherIconCode: "03d", weatherID: 800, isFahrenheit: false, condition: "Cloudy"),
            WeatherDataModel(day: "Tue", temperature: "30", openWeatherIconCode: "10d", weatherID: 200, isFahrenheit: false, condition: "Cloudy with Rain"),
            WeatherDataModel(day: "Wed", temperature: "26", openWeatherIconCode: "01d", weatherID: 300, isFahrenheit: false, condition: "Sunny"),
            WeatherDataModel(day: "Thu", temperature: "27", openWeatherIconCode: "03d", weatherID: 400, isFahrenheit: false, condition: "Cloudy"),
            WeatherDataModel(day: "Fri", temperature: "27", openWeatherIconCode: "03d", weatherID: 400, isFahrenheit: false, condition: "Cloudy")
        ],
        selectedIndex: $selected,
        isFahrenheit: false
    )
    .padding()
}
