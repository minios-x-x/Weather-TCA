//
//  Moya+Ex.swift
//  Weather-TCA
//
//  Created by 민경준 on 8/20/26.
//

import Foundation
import Moya

extension MoyaProvider {
    func request(_ target: Target) async -> Result<Response, MoyaError> {
        await withCheckedContinuation { continuation in
            self.request(target) { result in
                continuation.resume(returning: result)
            }
        }
    }
}



protocol MoyaTarget: TargetType { }
extension MoyaTarget {
    var baseURL: URL {
        return .init(string: "https://api.openweathermap.org/data/2.5")!
    }
    var validationType: ValidationType {
        return .successCodes
    }
    var headers: [String : String]? {
        var headers: [String: String] = [:]
        headers["Content-Type"] = "application/json"
        
        return headers
    }
}
