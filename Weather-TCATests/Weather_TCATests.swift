//
//  Weather_TCATests.swift
//  Weather-TCATests
//
//  Created by 민경준 on 8/25/26.
//

import ComposableArchitecture
import Testing
import Foundation
@testable import Weather_TCA


@MainActor
struct SplashTest {
//    @Test
//    func test_fetch_success() async {
//        let store = TestStore(
//            initialState: Splash.State(),
//            reducer: { Splash() },
//            withDependencies: {
//                $0.weatherAdapter.fetchCurrentWeather = { _ in .mock }
//            }
//        )
//        
//        await store.send(.fetchCurrentWeather)
//        await store.receive(\.responseCurrentWeather) {
//            $0.isSplashCompleted = true
//        }
//    }
    
//    @Test
//    func test_fetch_failure() async {
//        struct TestError: Error {}
//
//        let store = TestStore(
//            initialState: Splash.State(),
//            reducer: { Splash() },
//            withDependencies: {
//                $0.weatherAdapter.fetchCurrentWeather = { _ in
//                    throw TestError()
//                }
//            }
//        )
//
//        await store.send(.fetchCurrentWeather)
//        await store.receive(\.responseFetchError) {
//            $0.isSplashErrored = true
//        }
//    }
    
    @Test
    func test_root_transition_success() async throws {
        let store = TestStore(
            initialState: Root.State(),
            reducer: { Root() },
            withDependencies: {
                $0.weatherAdapter.fetchCurrentWeather = { _ in .mock }
            }
        )
        
        await store.send(
            .splash(.fetchCurrentWeather)
        )
        
        await store.receive(
            \.splash.responseCurrentWeather
        ) {
            $0.isSplashActive = false
            $0.main = Main.State(weather: .mock)
        }
    }
    
    @Test
    func test_root_transition_exhaustivity() async throws {
        let store = TestStore(
            initialState: Root.State(),
            reducer: { Root() },
            withDependencies: {
                $0.weatherAdapter.fetchCurrentWeather = { _ in .mock }
            }
        )
        store.exhaustivity = .off
        
        await store.send(
            .splash(.fetchCurrentWeather)
        )
        
        await store.receive(
            \.splash.responseCurrentWeather
        )
        
        #expect(store.state.isSplashActive == false)
    }
}
