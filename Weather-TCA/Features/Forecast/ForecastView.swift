//
//  ForecastView.swift
//  Weather-TCA
//
//  Created by 민경준 on 8/27/26.
//

import SwiftUI

struct ForecastView: View {
    @State private var scrollOffset: CGFloat = 0.0
    
    private var headerHeight: CGFloat {
        max(90.0, 220.0 - scrollOffset)
    }
    
    private var isHeaderCollapsed: Bool {
        220.0 - scrollOffset <= 90.0
    }
    
    @Environment(\.dismiss) private var dismiss
    
    
    private var backgroundGradient: LinearGradient {
        LinearGradient(colors: [.blue, .cyan], startPoint: .top, endPoint: .bottom)
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                backgroundGradient
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 15.0) {
                        VStack(spacing: 0.0) {
                            VStack(spacing: -15.0) {
                                Text("서울특별시")
                                    .font(
                                        .system(
                                            size: 35,
                                            weight: .regular
                                        )
                                    )
                                Text("27")
                                    .font(
                                        .system(
                                            size: 100,
                                            weight: .regular
                                        )
                                    )
                            }
                            Text("이슬비")
                                .font(
                                    .system(
                                        size: 25,
                                        weight: .regular
                                    )
                                )
                            HStack {
                                Text("최저: 29")
                                Text("최저: 25")
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
                                    HourlyCell(item: Forecast.mock.list[0])
                                    HourlyCell(item: Forecast.mock.list[0])
                                    HourlyCell(item: Forecast.mock.list[0])
                                    HourlyCell(item: Forecast.mock.list[0])
                                    HourlyCell(item: Forecast.mock.list[0])
                                    HourlyCell(item: Forecast.mock.list[0])
                                    HourlyCell(item: Forecast.mock.list[0])
                                    HourlyCell(item: Forecast.mock.list[0])
                                    HourlyCell(item: Forecast.mock.list[0])
                                    HourlyCell(item: Forecast.mock.list[0])
                                    HourlyCell(item: Forecast.mock.list[0])
                                    HourlyCell(item: Forecast.mock.list[0])
                                    HourlyCell(item: Forecast.mock.list[0])
                                    HourlyCell(item: Forecast.mock.list[0])
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
                            Rectangle()
                                .frame(height: 0.5)
                                .foregroundStyle(Color.secondary)
                            DailyCell(
                                items: Forecast.mock.list
                            )
                            
                            Rectangle()
                                .frame(height: 0.5)
                                .foregroundStyle(Color.secondary)
                            DailyCell(
                                items: Forecast.mock.list
                            )
                            
                            Rectangle()
                                .frame(height: 0.5)
                                .foregroundStyle(Color.secondary)
                            DailyCell(
                                items: Forecast.mock.list
                            )
                            
                            Rectangle()
                                .frame(height: 0.5)
                                .foregroundStyle(Color.secondary)
                            DailyCell(
                                items: Forecast.mock.list
                            )
                            
                            Rectangle()
                                .frame(height: 0.5)
                                .foregroundStyle(Color.secondary)
                            DailyCell(
                                items: Forecast.mock.list
                            )
                            
                            Rectangle()
                                .frame(height: 0.5)
                                .foregroundStyle(Color.secondary)
                            DailyCell(
                                items: Forecast.mock.list
                            )
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


#Preview {
    ForecastView()
}



extension View {
    @ViewBuilder
    func removeInsets() -> some View {
        self
            .listRowInsets(.zero)
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
    }
}

extension EdgeInsets {
    static let zero: EdgeInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
}
