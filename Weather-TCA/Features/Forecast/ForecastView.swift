//
//  ForecastView.swift
//  Weather-TCA
//
//  Created by 민경준 on 8/27/26.
//

import SwiftUI

struct ForecastView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Text("ForecastView")
            .onTapGesture {
                dismiss()
            }
    }
}
