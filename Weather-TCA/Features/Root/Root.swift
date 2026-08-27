//
//  Root.swift
//  Weather-TCA
//
//  Created by 민경준 on 8/18/26.
//

import ComposableArchitecture

@Reducer
struct Root {
    @ObservableState
    struct State: Equatable {
        var isSplashActive: Bool = true
        var main: Main.State?
        var splash: Splash.State = .init()
        
        mutating func finishSplash(initialValue target: Main.Target) {
            self.main = .init(initialValue: target)
            self.isSplashActive = false
        }
    }
    
    enum Action {
        case splash(Splash.Action)
        case main(Main.Action)
    }
    
    var body: some ReducerOf<Self> {
        Scope(\.splash, action: \.splash) { Splash() }
        
        
        Reduce { state, action in
            switch action {
            case .splash(.finishSplash):
                state.finishSplash(
                    initialValue: .init(
                        locality: state.splash.locality!,
                        weather: state.splash.weather,
                        forecast: state.splash.forecast
                    )
                )
                return .none
            default:
                return .none
            }
        }
        .ifLet(\.main, action: \.main) {
            Main()
        }
    }
}
