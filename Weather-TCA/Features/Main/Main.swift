//
//  Main.swift
//  Weather-TCA
//
//  Created by 민경준 on 8/20/26.
//

import ComposableArchitecture

@Reducer
struct Main {
    @Dependency(\.weatherAdapter) var weatherAdapter
    
    struct Target: Equatable, Identifiable {
        var id: Int { locality.id }
        let locality: Locality
        var weather: Weather?
        var forecast: Forecast?
    }
    
    @ObservableState
    struct State: Equatable {
        @SharedReader(.localities) var localities
        @Shared(.bookmarks) var bookmarks
        
        var queryList: [Locality] = []
        
        var cityList: [Target]
        var selectedCity: Target?
        var selectedQuery: Target?
        
        var hasPresented: Bool = false
        var isFetchingForecast: Bool = false
        
        var searchQuery: String = ""
        var isOnSearching: Bool = false
        
        init(initialValue targets: [Target]) {
            cityList = targets
            selectedCity = targets.first
        }
    }
    
    enum Action {
        case selectCity(Target?)
        case responseCity(Target)
        
        case selectQuery(Target?)
        case responseQuery(Target)
        
        case bookmarkCity(Target)
        case refreshBookmark([Target])
        
        case responseError(Error)
        
        case queryChanged(String)
        case focusChanged(Bool)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .selectCity(let target):
                state.hasPresented = true
                
                if let target = target {
                    state.isFetchingForecast = true
                    return .run { send in
                        let forecast = try await weatherAdapter.fetchCurrentForecast(target.locality.coord)
                        let weather = try await weatherAdapter.fetchCurrentWeather(target.locality.coord)
                        
                        var updated = target
                        updated.forecast = forecast
                        updated.weather = weather
                        
                        await send(.responseCity(updated))
                    } catch: { error, send in
                        await send(.responseError(error))
                    }
                } else {
                    state.selectedCity = nil
                    return .none
                }
            case .responseCity(let target):
                state.isFetchingForecast = false
                state.selectedCity = target
                
                return .none
            case .selectQuery(let target):
                if let target = target {
                    state.isFetchingForecast = true
                    return .run { send in
                        let forecast = try await weatherAdapter.fetchCurrentForecast(target.locality.coord)
                        let weather = try await weatherAdapter.fetchCurrentWeather(target.locality.coord)
                        
                        let target: Target = .init(
                            locality: target.locality,
                            weather: weather,
                            forecast: forecast
                        )
                        
                        await send(.responseQuery(target))
                    } catch: { error, send in
                        await send(.responseError(error))
                    }
                } else {
                    state.selectedQuery = nil
                    return .none
                }
            case .responseQuery(let target):
                state.isFetchingForecast = false
                state.selectedQuery = target
                
                return .none
            case .bookmarkCity(let target):
                state.$bookmarks.withLock {
                    $0 = ($0 + [target.locality] + [.seoul]).uniqued()
                }
                let bookmarks = state.bookmarks

                return .run { send in
                    var targets: [Target] = []
                    for bookmark in bookmarks {
                        let weather = try await weatherAdapter.fetchCurrentWeather(bookmark.coord)
                        let forecast = try await weatherAdapter.fetchCurrentForecast(bookmark.coord)
                        
                        targets.append(
                            .init(
                                locality: bookmark,
                                weather: weather,
                                forecast: forecast
                            )
                        )
                    }
                    
                    await send(.refreshBookmark(targets))
                }
            case .refreshBookmark(let target):
                state.cityList = target
                state.isOnSearching = false
                state.searchQuery = ""
                state.selectedQuery = nil
                
                return .none
            case .queryChanged(let query):
                state.searchQuery = query
                state.queryList = state.localities.filtered(by: query)
                return .none
            case .focusChanged(let focused):
                state.isOnSearching = focused
                return .none
            case .responseError(_):
                state.isFetchingForecast = false
                state.selectedCity = nil
                
                return .none
            }
        }
    }
}
