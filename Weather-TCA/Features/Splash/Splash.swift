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
    }
    
    enum Action {
        case onAppear
        case fetchLocalities
        case responseLocalities([Locality])
        case fetchCurrentWeather
        case responseCurrentWeather(Weather)
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
                // @Shared 값은 = 대신 withLock으로 바꾼다.
                state.$localities.withLock { $0 = localities }
                return .send(.fetchCurrentWeather)
            case .fetchCurrentWeather:
                // localities.first를 "기본 도시(서울)"로 취급한다.
                // 나중에 "사용자가 마지막으로 본 도시"를 쓰게 되면 이 부분만 바뀌면 된다.
                guard let target = state.localities.first else {
                    return .send(
                        .responseFetchError(
                            LocalityError.fileNotFound
                        )
                    )
                }
              
                // .run 클로저 안에서는 state에 직접 접근할 수 없다.
                // 그래서 필요한 값(target)을 캡처 리스트 [target]으로 미리 복사해서 넘긴다.
                return .run { [target] send in
                    let weather = try await weatherAdapter.fetchCurrentWeather(target.coord)
                    
                    dump(weather)
                    await send(
                        .responseCurrentWeather(weather)
                    )
                } catch: { error, send in
                    print("FETCH ERROR: \(error.localizedDescription)")
                    await send(
                        .responseFetchError(error)
                    )
                }
            case .responseFetchError(let error):
                print(error.localizedDescription)
                return .none
            default:
                return .none
            }
        }
    }
}
