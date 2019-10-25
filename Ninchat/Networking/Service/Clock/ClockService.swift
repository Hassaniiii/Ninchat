//
//  ClockService.swift
//  Ninchat
//
//  Created by Hassaniiii on 10/25/19.
//  Copyright © 2019 Hassaniiii. All rights reserved.
//

import Foundation
import Combine

protocol ClockService {
    func observe() -> AnyPublisher<Void, APIError>
}

final class ClockServiceImpl: ClockService {
    
    private let serviceManager: ServiceManager = ServiceManagerImpl()
    
    func observe() -> AnyPublisher<Void, APIError> {
        let request = ClockRequest(act: "observe", nonce: String.randomNumberGenerator)
        return serviceManager.performRequestNoReturn(request)
    }
}
