//
//  Weather.swift
//  Weather-TCA
//
//  Created by 민경준 on 8/20/26.
//

import Foundation

/// OpenWeatherMap "Current Weather Data" API 응답 모델
/// https://openweathermap.org/current
struct Weather: Decodable, Equatable, Identifiable {
    struct Coordinate: Decodable, Equatable {
        let lng: Double
        let lat: Double
        
        enum CodingKeys: String, CodingKey {
            case lng = "lon"
            case lat
        }
    }

    struct Condition: Decodable, Equatable {
        let id: Int
        let main: String
        let description: String
        let icon: String
    }

    struct Info: Decodable, Equatable {
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

    struct Wind: Decodable, Equatable {
        let speed: Double
        let deg: Int
        
        var direction: String {
            let directions = ["북", "북동", "동", "남동", "남", "남서", "서", "북서"]
            let index = Int((Double(deg) / 45).rounded()) % 8
            return directions[index]
        }
    }

    struct Clouds: Decodable, Equatable {
        let all: Int
    }

    struct System: Decodable, Equatable {
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
    
    static let mock: Weather = .init(
        coordinate: .init(
            lng: 126.9778,
            lat: 37.5683
        ),
        condition: [
            .init(
                id: 802,
                main: "Clouds",
                description: "구름조금",
                icon: "09d"
            )
        ],
        info: .init(
            temp: 32.76,
            pressure: 1010,
            humidity: 62,
            tempMin: 32.76,
            tempMax: 32.78
        ),
        visibility: 10000,
        wind: .init(speed: 3.09, deg: 290),
        clouds: .init(all: 48),
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

