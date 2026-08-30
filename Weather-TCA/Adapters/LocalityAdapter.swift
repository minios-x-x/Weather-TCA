//
//  LocalityAdapter.swift
//  Weather-TCA
//
//  Created by 민경준 on 8/27/26.
//

import ComposableArchitecture
import Foundation

enum LocalityError: Error, Equatable {
    case fileNotFound
}

struct LocalityAdapter {
    var fetchLoaclityList: () async throws -> [Locality]
}

extension LocalityAdapter: DependencyKey {
    static var liveValue: LocalityAdapter {
        return .init {
            guard let url = Bundle.main.url(forResource: "city.list.kr", withExtension: "json") else {
                throw LocalityError.fileNotFound
            }
            
            let data = try Data(contentsOf: url)
            return try JSONSerializer.decode(
                [Locality].self,
                from: data
            )
        }
    }
    // 프리뷰에서는 매번 번들을 읽지 않도록 고정된 목록을 바로 반환한다.
    static var previewValue: LocalityAdapter {
        return .init {
            return [.seoul, .suwon]
        }
    }
 
    // 테스트 기본값.
    // 개별 테스트에서 다른 동작이 필요하면 withDependencies로 덮어쓰면 된다.
    static var testValue: LocalityAdapter {
        return .init {
            return [.seoul, .suwon]
        }
    }
}

extension DependencyValues {
    var localityAdapter: LocalityAdapter {
        get { self[LocalityAdapter.self] }
        set { self[LocalityAdapter.self] = newValue }
    }
}


// MARK: - Shared Key
 
/// 앱 전역에서 같은 도시 목록을 참조하기 위한 타입-세이프 Shared 키.
/// - Splash: `@Shared(.localities)`로 값을 채운다.
/// - 그 외 화면: `@SharedReader(.localities)`로 읽기만 한다.
extension SharedReaderKey where Self == InMemoryKey<[Locality]>.Default {
    static var localities: Self {
        Self[.inMemory("localities"), default: []]
    }
}

extension SharedReaderKey where Self == AppStorageKey<[Locality]>.Default {
    static var bookmarks: Self {
        Self[.appStorage("bookmark_locations"), default: []]
    }
}
