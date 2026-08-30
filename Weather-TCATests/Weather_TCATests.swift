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

// MARK: - Root

@MainActor
struct RootTests {
    @Test
    func splash_finishSplash_transitionsToMain() async {
        let targets: [Main.Target] = [
            .init(locality: .seoul, weather: .mock, forecast: .mock)
        ]

        var splashState = Splash.State()
        splashState.targets = targets

        let store = TestStore(
            initialState: Root.State(splash: splashState),
            reducer: { Root() }
        )

        await store.send(.splash(.finishSplash)) {
            $0.isSplashActive = false
            $0.main = Main.State(initialValue: targets)
        }
    }

    @Test
    func fullSplashFlow_transitionsRootToMainWithBookmarkedCities() async {
        let store = TestStore(
            initialState: Root.State(),
            reducer: { Root() },
            withDependencies: {
                $0.defaultAppStorage = UserDefaults(suiteName: "root-\(UUID())")!
                $0.localityAdapter.fetchLoaclityList = { [.seoul, .suwon] }
                $0.weatherAdapter.fetchCurrentWeather = { _ in .mock }
                $0.weatherAdapter.fetchCurrentForecast = { _ in .mock }
            }
        )
        // 여러 단계가 동기적으로 연쇄될 때 TestStore가 상태 변화를 엉뚱한 단계에
        // 귀속시키는 경우가 있어, 단계별 diff 대신 최종 상태만 확인한다.
        store.exhaustivity = .off

        // 즐겨찾기가 비어있는 첫 실행 상태를 가정한다.
        @Shared(.bookmarks) var bookmarks
        $bookmarks.withLock { $0 = [] }

        await store.send(.splash(.onAppear))
        await store.receive(\.splash.fetchLocalities)
        await store.receive(\.splash.responseLocalities)
        // 즐겨찾기가 비어있어도 서울은 항상 기본으로 포함된다.
        await store.receive(\.splash.fetchCurrentWeathers)
        await store.receive(\.splash.responseCurrentWeathers)
        await store.receive(\.splash.finishSplash)

        #expect(store.state.isSplashActive == false)
        #expect(
            store.state.main == Main.State(initialValue: [
                .init(locality: .seoul, weather: .mock, forecast: .mock)
            ])
        )
    }
}

// MARK: - Splash

@MainActor
struct SplashTests {
    @Test
    func onAppear_sendsFetchLocalities() async {
        // localityAdapter를 실패시켜서 fetchLocalities 이후 체인이 responseFetchError에서
        // 끊기게 만든다. 그래야 weatherAdapter까지 안 건드리고 이 액션 하나에만 집중할 수 있다.
        struct TestError: Error, Equatable {}

        let store = TestStore(
            initialState: Splash.State(),
            reducer: { Splash() },
            withDependencies: {
                $0.localityAdapter.fetchLoaclityList = { throw TestError() }
            }
        )
        store.exhaustivity = .off

        await store.send(.onAppear)
        await store.receive(\.fetchLocalities)
    }

    @Test
    func fetchLocalities_success_sendsResponseLocalities() async {
        let store = TestStore(
            initialState: Splash.State(),
            reducer: { Splash() },
            withDependencies: {
                $0.localityAdapter.fetchLoaclityList = { [.seoul, .suwon] }
                $0.weatherAdapter.fetchCurrentWeather = { _ in .mock }
                $0.weatherAdapter.fetchCurrentForecast = { _ in .mock }
            }
        )
        store.exhaustivity = .off

        await store.send(.fetchLocalities)
        await store.receive(\.responseLocalities) {
            $0.$localities.withLock { $0 = [.seoul, .suwon] }
        }
    }

    @Test
    func fetchLocalities_failure_sendsResponseFetchError() async {
        struct TestError: Error, Equatable {}

        let store = TestStore(
            initialState: Splash.State(),
            reducer: { Splash() },
            withDependencies: {
                $0.localityAdapter.fetchLoaclityList = { throw TestError() }
            }
        )

        await store.send(.fetchLocalities)
        await store.receive(\.responseFetchError)
    }

    @Test
    func responseLocalities_setsLocalitiesAndAlwaysIncludesSeoulInBookmarks() async {
        let store = TestStore(
            initialState: Splash.State(),
            reducer: { Splash() },
            withDependencies: {
                $0.defaultAppStorage = UserDefaults(suiteName: "splash-\(UUID())")!
                $0.weatherAdapter.fetchCurrentWeather = { _ in .mock }
                $0.weatherAdapter.fetchCurrentForecast = { _ in .mock }
            }
        )
        store.exhaustivity = .off

        // 즐겨찾기가 비어있는 상태를 명시적으로 세팅한다.
        @Shared(.bookmarks) var bookmarks
        $bookmarks.withLock { $0 = [] }

        await store.send(.responseLocalities([.seoul, .suwon])) {
            $0.$localities.withLock { $0 = [.seoul, .suwon] }
        }
        // 즐겨찾기가 비어있어도 서울은 항상 포함해서 fetchCurrentWeathers를 보낸다.
        await store.receive(\.fetchCurrentWeathers)
    }

