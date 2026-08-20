//
//  Moya+Ex.swift
//  Weather-TCA
//
//  Created by 민경준 on 8/20/26.
//

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
