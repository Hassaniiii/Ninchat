//
//  AccessService.swift
//  Ninchat
//
//  Created by Hassaniiii on 10/25/19.
//  Copyright © 2019 Hassaniiii. All rights reserved.
//

import Foundation
import Combine

protocol AccessService {
    func beginAccess() -> AnyPublisher<Void, APIError>
    func endAccess() -> AnyPublisher<String?, APIError>
}

final class AccessServiceImpl: AccessService {
    
    private let serviceManager: ServiceManager = ServiceManagerImpl()
    
    func beginAccess() -> AnyPublisher<Void, APIError> {
        let request = AccessRequest(act: "begin", nonce: String.randomNumberGenerator)
        return serviceManager.performRequestNoReturn(request)
    }
    
    func endAccess() -> AnyPublisher<String?, APIError> {
        let request = AccessRequest(act: "end", nonce: String.randomNumberGenerator, timeout: 0)
        return serviceManager.performRequest(request)
    }
}
