//
//  TemperatureBar.swift
//  Weather-TCA
//
//  Created by 민경준 on 8/28/26.
//

import SwiftUI

/// 5(또는 N)일 전체 기온 범위를 기준 눈금으로 삼아, 그 안에서 하루치 최저~최고 구간을 막대로 그려주는 뷰.
struct TemperatureBar: View {
    let dayMin: Double
    let dayMax: Double
    let overallMin: Double
    let overallMax: Double
    /// "오늘"에만 넘겨주면 현재 기온 위치에 흰 점이 찍힌다.
    var currentTemp: Double? = nil

    private var overallRange: Double {
        max(overallMax - overallMin, 1) // 0으로 나누는 것 방지
    }

    private func position(for value: Double, in width: CGFloat) -> CGFloat {
        let ratio = (value - overallMin) / overallRange
        return width * CGFloat(min(max(ratio, 0), 1))
    }

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let startX = position(for: dayMin, in: width)
            let endX = position(for: dayMax, in: width)
            let barWidth = max(endX - startX, 4)

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(.ultraThinMaterial)
                    .frame(height: 4)

                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [.yellow, .orange],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: barWidth, height: 5)
                    .offset(x: startX)

                if let currentTemp {
                    let currentX = position(for: currentTemp, in: width)
                    Circle()
                        .fill(.white)
                        .frame(width: 8, height: 8)
                        .offset(x: currentX - 4)
                }
            }
        }
        .frame(height: 8)
    }
}
