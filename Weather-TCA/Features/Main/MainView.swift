//
//  MainView.swift
//  Weather-TCA
//
//  Created by 민경준 on 8/25/26.
//

import ComposableArchitecture
import SwiftUI

struct MainView: View {
    let store: StoreOf<Main>
    
    var body: some View {
        VStack {
            if let weather = store.state.weather.condition.first {
                AsyncImage(
                    url: URL(string: "https://openweathermap.org/img/wn/\(weather.icon)@2x.png"),
                    content: { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 200)
                    },
                    placeholder: {
                        ProgressView()
                    }
                )
                Text(weather.description)
                
                Text("온도: \(store.state.weather.info.temp)")
                Text("최저온도: \(store.state.weather.info.tempMin)")
                Text("최고온도: \(store.state.weather.info.tempMax)")
                
                Text("풍향: \(store.state.weather.wind.direction)풍")
                Text("풍속: \(store.state.weather.wind.speed)")
            }
        }
    }
}

#Preview {
    MainView(
        store: .init(
            initialState: Main.State(weather: .mock),
            reducer: {
                Main()
            }
        )
    )
}
