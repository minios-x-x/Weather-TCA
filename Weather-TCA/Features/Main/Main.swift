//
//  Main.swift
//  Weather-TCA
//
//  Created by 민경준 on 8/20/26.
//

import ComposableArchitecture

@Reducer
struct Main {
    @ObservableState
    struct State {
        var weather: Weather?
    }
    
    enum Action {
        
    }
    
    var body: some ReducerOf<Self> {
        
    }
}
