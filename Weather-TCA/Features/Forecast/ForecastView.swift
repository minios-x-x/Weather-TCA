//
//  ForecastView.swift
//  Weather-TCA
//
//  Created by 민경준 on 8/27/26.
//

import SwiftUI

struct ForecastContentView: View {
    init(_ content: Content) {
        self.content = content
    }
    
    struct Content {
        let locality: Locality
        let forecast: Forecast
        let weather: Weather
    }
    
    let content: Content
    
    private var dailyGroups: [(date: Date, items: [Forecast.Item])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: content.forecast.list) { item in
            calendar.startOfDay(for: item.date)
        }
        return grouped.keys.sorted().map { date in
            (date: date, items: grouped[date] ?? [])
        }
    }
    private var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [.blue, .cyan],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    private var temp: String {
        let intValue = Int(content.weather.info.temp)
        return String(intValue)
    }
    private var todayHighLow: (high: Double, low: Double) {
        let todayItems = content.forecast.list.filter {
            Calendar.current.isDateInToday($0.date)
        }
        
        var highs = todayItems.map(\.info.tempMax)
        var lows = todayItems.map(\.info.tempMin)
        
        highs.append(content.weather.info.tempMax)
        lows.append(content.weather.info.tempMin)
        
        
        guard let high = highs.max(), let low = lows.min() else {
            return (0, 0)
        }
        return (high, low)
    }
    
    
    private var tempMin: String {
        let intValue = Int(todayHighLow.low)
        return String(intValue)
    }
    private var tempMax: String {
        let intValue = Int(todayHighLow.high)
        return String(intValue)
    }
    private var description: String {
        content.weather.condition.first?.description ?? ""
    }
    
    
    var body: some View {
        ZStack(alignment: .top) {
            backgroundGradient
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 15.0) {
                    VStack(spacing: 0.0) {
                        VStack(spacing: -15.0) {
                            Text(content.locality.city)
                                .font(
                                    .system(
                                        size: 35,
                                        weight: .regular
                                    )
                                )
                            Text("\(temp)°")
                                .font(
                                    .system(
                                        size: 100,
                                        weight: .regular
                                    )
                                )
                        }
                        Text(description)
                            .font(
                                .system(
                                    size: 25,
                                    weight: .regular
                                )
                            )
                        HStack {
                            Text("최저: \(tempMin)°")
                            Text("최저: \(tempMax)°")
                        }
                        .font(
                            .system(
                                size: 25,
                                weight: .regular
                            )
                        )
                    }
                    .foregroundStyle(.white)
                    .padding(.vertical, 50.0)
                    
                    ForecastCard {
                        Rectangle()
                            .frame(height: 0.5)
                            .foregroundStyle(Color.secondary)
                        ScrollView(.horizontal) {
                            HStack {
                                ForEach(content.forecast.next24Hours, id: \.dtTimestamp) { info in
                                    HourlyCell(item: info)
                                }
                            }
                        }
                        .padding(.vertical)
                        .scrollIndicators(.hidden)
                    } headerView: {
                        Image(systemName: "clock")
                            .resizable()
                            .frame(width: 15.0, height: 15.0)
                        Text("시간별 일기예보")
                            .font(
                                .system(
                                    size: 15,
                                    weight: .regular
                                )
                            )
                    }
                    
                    ForecastCard {
                        ForEach(dailyGroups, id: \.date) { group in
                            Rectangle()
                                .frame(height: 0.5)
                                .foregroundStyle(Color.secondary)
                            DailyCell(
                                items: group.items
                            )
                        }
                    } headerView: {
                        Image(systemName: "calendar")
                            .resizable()
                            .frame(width: 15.0, height: 15.0)
                        Text("5일간의 일기예보")
                            .font(
                                .system(
                                    size: 15,
                                    weight: .regular
                                )
                            )
                    }
                    
                }
                
                Color.clear
                    .frame(height: 50.0)
            }
            .scrollIndicators(.hidden)
        }
    }
}

struct ForecastFullScreenView: View {
    init(_ content: ForecastContentView.Content) {
        self.content = content
    }
    
    let content: ForecastContentView.Content
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ForecastContentView(content)
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    Spacer()
                }
                ToolbarItem(placement: .bottomBar) {
                    Spacer()
                }
                ToolbarItem(placement: .bottomBar) {
                    Image(systemName: "list.bullet")
                        .onTapGesture { dismiss() }
                }
            }
            .toolbarBackgroundVisibility(
                .visible,
                for: .bottomBar
            )
            .toolbarBackground(
                .ultraThinMaterial,
                for: .bottomBar
            )
        }
    }
}

struct ForecastSheetView: View {
    init(_ content: ForecastContentView.Content) {
        self.content = content
    }
    
    let content: ForecastContentView.Content
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ForecastContentView(content)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Text("취소")
                            .foregroundStyle(.white)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        
                    } label: {
                        Text("추가")
                            .foregroundStyle(.white)
                    }
                }
            }
            .toolbarBackground(.clear, for: .navigationBar)
            .toolbarBackgroundVisibility(.hidden, for: .navigationBar)
            
        }
    }
}
