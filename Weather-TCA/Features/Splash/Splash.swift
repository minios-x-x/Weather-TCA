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
        
        var locality: Locality?
        var weather: Weather?
        var forecast: Forecast?
        
        var isFinish: Bool {
            weather != nil && forecast != nil && locality != nil
        }
    }
    
    enum Action {
        case onAppear
        case fetchLocalities
        case responseLocalities([Locality])
        
        case fetchCurrentWeather(Locality.Coordinate)
        case responseCurrentWeather(Weather)
        case fetchCurrentForecast(Locality.Coordinate)
        case responseCurrentForecast(Forecast)
        
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
                state.locality = localities.first
                
                // localities.first를 "기본 도시(서울)"로 취급한다.
                // 나중에 "사용자가 마지막으로 본 도시"를 쓰게 되면 이 부분만 바뀌면 된다.
                guard let target = state.localities.first else {
                    return .send(
                        .responseFetchError(
                            LocalityError.fileNotFound
                        )
                    )
                }
                
                return .merge(
                    .send(.fetchCurrentWeather(target.coord)),
                    .send(.fetchCurrentForecast(target.coord))
                )
            case .fetchCurrentWeather(let coord):
                return .run { send in
                    let weather = try await weatherAdapter.fetchCurrentWeather(coord)
                    await send(
                        .responseCurrentWeather(weather)
                    )
                } catch: { error, send in
                    print("FETCH WEATHER ERROR: \(error.localizedDescription)")
                    await send(
                        .responseFetchError(error)
                    )
                }
            case .responseCurrentWeather(let weather):
                state.weather = weather
                return finishIfReady(state)
            case .fetchCurrentForecast(let coord):
                return .run { send in
                    let forecast = try await weatherAdapter.fetchCurrentForecast(coord)
                    await send(
                        .responseCurrentForecast(forecast)
                    )
                } catch: { error, send in
                    print("FETCH FORECAST ERROR: \(error.localizedDescription)")
                    await send(
                        .responseFetchError(error)
                    )
                }
            case .responseCurrentForecast(let forecast):
                state.forecast = forecast
                return finishIfReady(state)
            default:
                return .none
            }
        }
    }
    
    private func finishIfReady(_ state: State) -> Effect<Action> {
        state.isFinish ? .send(.finishSplash) : .none
    }
}
