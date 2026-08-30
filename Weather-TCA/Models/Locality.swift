//
//  Locality.swift
//  Weather-TCA
//
//  Created by 민경준 on 8/27/26.
//

import Foundation

struct Locality: Codable, Equatable, Identifiable {
    struct Coordinate: Codable, Equatable {
        let lat: Double
        let lng: Double
    }
    
    let id: Int
    let country: String
    let province: String
    let city: String
    let coord: Coordinate
}

extension Locality {
    static let seoul: Locality = .init(
        id: 1,
        country: "대한민국",
        province: "서울특별시",
        city: "서울특별시",
        coord: .init(
            lat: 37.5665,
            lng: 126.9780
        )
    )
    static let suwon: Locality = .init(
        id: 9,
        country: "대한민국",
        province: "경기도",
        city: "수원시",
        coord: .init(
            lat: 37.2636,
            lng: 127.0286
        )
    )
}

extension Array where Element == Locality {
    func filtered(by query: String) -> [Locality] {
        guard !query.isEmpty else { return [] }
        return filter {
            $0.country.localizedStandardContains(query)
            || $0.province.localizedStandardContains(query)
            || $0.city.localizedStandardContains(query)
        }
    }
    func uniqued() -> [Locality] {
        var seen = Set<Int>()
        return filter { seen.insert($0.id).inserted }
    }
}
