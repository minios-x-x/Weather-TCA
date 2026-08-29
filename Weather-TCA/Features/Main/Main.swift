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
        var cityList: [Target]
        var selectedCity: Target?
        var hasPresented: Bool = false
        var isFetchingForecast: Bool = false
        var searchQuery: String = ""
        var isOnSearching: Bool = false
        
        init(initialValue target: Target) {
            cityList = [target]
            selectedCity = target
        }
    }
    
    enum Action {
        case selectCity(Target?)
        case fetchForecast(Target)
        
        case responseForecast(Target)
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
                    return .send(.fetchForecast(target))
                } else {
                    state.selectedCity = nil
                    return .none
                }
            case .fetchForecast(let target):
                state.isFetchingForecast = true
                
                return .run { send in
                    let forecast = try await weatherAdapter.fetchCurrentForecast(target.locality.coord)
                    var updated = target
                    updated.forecast = forecast
                    
                    await send(.responseForecast(updated))
                } catch: { error, send in
                    await send(.responseError(error))
                }
            case .responseForecast(let target):
                state.isFetchingForecast = false
                state.selectedCity = target
                
                return .none
            case .responseError(let error):
                state.isFetchingForecast = false
                state.selectedCity = nil
                
                return .none
            default:
                return .none
            }
        }
    }
}
