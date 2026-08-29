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


extension Forecast {
    /// 지금 시각 기준으로 24시간 이내에 해당하는 항목만 반환한다.
    var next24Hours: [Item] {
        let now = Date()
        let cutoff = now.addingTimeInterval(24 * 60 * 60)
        return list.filter { $0.date >= now && $0.date <= cutoff }
    }
}


extension Forecast {
    static let mock: Forecast = {
        let json = """
        {
            "cod": "200",
            "message": 0,
            "cnt": 2,
            "list": [
                {
                    "dt": 1787821200,
                    "main": {
                        "temp": 32.76,
                        "feels_like": 39.62,
                        "temp_min": 28.64,
                        "temp_max": 32.76,
                        "pressure": 1006,
                        "sea_level": 1006,
                        "grnd_level": 997,
                        "humidity": 62,
                        "temp_kf": 4.12,
                        "dew_point": 24.52
                    },
                    "weather": [
                        {
                            "id": 500,
                            "main": "Rain",
                            "description": "실 비",
                            "icon": "10d"
                        }
                    ],
                    "clouds": {
                        "all": 100
                    },
                    "wind": {
                        "speed": 2.19,
                        "deg": 264,
                        "gust": 2.62
                    },
                    "visibility": 10000,
                    "pop": 0.31,
                    "rain": {
                        "3h": 0.19
                    },
                    "sys": {
                        "pod": "d"
                    },
                    "dt_txt": "2026-08-27 09:00:00"
                },
                {
                    "dt": 1787832000,
                    "main": {
                        "temp": 30.92,
                        "feels_like": 36.52,
                        "temp_min": 27.24,
                        "temp_max": 30.92,
                        "pressure": 1007,
                        "sea_level": 1007,
                        "grnd_level": 998,
                        "humidity": 67,
                        "temp_kf": 3.68,
                        "dew_point": 24.07
                    },
                    "weather": [
                        {
                            "id": 500,
                            "main": "Rain",
                            "description": "실 비",
                            "icon": "10n"
                        }
                    ],
                    "clouds": {
                        "all": 100
                    },
                    "wind": {
                        "speed": 0.76,
                        "deg": 265,
                        "gust": 0.94
                    },
                    "visibility": 10000,
                    "pop": 0.74,
                    "rain": {
                        "3h": 0.93
                    },
                    "sys": {
                        "pod": "n"
                    },
                    "dt_txt": "2026-08-27 12:00:00"
                }
            ],
            "city": {
                "id": 1835848,
                "name": "Seoul",
                "coord": {
                    "lat": 37.5683,
                    "lon": 126.9778
                },
                "country": "KR",
                "population": 10349312,
                "timezone": 32400,
                "sunrise": 1787777869,
                "sunset": 1787825410
            }
        }
        """
 
        let data = Data(json.utf8)
        return try! JSONDecoder().decode(Forecast.self, from: data)
    }()
}
