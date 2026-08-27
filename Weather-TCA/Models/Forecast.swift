//
//  Forecast.swift
//  Weather-TCA
//
//  Created by 민경준 on 8/27/26.
//

import Foundation

/// OpenWeatherMap "5 Day / 3 Hour Forecast" API 응답 모델
/// https://docs.openweather.co.uk/forecast5
///
/// 3시간 간격으로 최대 5일치(40개) 항목을 준다.
struct Forecast: Decodable, Equatable {
    struct Info: Decodable, Equatable {
        let temp: Double
        let feelsLike: Double
        let tempMin: Double
        let tempMax: Double
        let pressure: Int
        let humidity: Int

        enum CodingKeys: String, CodingKey {
            case temp, pressure, humidity
            case feelsLike = "feels_like"
            case tempMin = "temp_min"
            case tempMax = "temp_max"
        }
    }

    struct Wind: Decodable, Equatable {
        let speed: Double
        let deg: Int
        let gust: Double?
    }

    struct Clouds: Decodable, Equatable {
        let all: Int
    }

    struct Condition: Decodable, Equatable {
        let id: Int
        let main: String
        let description: String
        let icon: String
    }

    struct System: Decodable, Equatable {
        /// "d"(주간) 또는 "n"(야간)
        let pod: String
    }

    struct Item: Decodable, Equatable {
        let dtTimestamp: Int
        let info: Info
        let condition: [Condition]
        let clouds: Clouds
        let wind: Wind
        let visibility: Int
        /// 강수 확률 (0.0 ~ 1.0)
        let pop: Double
        let system: System
        /// "2022-08-30 15:00:00" 형식의 사람이 읽기 쉬운 시각 문자열
        let dtText: String

        enum CodingKeys: String, CodingKey {
            case info = "main"
            case condition = "weather"
            case clouds, wind, visibility, pop
            case system = "sys"
            case dtTimestamp = "dt"
            case dtText = "dt_txt"
        }

        var date: Date {
            Date(timeIntervalSince1970: TimeInterval(dtTimestamp))
        }
    }

    struct City: Decodable, Equatable {
        struct Coordinate: Decodable, Equatable {
            let lat: Double
            let lon: Double
        }

        let id: Int
        let name: String
        let coordinate: Coordinate
        let country: String
        let timezone: Int
        let sunriseTimestamp: Int
        let sunsetTimestamp: Int

        enum CodingKeys: String, CodingKey {
            case id, name, country, timezone
            case coordinate = "coord"
            case sunriseTimestamp = "sunrise"
            case sunsetTimestamp = "sunset"
        }
    }

    let list: [Item]
    let city: City

    // 이 API의 "cod"는 "200"처럼 문자열로 내려온다.
    // (Weather 모델의 cod는 Int였던 것과 다르다.)
    let cod: String
}
