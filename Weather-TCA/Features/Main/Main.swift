//
//  Main.swift
//  Weather-TCA
//
//  Created by 민경준 on 8/20/26.
//

import ComposableArchitecture

@Reducer
struct Main {
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
        var searchQuery: String = ""
        var isOnSearching: Bool = false
        
        init(initialValue target: Target) {
            cityList = [target]
            selectedCity = target
        }
    }
    
    enum Action {
        case selectCity(Target?)
        case queryChanged(String)
        case focusChanged(Bool)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .selectCity(let weather):
                state.hasPresented = true
                state.selectedCity = weather
                return .none
            default:
                return .none
            }
        }
    }
}
