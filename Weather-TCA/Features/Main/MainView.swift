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
            List{
                ForEach(store.state.cityList) { city in
                    CityRow(city: city)
                        .listRowInsets(EdgeInsets())      // row 기본 여백 제거
                        .listRowBackground(Color.clear)   // row 기본 흰 배경 제거
                        .listRowSeparator(.hidden)        // 구분선 제거
                        .padding(.horizontal)
                        .padding(.vertical)
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
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .navigationTitle("날씨")
            .searchable(
                text: Binding(
                    get: { store.searchQuery },
                    set: { store.send(.queryChanged($0)) }
                ),
                isPresented: Binding(
                    get: { store.isOnSearching },
                    set: { store.send(.focusChanged($0)) }
                ),
                prompt: "도시 또는 공항 검색"
            )
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        print("TAP BUTTON")
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
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
                ),
                content: { locality in
                    ForecastView()
                        .navigationTransition(
                            .zoom(sourceID: locality.id, in: namespace)
                        )
                }
            )
            .transaction { transaction in
                if store.hasPresented == false {
                    transaction.disablesAnimations = true
                }
            }
        }
    }
}

