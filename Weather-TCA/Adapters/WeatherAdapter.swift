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
