//
//  SplashView.swift
//  Weather-TCA
//
//  Created by 민경준 on 8/20/26.
//

import SwiftUI
import ComposableArchitecture

struct SplashView: View {
    @Bindable var store: StoreOf<Splash>
    
    var body: some View {
        ZStack {
            Color.skyblue
                .ignoresSafeArea()
            
            Image("icon-sun")
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
        }
        .onAppear() {
            store.send(.fetchCurrentWeather)
        }
    }
}

#Preview("SplashView") {
    SplashView(
        store: .init(
            initialState: Splash.State(),
            reducer: {
                Splash()
            },
            withDependencies: {
                $0.weatherAdapter = .previewValue
            }
        )
    )
}
