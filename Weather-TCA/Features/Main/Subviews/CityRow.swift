//
//  CityRow.swift
//  Weather-TCA
//
//  Created by 민경준 on 8/27/26.
//

import SwiftUI

struct CityRow: View {
    let city: Main.Target
    
    var time: String {
        guard let date = city.weather?.date else {
            return ""
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        return formatter.string(from: date)
    }
    var temp: String {
        guard let temp = city.weather?.info.temp else {
            return ""
        }
        
        let intValue = Int(temp)
        return String(intValue)
    }
    var description: String {
        guard let weather = city.weather, let condition = weather.condition.first else {
            return ""
        }
        
        return condition.description
    }
    var min: String {
        guard let temp = city.weather?.info.tempMin else {
            return ""
        }
        
        let intValue = Int(temp)
        return String(intValue)
    }
    var max: String {
        guard let temp = city.weather?.info.tempMax else {
            return ""
        }
        
        let intValue = Int(temp)
        return String(intValue)
    }
    
    
    var body: some View {
        VStack(spacing: 20.0) {
            HStack {
                VStack(alignment: .leading) {
                    Text(city.locality.city)
                        .font(
                            .system(size: 25, weight: .bold)
                        )
                    Text(time)
                        .font(
                            .system(size: 20, weight: .semibold)
                        )
                }
                Spacer()
                
                Text("\(temp)°")
                    .font(
                        .system(size: 50, weight: .semibold)
                    )
            }
            
            HStack {
                Text(description)
                Spacer()
                
                HStack(spacing: 5.0) {
                    Text("최고: \(max)°")
                    Text("최저: \(min)°")
                }
            }
        }
        .foregroundStyle(.white)
        .padding(.horizontal)
        .padding(.vertical)
        .background(
            LinearGradient(
                colors: gradientColors(for: city.weather),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(
            RoundedRectangle(cornerRadius: 10.0)
        )
    }
    
    func gradientColors(for weather: Weather?) -> [Color] {
        guard let condition = weather?.condition.first else { return [.gray, .gray.opacity(0.7)] }
        let isNight = condition.icon.hasSuffix("n")

        switch condition.id {
        case 200...599: return isNight ? [.indigo, .black.opacity(0.8)] : [.blue.opacity(0.7), .gray]
        case 600...699: return [.gray.opacity(0.6), .white.opacity(0.8)]
        case 800: return isNight ? [.indigo, .black] : [.cyan, .blue]
        case 801...804: return isNight ? [.gray.opacity(0.7), .black.opacity(0.7)] : [.blue.opacity(0.5), .gray.opacity(0.6)]
        default: return [.blue, .gray]
        }
    }
}


#Preview {
    CityRow(
        city: .init(
            locality: .seoul,
            weather: .mock,
            forecast: .mock
        )
    )
}
