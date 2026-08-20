//
//  NetworkClient.swift
//  Weather-TCA
//
//  Created by 민경준 on 8/20/26.
//

import Foundation
import Moya

enum NetworkError: Swift.Error, LocalizedError {
    case requestFailed(underlying: MoyaError)
    case decodingFailed(underlying: Error)
    
    var errorDescription: String? {
        switch self {
        case .requestFailed:
            return "네트워크 요청에 실패했어요."
        case .decodingFailed:
            return "데이터를 해석하는 데 실패했어요."
        }
    }
}

enum JSONSerializer {
    enum Failure: Swift.Error, LocalizedError {
        case encodingFailed
        case decodingFailed
        
        var errorDescription: String? {
            switch self {
            case .encodingFailed:
                return "문자열을 UTF-8 데이터로 변환할 수 없어요."
            case .decodingFailed:
                return "데이터를 UTF-8 문자열로 변환할 수 없어요."
            }
        }
    }
    
    static func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        let decoder = JSONDecoder()
        let value = try decoder.decode(type, from: data)
        
        return value
    }
    static func decode<T: Decodable>(_ type: T.Type, from jsonString: String) throws -> T {
        guard let data = jsonString.data(using: .utf8) else {
            throw Failure.encodingFailed
        }
        
        let value = try JSONSerializer.decode(type, from: data)
        return value
    }
    static func decodeString(from data: Data) throws -> String {
        guard let string = String(data: data, encoding: .utf8) else {
            throw Failure.decodingFailed
        }
        return string
    }
}


final class NetworkClient {
    typealias MoyaResult = Result<Moya.Response, MoyaError>
    
    func codable<T: Decodable, E: TargetType>(_ target: E) async throws -> T {
        let provider: MoyaProvider<E> = .init()
        let moyaResult = await provider.request(target)
        
        switch decode(T.self, from: moyaResult) {
        case .success(let value):
            return value
        case .failure(let error):
            throw error
        }
    }
    
    func void<E: TargetType>(_ target: E) async throws {
        let provider: MoyaProvider<E> = .init()
        let moyaResult = await provider.request(target)
        
        switch moyaResult {
        case .success(_):
            return
        case .failure(let failure):
            throw NetworkError.requestFailed(underlying: failure)
        }
    }
    
    func decode<T: Decodable>(_ type: T.Type, from moyaResult: MoyaResult) -> Result<T, NetworkError> {
        switch moyaResult {
        case .success(let response):
            do {
                let value: T
                switch type {
                case is Data.Type:
                    value = response.data as! T
                case is String.Type:
                    value = try JSONSerializer.decodeString(from: response.data) as! T
                default:
                    value = try JSONSerializer.decode(type, from: response.data)
                }
                
                return .success(value)
            } catch {
                return .failure(
                    .decodingFailed(underlying: error)
                )
            }
            
        case .failure(let error):
            return .failure(
                .requestFailed(underlying: error)
            )
        }
    }
}
