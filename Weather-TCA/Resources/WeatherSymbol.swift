//
//  WeatherSymbol.swift
//  Weather-TCA
//
//  Created by 민경준 on 8/28/26.
//

import SwiftUI

struct WeatherSymbol: View {
    init(for iconCode: String) {
        self.iconCode = iconCode
    }
    
    let iconCode: String
    var url: URL? {
        .init(string: "https://openweathermap.org/img/wn/\(iconCode)@2x.png")
    }
    var body: some View {
        AsyncImage(url: url) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
        } placeholder: {
            ProgressView()
        }
    }
}