    @Test
    func fetchCurrentWeathers_success_sendsResponseCurrentWeathers() async {
        let store = TestStore(
            initialState: Splash.State(),
            reducer: { Splash() },
            withDependencies: {
                $0.weatherAdapter.fetchCurrentWeather = { _ in .mock }
                $0.weatherAdapter.fetchCurrentForecast = { _ in .mock }
            }
        )

        await store.send(.fetchCurrentWeathers([.seoul]))
        await store.receive(\.responseCurrentWeathers) {
            $0.targets = [
                .init(locality: .seoul, weather: .mock, forecast: .mock)
            ]
        }
        // responseCurrentWeathers는 곧바로 finishSplash도 보낸다.
        await store.receive(\.finishSplash)
    }

    @Test
    func fetchCurrentWeathers_failure_sendsResponseFetchError() async {
        struct TestError: Error, Equatable {}

        let store = TestStore(
            initialState: Splash.State(),
            reducer: { Splash() },
            withDependencies: {
                $0.weatherAdapter.fetchCurrentWeather = { _ in throw TestError() }
                $0.weatherAdapter.fetchCurrentForecast = { _ in .mock }
            }
        )

        await store.send(.fetchCurrentWeathers([.seoul]))
        await store.receive(\.responseFetchError)
    }

    @Test
    func responseCurrentWeathers_setsTargetsAndFinishesSplash() async {
        let targets: [Main.Target] = [
            .init(locality: .seoul, weather: .mock, forecast: .mock)
        ]

        let store = TestStore(
            initialState: Splash.State(),
            reducer: { Splash() }
        )

        await store.send(.responseCurrentWeathers(targets)) {
            $0.targets = targets
        }
        await store.receive(\.finishSplash)
    }
}

// MARK: - Main

@MainActor
struct MainTests {
    @Test
    func selectCity_withTarget_fetchesForecastAndWeather() async {
        let target = Main.Target(locality: .seoul, weather: nil, forecast: nil)

        let store = TestStore(
            initialState: Main.State(initialValue: [target]),
            reducer: { Main() },
            withDependencies: {
                $0.weatherAdapter.fetchCurrentForecast = { _ in .mock }
                $0.weatherAdapter.fetchCurrentWeather = { _ in .mock }
            }
        )

        await store.send(.selectCity(target)) {
            $0.hasPresented = true
            $0.isFetchingForecast = true
        }
        await store.receive(\.responseCity) {
            $0.isFetchingForecast = false
            $0.selectedCity = Main.Target(
                locality: .seoul,
                weather: .mock,
                forecast: .mock
            )
        }
    }

    @Test
    func selectCity_withNil_clearsSelection() async {
        let target = Main.Target(locality: .seoul, weather: .mock, forecast: .mock)
        var state = Main.State(initialValue: [target])
        state.selectedCity = target

        let store = TestStore(
            initialState: state,
            reducer: { Main() }
        )

        await store.send(.selectCity(nil)) {
            $0.hasPresented = true
            $0.selectedCity = nil
        }
    }

    @Test
    func selectCity_failure_clearsFetchingAndSelection() async {
        struct TestError: Error, Equatable {}
        let target = Main.Target(locality: .seoul, weather: nil, forecast: nil)

        let store = TestStore(
            initialState: Main.State(initialValue: [target]),
            reducer: { Main() },
            withDependencies: {
                $0.weatherAdapter.fetchCurrentForecast = { _ in throw TestError() }
                $0.weatherAdapter.fetchCurrentWeather = { _ in .mock }
            }
        )

        await store.send(.selectCity(target)) {
            $0.hasPresented = true
            $0.isFetchingForecast = true
        }
        await store.receive(\.responseError) {
            $0.isFetchingForecast = false
            $0.selectedCity = nil
        }
    }

