//
//  WeatherAdapter.swift
//  Weather-TCA
//
//  Created by 민경준 on 8/20/26.
//

import ComposableArchitecture

struct WeatherAdapter {
    var fetchCurrentWeather: (String) async throws -> Weather
}

extension WeatherAdapter: DependencyKey {
    static var liveValue: WeatherAdapter {
        return .init(
            fetchCurrentWeather: { city in
                try await NetworkClient.shared.codable(
                    WeatherTarget.current(city: city)
                )
            }
        )
    }
    
    static var previewValue: WeatherAdapter {
        return .init(
            fetchCurrentWeather: { city in
                return .init(
                    coordinate: .init(lng: 126.98, lat: 37.57),
                    condition: [
                        .init(
                            id: 800,
                            main: "Clear",
                            description: "clear sky",
                            icon: "01d"
                        )
                    ],
                    info: .init(
                        temp: 22.0,
                        pressure: 1013,
                        humidity: 55,
                        tempMin: 20.0,
                        tempMax: 24.0
                    ),
                    visibility: 10000,
                    wind: .init(speed: 2.1, deg: 120),
                    clouds: .init(all: 0),
                    dtTimestamp: 1_700_000_000,
                    system: .init(
                        country: "KR",
                        sunriseTimestamp: 1_699_970_000,
                        sunsetTimestamp: 1_700_010_000
                    ),
                    id: 1835848,
                    name: "Seoul",
                    cod: 200
                )
            }
        )
    }
}


extension DependencyValues {
    var weatherAdapter: WeatherAdapter {
        get { self[WeatherAdapter.self] }
        set { self[WeatherAdapter.self] = newValue }
    }
}
