//
//  Splash.swift
//  Weather-TCA
//
//  Created by 민경준 on 8/18/26.
//

import ComposableArchitecture

@Reducer
struct Splash {
    @Dependency(\.weatherAdapter) var weatherAdapter
    @Dependency(\.localityAdapter) var localityAdapter
    
    @ObservableState
    struct State: Equatable {
        // 값을 채우는 쪽이니 읽기/쓰기가 모두 가능한 @Shared를 쓴다.
        @Shared(.localities) var localities
        @SharedReader(.bookmarks) var bookmarks
        
        var targets: [Main.Target] = []
    }
    
    enum Action {
        case onAppear
        case fetchLocalities
        case responseLocalities([Locality])
        
        case fetchCurrentWeathers([Locality])
        case responseCurrentWeathers([Main.Target])
        
        case finishSplash
        case responseFetchError(Error)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .send(.fetchLocalities)
            case .fetchLocalities:
                return .run { send in
                    let localities = try await localityAdapter.fetchLoaclityList()
                    await send(.responseLocalities(localities))
                } catch: { error, send in
                    print("FETCH LOCALITY ERROR: \(error.localizedDescription)")
                    await send(
                        .responseFetchError(error)
                    )
                }
            case .responseLocalities(let localities):
                // @Shared 값은 `=` 대신 withLock으로 바꾼다.
                state.$localities.withLock { $0 = localities }
                
                let bookmarks = (state.bookmarks + [.seoul]).uniqued()
                return .send(.fetchCurrentWeathers(bookmarks))
            case .fetchCurrentWeathers(let bookmarks):
                return .run { send in
                    var targets: [Main.Target] = []
                    
                    for bookmark in bookmarks {
                        let weather = try await weatherAdapter.fetchCurrentWeather(bookmark.coord)
                        let forecast = try await weatherAdapter.fetchCurrentForecast(bookmark.coord)
                        
                        let target = Main.Target(
                            locality: bookmark,
                            weather: weather,
                            forecast: forecast
                        )
                        
                        targets.append(target)
                    }
                    
                    await send(.responseCurrentWeathers(targets))
                } catch: { error, send in
                    print("FETCH WEATHER ERROR: \(error.localizedDescription)")
                    await send(
                        .responseFetchError(error)
                    )
                }
            case .responseCurrentWeathers(let targets):
                state.targets = targets
                return .send(.finishSplash)
            default:
                return .none
            }
        }
    }
}
