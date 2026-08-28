//
//  HourlyCell.swift
//  Weather-TCA
//
//  Created by 민경준 on 8/28/26.
//

import SwiftUI

struct HourlyCell: View {
    let item: Forecast.Item
    
    var body: some View {
        VStack(spacing: 1.0) {
            Text("지금")
            WeatherSymbol(for: "10d")
                .frame(width: 50.0)
            Text("26°")
        }
    }
}


#Preview {
    HourlyCell(
        item: Forecast.mock.list[0]
    )
}

//{
//    "dt": 1787821200,
//    "main": {
//        "temp": 32.76,
//        "feels_like": 39.62,
//        "temp_min": 28.64,
//        "temp_max": 32.76,
//        "pressure": 1006,
//        "sea_level": 1006,
//        "grnd_level": 997,
//        "humidity": 62,
//        "temp_kf": 4.12,
//        "dew_point": 24.52
//    },
//    "weather": [
//        {
//            "id": 500,
//            "main": "Rain",
//            "description": "실 비",
//            "icon": "10d"
//        }
//    ],
//    "clouds": {
//        "all": 100
//    },
//    "wind": {
//        "speed": 2.19,
//        "deg": 264,
//        "gust": 2.62
//    },
//    "visibility": 10000,
//    "pop": 0.31,
//    "rain": {
//        "3h": 0.19
//    },
//    "sys": {
//        "pod": "d"
//    },
//    "dt_txt": "2026-08-27 09:00:00"
//}
