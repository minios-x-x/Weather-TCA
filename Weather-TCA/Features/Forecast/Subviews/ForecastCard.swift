//
//  ForecastCard.swift
//  Weather-TCA
//
//  Created by 민경준 on 8/28/26.
//

import SwiftUI

struct ForecastCard<Content: View, HeaderView: View>: View {
    @ViewBuilder var content: () -> Content
    @ViewBuilder var headerView: () -> HeaderView
    
    var body: some View {
        LazyVStack(spacing: 0.0, pinnedViews: [.sectionHeaders]) {
            Section {
                VStack(spacing: 0.0) {
                    // Content
                    content()
                }
                .padding(.horizontal)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    .ultraThinMaterial,
                    in: UnevenRoundedRectangle(
                        topLeadingRadius: 0,
                        bottomLeadingRadius: 20,
                        bottomTrailingRadius: 20,
                        topTrailingRadius: 0
                    )
                )
            } header: {
                HStack(spacing: 5.0) {
                    // HeaderView
                    headerView()
                }
                .foregroundStyle(Color.secondary)
                .padding(.horizontal)
                .padding(.vertical, 10.0)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    .ultraThinMaterial,
                    in: UnevenRoundedRectangle(
                        topLeadingRadius: 20,
                        bottomLeadingRadius: 0,
                        bottomTrailingRadius: 0,
                        topTrailingRadius: 20
                    )
                )
            }
        }
        .padding(.horizontal)
    }
}
