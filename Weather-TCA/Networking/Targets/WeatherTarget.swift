//
//  WeatherTarget.swift
//  Weather-TCA
//
//  Created by 민경준 on 8/20/26.
//

import Moya

enum WeatherTarget {
    case current(coord: Locality.Coordinate)
    case forecast(coord: Locality.Coordinate)
}

extension WeatherTarget: MoyaTarget {
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
                "appid": "825364e6c96d79c5c7f65e4bb2130762"
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
                "appid": "825364e6c96d79c5c7f65e4bb2130762"
            ]
            
            return .requestParameters(
                parameters: parameters,
                encoding: URLEncoding.queryString
            )
        }
    }
}
