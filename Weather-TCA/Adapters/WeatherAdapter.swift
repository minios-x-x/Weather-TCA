//
//  WeatherAdapter.swift
//  Weather-TCA
//
//  Created by 민경준 on 8/20/26.
//

import ComposableArchitecture

struct WeatherAdapter {
    var fetchCurrentWeather: (Locality.Coordinate) async throws -> Weather
    var fetchCurrentForecast: (Locality.Coordinate) async throws -> Forecast
}

extension WeatherAdapter: DependencyKey {
    static var liveValue: WeatherAdapter {
        return .init(
            fetchCurrentWeather: { coord in
                try await NetworkClient.shared.codable(
                    WeatherTarget.current(coord: coord)
                )
            },
            fetchCurrentForecast: { coord in
                try await NetworkClient.shared.codable(
                    WeatherTarget.forecast(coord: coord)
                )
            }
        )
    }
    
    static var previewValue: WeatherAdapter {
        return .init(
            fetchCurrentWeather: { coord in
                return .mock
            },
            fetchCurrentForecast: { coord in
                return .mock
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
