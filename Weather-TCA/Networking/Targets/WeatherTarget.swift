//
//  WeatherTarget.swift
//  Weather-TCA
//
//  Created by 민경준 on 8/20/26.
//

import Moya

enum WeatherTarget {
    case current(city: String)
}

extension WeatherTarget: MoyaTarget {
    var path: String {
        switch self {
        case .current:
            return "weather"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .current:
            return .get
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .current(let city):
            let parameters: [String: Any] = [
                "q": city,
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
