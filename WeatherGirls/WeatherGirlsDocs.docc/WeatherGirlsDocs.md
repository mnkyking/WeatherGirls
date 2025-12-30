# ``WeatherGirls``

Learn the possible weather conditions returned by the OpenWeather “Current Weather” API and how they relate to icon codes you may use for mapping to SF Symbols.

## Overview

Each `weather` item in the response includes:
- `id`: Numeric condition code
- `main`: Group of weather parameters (e.g., “Rain”)
- `description`: Condition within the group (e.g., “light rain”)
- `icon`: Icon code (e.g., “10d”, “01n”)

You can map `icon` prefixes (01–50) or use specific `id` values for more precise symbol selection.

## Condition Groups and Codes

### Thunderstorm (2xx)
- 200: Thunderstorm with light rain
- 201: Thunderstorm with rain
- 202: Thunderstorm with heavy rain
- 210: Light thunderstorm
- 211: Thunderstorm
- 212: Heavy thunderstorm
- 221: Ragged thunderstorm
- 230: Thunderstorm with light drizzle
- 231: Thunderstorm with drizzle
- 232: Thunderstorm with heavy drizzle

### Drizzle (3xx)
- 300: Light intensity drizzle
- 301: Drizzle
- 302: Heavy intensity drizzle
- 310: Light intensity drizzle rain
- 311: Drizzle rain
- 312: Heavy intensity drizzle rain
- 313: Shower rain and drizzle
- 314: Heavy shower rain and drizzle
- 321: Shower drizzle

### Rain (5xx)
- 500: Light rain
- 501: Moderate rain
- 502: Heavy intensity rain
- 503: Very heavy rain
- 504: Extreme rain
- 511: Freezing rain
- 520: Light intensity shower rain
- 521: Shower rain
- 522: Heavy intensity shower rain
- 531: Ragged shower rain

### Snow (6xx)
- 600: Light snow
- 601: Snow
- 602: Heavy snow
- 611: Sleet
- 612: Light shower sleet
- 613: Shower sleet
- 615: Light rain and snow
- 616: Rain and snow
- 620: Light shower snow
- 621: Shower snow
- 622: Heavy shower snow

### Atmosphere (7xx)
- 701: Mist
- 711: Smoke
- 721: Haze
- 731: Sand/dust whirls
- 741: Fog
- 751: Sand
- 761: Dust
- 762: Volcanic ash
- 771: Squalls
- 781: Tornado

### Clear (800)
- 800: Clear sky

### Clouds (80x)
- 801: Few clouds (11–25%)
- 802: Scattered clouds (25–50%)
- 803: Broken clouds (51–84%)
- 804: Overcast clouds (85–100%)

## Icon Codes (Day/Night Variants)

- 01d / 01n: Clear sky
- 02d / 02n: Few clouds
- 03d / 03n: Scattered clouds
- 04d / 04n: Broken/overcast clouds
- 09d / 09n: Shower rain / drizzle
- 10d / 10n: Rain
- 11d / 11n: Thunderstorm
- 13d / 13n: Snow
- 50d / 50n: Mist/fog/haze (atmosphere)

## Mapping Tips

- For a quick mapping, use the `icon` prefix (e.g., `01`, `02`, … `50`) to choose an SF Symbol such as:
  - 01 → `sun.max.fill`
  - 02 → `cloud.sun.fill`
  - 03 → `cloud.fill`
  - 04 → `smoke.fill`
  - 09 → `cloud.drizzle.fill`
  - 10 → `cloud.rain.fill`
  - 11 → `cloud.bolt.rain.fill`
  - 13 → `snowflake`
  - 50 → `cloud.fog.fill`
- For more precision, branch on `id` ranges or specific IDs (e.g., `511` → freezing rain, `781` → tornado) and pick a more exact symbol.

## See Also
- OpenWeather API docs: Current Weather endpoint
- Your code: `mapIcon(from:)` in `ContentView.swift`

