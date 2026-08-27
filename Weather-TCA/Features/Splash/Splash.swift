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
    struct State: Equatable {
        var isSplashCompleted: Bool = false
        var isSplashErrored: Bool = false
    }
    
    enum Action {
        case fetchCurrentWeather
        case responseCurrentWeather(Weather)
        case responseFetchError(Error)
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
                } catch: { error, send in
                    print("FETCH ERROR: \(error.localizedDescription)")
                    await send(
                        .responseFetchError(error)
                    )
                }
            case .responseCurrentWeather(_):
                state.isSplashCompleted = true
                return .none
            case .responseFetchError(let error):
                state.isSplashErrored = true
                return .none
            default:
                return .none
            }
        }
    }
}
