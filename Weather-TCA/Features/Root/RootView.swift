//
//  RootView.swift
//  Weather-TCA
//
//  Created by 민경준 on 8/20/26.
//

import SwiftUI
import ComposableArchitecture

struct RootView: View {
    let store: StoreOf<Root>
    
    var body: some View {
        Group {
            if let mainStore = store.scope(\.main, action: \.main) {
                MainView(store: mainStore)
                    .transition(.opacity)
            } else {
                SplashView(
                    store: store.scope(
                        state: \.splash,
                        action: \.splash
                    )
                )
                .transition(.opacity)
            }
        }
        .animation(.easeInOut, value: store.main == nil)
    }
}
