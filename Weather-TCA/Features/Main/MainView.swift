//
//  MainView.swift
//  Weather-TCA
//
//  Created by 민경준 on 8/25/26.
//

import ComposableArchitecture
import SwiftUI

struct MainView: View {
    @Namespace private var namespace
    var store: StoreOf<Main>
    
    var body: some View {
        NavigationStack {
            List(store.state.cityList) { city in
                ZStack {
                    Rectangle()
                        .fill(Color.blue)
                    Text(city.locality.city)
                }
                .matchedTransitionSource(
                    id: city.id,
                    in: namespace
                )
                .onTapGesture {
                    store.send(
                        .selectCity(city)
                    )
                }
            }
            .fullScreenCover(
                item: Binding(
                    get: {
                        store.selectedCity
                    },
                    set: { newValue in
                        store.send(
                            .selectCity(newValue)
                        )
                    }
                )
            ) { locality in
                ForecastView()
                    .navigationTransition(
                        .zoom(sourceID: locality.id, in: namespace)
                    )
            }
            .transaction { transaction in
                if store.hasPresented == false {
                    transaction.disablesAnimations = true
                }
            }
        }
    }
}

