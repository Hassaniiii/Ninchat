//
//  ServiceManager.swift
//  Ninchat
//
//  Created by Hassaniiii on 10/25/19.
//  Copyright © 2019 Hassaniiii. All rights reserved.
//

import Foundation
import Combine

protocol ServiceManager {
    func performRequest<T: Request>(_ request: T) -> AnyPublisher<String?, APIError>
    func performRequestNoReturn<T: Request>(_ request: T) -> AnyPublisher<Void, APIError>
}

final class ServiceManagerImpl: ServiceManager, ObservableObject {
    private let session = URLSession.shared
    
    func performRequest<T>(_ request: T) -> AnyPublisher<String?, APIError> where T : Request {
        session.dataTaskPublisher(for: self.urlRequest(request))
            .tryMap { data, response in
                try self.validateResponse(response)
                return String(data: data, encoding: .utf8)
            }
            .mapError { error in
                self.transformError(error)
            }
            .eraseToAnyPublisher()
    }
    
    func performRequestNoReturn<T>(_ request: T) -> AnyPublisher<Void, APIError> where T : Request {
        session.dataTaskPublisher(for: self.urlRequest(request))
            .tryMap { data, response in
                try self.validateResponse(response)
            }
            .mapError { error in
                self.transformError(error)
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    private func validateResponse(_ response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.noData
        }
        guard 200 ... 299 ~= httpResponse.statusCode else {
            throw APIError.detailed(httpResponse.statusCode, nil)
        }
    }
    
    private func transformError(_ err: Error) -> APIError {
        if let apiError = err as? APIError {
            return apiError
        }
        return APIError.detailed((err as NSError).code, (err as NSError).localizedDescription)
    }
    
    private func urlRequest<T: Request>(_ request: T, cache: URLRequest.CachePolicy = .useProtocolCachePolicy) -> URLRequest {
        guard let url = URL(string: "\(request.host)\(request.path)") else {
            fatalError("ERROR! Cannot generate the URL")
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.httpMethod.rawValue
        urlRequest.allHTTPHeaderFields = request.headers
        urlRequest.httpBody = request.body
        urlRequest.cachePolicy = cache

        return urlRequest
    }
}
