//
//  Weather_TCAApp.swift
//  Weather-TCA
//
//  Created by 민경준 on 8/18/26.
//

import SwiftUI
import ComposableArchitecture

@main
struct Weather_TCAApp: App {
    let store = Store(
        initialState: .init(),
        reducer: { Root() }
    )
    
    var body: some Scene {
        WindowGroup {
            RootView(store: store)
        }
    }
}
