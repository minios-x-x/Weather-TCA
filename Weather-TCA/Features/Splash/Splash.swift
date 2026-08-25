//
//  Splash.swift
//  Weather-TCA
//
//  Created by 민경준 on 8/18/26.
//

import ComposableArchitecture

@Reducer
struct Splash {
    @Dependency(\.weatherAdapter) var adapter
    @ObservableState
    struct State {
        
    }
    
    enum Action {
        case fetchCurrentWeather
        case responseCurrentWeather(Weather)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .fetchCurrentWeather:
                return .run { send in
                    let weather = try await adapter.fetchCurrentWeather("Seoul")
                    
                    dump(weather)
                    await send(
                        .responseCurrentWeather(weather)
                    )
                }
            default:
                return .none
            }
        }
    }
}
