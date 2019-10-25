//
//  AuditService.swift
//  Ninchat
//
//  Created by Hassaniiii on 10/25/19.
//  Copyright © 2019 Hassaniiii. All rights reserved.
//

import Foundation
import Combine

protocol AuditService {
    func emptyAction() -> AnyPublisher<String?, APIError>
    func burbleAction(offset: Int) -> AnyPublisher<String?, APIError>
    func chortleAction(offset: Int) -> AnyPublisher<Void, APIError>
}

final class AuditServiceImpl: AuditService {
    
    private let serviceManager: ServiceManager = ServiceManagerImpl()
    
    func emptyAction() -> AnyPublisher<String?, APIError> {
        let request = AuditRequest(act: "", nonce: String.randomNumberGenerator)
        return serviceManager.performRequest(request)
    }
    
    func burbleAction(offset: Int) -> AnyPublisher<String?, APIError> {
        let request = AuditRequest(act: "burble", nonce: String.randomNumberGenerator, offset: offset)
        return serviceManager.performRequest(request)
    }
    
    func chortleAction(offset: Int) -> AnyPublisher<Void, APIError> {
        let request = AuditRequest(act: "chortle", nonce: String.randomNumberGenerator, offset: offset)
        return serviceManager.performRequestNoReturn(request)
    }
}
