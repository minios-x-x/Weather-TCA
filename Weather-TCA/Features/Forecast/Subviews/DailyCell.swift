//
//  DailyCell.swift
//  Weather-TCA
//
//  Created by 민경준 on 8/28/26.
//

import SwiftUI

struct DailyCell: View {
    let items: [Forecast.Item]
    
    var dayMin: Double {
        items.map(\.info.tempMin).min() ?? 0
    }
    var dayMax: Double {
        items.map(\.info.tempMax).max() ?? 0
    }
    
    private var dayLabel: Text {
        guard let date = items.first?.date else { return Text("") }
        if Calendar.current.isDateInToday(date) {
            return Text("오늘")
        }
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "EEEEE" // 한 글자 요일 (월, 화, 수...)
        return Text(formatter.string(from: date))
    }
    private var iconCode: String {
        items.first?.condition.first?.icon ?? ""
    }
    
    var body: some View {
        HStack(spacing: 0.0) {
            dayLabel
                .font(
                    .system(size: 20.0)
                )
            
            Spacer()
            WeatherSymbol(for: iconCode)
                .frame(width: 50.0, height: 50.0)
            
            Spacer()
            HStack {
                Text("\(Int(dayMin))°")
                    .font(
                        .system(size: 20.0)
                    )
                    .foregroundStyle(
                        Color.secondary
                    )
                TemperatureBar(
                    dayMin: dayMin,
                    dayMax: dayMax,
                    overallMin: 19.0,
                    overallMax: 35.0
                )
                .frame(width: 125.0)
                Text("\(Int(dayMax))°")
                    .font(
                        .system(size: 20.0)
                    )
            }
        }
        .frame(width: .infinity, alignment: .leading)
    }
}

#Preview {
    DailyCell(
        items: Forecast.mock.list
    )
}
