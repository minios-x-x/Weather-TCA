//
//  WeatherTarget.swift
//  Weather-TCA
//
//  Created by 민경준 on 8/20/26.
//

import Moya
import Foundation

enum WeatherTarget {
    case current(coord: Locality.Coordinate)
    case forecast(coord: Locality.Coordinate)
}

extension WeatherTarget: MoyaTarget {
    private var apiKey: String {
        Bundle.main.object(forInfoDictionaryKey: "OPENWEATHER_API_KEY") as? String ?? ""
    }
    
    var path: String {
        switch self {
        case .current:
            return "weather"
        case .forecast:
            return "forecast"
        }
    }
    
    var method: Moya.Method {
        switch self {
        default:
            return .get
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .forecast(let target):
            let parameters: [String: Any] = [
                "lat": target.lat,
                "lon": target.lng,
                "units": "metric",
                "lang": "kr",
                "appid": apiKey
            ]
            
            return .requestParameters(
                parameters: parameters,
                encoding: URLEncoding.queryString
            )
        case .current(let target):
            let parameters: [String: Any] = [
                "lat": target.lat,
                "lon": target.lng,
                "units": "metric",
                "lang": "kr",
                "appid": apiKey
            ]
            
            return .requestParameters(
                parameters: parameters,
                encoding: URLEncoding.queryString
            )
        }
    }
}
