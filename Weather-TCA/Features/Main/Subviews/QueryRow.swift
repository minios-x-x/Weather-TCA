//
//  QueryRow.swift
//  Weather-TCA
//
//  Created by 민경준 on 8/30/26.
//

import SwiftUI

struct QueryRow: View {
    init(_ locality: Locality, matching query: String) {
        self.locality = locality
        self.query = query
    }
    
    let locality: Locality
    let query: String
    
    var displayName: String {
        locality.province == locality.city
        ? "\(locality.country) \(locality.city)"
        : "\(locality.country) \(locality.province) \(locality.city)"
    }
    
    var body: some View {
        highlightedText(displayName, matching: query)
    }
    
    func highlightedText(
        _ text: String,
        matching query: String,
        highlightColor: Color = .accentColor,
        baseColor: Color = .black
    ) -> Text {
        guard !query.isEmpty, let range = text.range(of: query, options: .caseInsensitive) else {
            return Text(text).foregroundStyle(baseColor)
        }

        let before = text[text.startIndex..<range.lowerBound]
        let matched = text[range]
        let after = text[range.upperBound...]

        return Text(before).foregroundStyle(baseColor)
            + Text(matched).foregroundStyle(highlightColor)
            + Text(after).foregroundStyle(baseColor)
    }
}


#Preview {
    QueryRow(.seoul, matching: "서울")
}
