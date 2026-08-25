//
//  Weather.swift
//  Weather-TCA
//
//  Created by 민경준 on 8/20/26.
//

import Foundation

/// OpenWeatherMap "Current Weather Data" API 응답 모델
/// https://openweathermap.org/current
struct Weather: Decodable {
    struct Coordinate: Decodable {
        let lng: Double
        let lat: Double
        
        enum CodingKeys: String, CodingKey {
            case lng = "lon"
            case lat
        }
    }

    struct Condition: Decodable {
        let id: Int
        let main: String
        let description: String
        let icon: String
    }

    struct Info: Decodable {
        let temp: Double
        let pressure: Int
        let humidity: Int
        let tempMin: Double
        let tempMax: Double

        enum CodingKeys: String, CodingKey {
            case temp, pressure, humidity
            case tempMin = "temp_min"
            case tempMax = "temp_max"
        }
    }

    struct Wind: Decodable {
        let speed: Double
        let deg: Int
    }

    struct Clouds: Decodable {
        let all: Int
    }

    struct System: Decodable {
        let country: String?
        let sunriseTimestamp: Int
        let sunsetTimestamp: Int

        enum CodingKeys: String, CodingKey {
            case country
            case sunriseTimestamp = "sunrise"
            case sunsetTimestamp = "sunset"
        }

        var sunrise: Date {
            Date(timeIntervalSince1970: TimeInterval(sunriseTimestamp))
        }

        var sunset: Date {
            Date(timeIntervalSince1970: TimeInterval(sunsetTimestamp))
        }
    }

    let coordinate: Coordinate
    let condition: [Condition]
    let info: Info
    let visibility: Int
    let wind: Wind
    let clouds: Clouds
    let dtTimestamp: Int
    let system: System
    let id: Int
    let name: String
    let cod: Int

    enum CodingKeys: String, CodingKey {
        case visibility, wind, clouds, id, name, cod
        case system = "sys"
        case info = "main"
        case coordinate = "coord"
        case condition = "weather"
        case dtTimestamp = "dt"
    }

    /// 관측 시각 (dt를 Date로 변환)
    var observedAt: Date {
        Date(timeIntervalSince1970: TimeInterval(dtTimestamp))
    }
}