    @Test
    func selectQuery_withTarget_fetchesForecastAndWeather() async {
        let target = Main.Target(locality: .suwon, weather: nil, forecast: nil)

        let store = TestStore(
            initialState: Main.State(initialValue: []),
            reducer: { Main() },
            withDependencies: {
                $0.weatherAdapter.fetchCurrentForecast = { _ in .mock }
                $0.weatherAdapter.fetchCurrentWeather = { _ in .mock }
            }
        )

        await store.send(.selectQuery(target)) {
            $0.isFetchingForecast = true
        }
        await store.receive(\.responseQuery) {
            $0.isFetchingForecast = false
            $0.selectedQuery = Main.Target(
                locality: .suwon,
                weather: .mock,
                forecast: .mock
            )
        }
    }

    @Test
    func selectQuery_withNil_clearsSelection() async {
        let target = Main.Target(locality: .suwon, weather: .mock, forecast: .mock)
        var state = Main.State(initialValue: [])
        state.selectedQuery = target

        let store = TestStore(
            initialState: state,
            reducer: { Main() }
        )

        await store.send(.selectQuery(nil)) {
            $0.selectedQuery = nil
        }
    }

    @Test
    func selectQuery_failure_alsoClearsSelectedCity() async {
        // 주의: 지금 구현상 selectQuery가 실패해도 responseError가 selectedCity를 정리한다.
        // selectedQuery는 그대로 남는, 다소 의아한 현재 동작을 그대로 문서화하는 테스트다.
        struct TestError: Error, Equatable {}
        let queryTarget = Main.Target(locality: .suwon, weather: nil, forecast: nil)
        let existingCity = Main.Target(locality: .seoul, weather: .mock, forecast: .mock)

        var state = Main.State(initialValue: [existingCity])
        state.selectedCity = existingCity

        let store = TestStore(
            initialState: state,
            reducer: { Main() },
            withDependencies: {
                $0.weatherAdapter.fetchCurrentForecast = { _ in throw TestError() }
                $0.weatherAdapter.fetchCurrentWeather = { _ in .mock }
            }
        )

        await store.send(.selectQuery(queryTarget)) {
            $0.isFetchingForecast = true
        }
        await store.receive(\.responseError) {
            $0.isFetchingForecast = false
            $0.selectedCity = nil
        }
    }

    @Test
    func bookmarkCity_addsLocalityAndSeoulThenRefreshesCityList() async {
        let target = Main.Target(locality: .suwon, weather: nil, forecast: nil)

        let store = TestStore(
            initialState: Main.State(initialValue: []),
            reducer: { Main() },
            withDependencies: {
                $0.defaultAppStorage = UserDefaults(suiteName: "main-\(UUID())")!
                $0.weatherAdapter.fetchCurrentWeather = { _ in .mock }
                $0.weatherAdapter.fetchCurrentForecast = { _ in .mock }
            }
        )

        // 즐겨찾기가 비어있는 상태로 시작한다.
        @Shared(.bookmarks) var bookmarks
        $bookmarks.withLock { $0 = [] }

        await store.send(.bookmarkCity(target)) {
            $0.$bookmarks.withLock { $0 = [.suwon, .seoul] }
        }
        await store.receive(\.refreshBookmark) {
            $0.cityList = [
                .init(locality: .suwon, weather: .mock, forecast: .mock),
                .init(locality: .seoul, weather: .mock, forecast: .mock),
            ]
            $0.isOnSearching = false
            $0.searchQuery = ""
            $0.selectedQuery = nil
        }
    }

    @Test
    func queryChanged_filtersLocalitiesByQuery() async {
        @Shared(.localities) var localities
        $localities.withLock { $0 = [.seoul, .suwon] }

        let store = TestStore(
            initialState: Main.State(initialValue: []),
            reducer: { Main() }
        )

        await store.send(.queryChanged("수원")) {
            $0.searchQuery = "수원"
            $0.queryList = [.suwon]
        }
    }

    @Test
    func queryChanged_withEmptyQuery_clearsList() async {
        @Shared(.localities) var localities
        $localities.withLock { $0 = [.seoul, .suwon] }

        // 검색어가 이미 입력되어 있던 상태에서 지워지는지 확인해야 의미가 있다.
        var state = Main.State(initialValue: [])
        state.searchQuery = "수원"
        state.queryList = [.suwon]

        let store = TestStore(
            initialState: state,
            reducer: { Main() }
        )

        await store.send(.queryChanged("")) {
            $0.searchQuery = ""
            $0.queryList = []
        }
    }

    @Test
    func focusChanged_togglesSearchingState() async {
        let store = TestStore(
            initialState: Main.State(initialValue: []),
            reducer: { Main() }
        )

        await store.send(.focusChanged(true)) {
            $0.isOnSearching = true
        }
        await store.send(.focusChanged(false)) {
            $0.isOnSearching = false
        }
    }
}
