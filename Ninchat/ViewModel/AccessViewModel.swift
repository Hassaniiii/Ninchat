//
//  ClockViewModel.swift
//  Ninchat
//
//  Created by Hassaniiii on 10/25/19.
//  Copyright © 2019 Hassaniiii. All rights reserved.
//

import Foundation
import Combine

final class AccessViewModel: ObservableObject {
    @Published var clock: String = ""
    private let accessService: AccessService
    private let clockService: ClockService
    private let auditViewModel: AuditViewModel
    
    init(auditViewModel: AuditViewModel) {
        self.auditViewModel = auditViewModel
        self.accessService = AccessServiceImpl()
        self.clockService = ClockServiceImpl()
        self.startServerObservation()
    }
    
    private func startServerObservation() {
        let timer = Timer(timeInterval: ServiceConstants.timeInterval, repeats: true) { [unowned self] _ in
            self.fetchClock()
        }
        RunLoop.main.add(timer, forMode: .common)
    }
    
    func fetchClock() {
        accessService.beginAccess()
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { [unowned self] error in
                self.error(error)
            }, receiveValue: { })
            .cancel()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(20)) {
            self.clockService.observe()
                .receive(on: RunLoop.main)
                .delay(for: .milliseconds(10), scheduler: RunLoop.main)
                .flatMap { [unowned self] in
                    self.accessService.endAccess()
                }
                .receive(on: RunLoop.main)
                .sink(receiveCompletion: { [unowned self] error in
                    self.error(error)
                }, receiveValue: { [unowned self] clock in
                    self.clock = clock?.unwrapped.toDateString ?? ""
                })
                .cancel()
        }
    }
    
    private func error(_ err: Subscribers.Completion<APIError>) {
        if case let .failure(fail) = err,
            case let .detailed(statusCode,_) = fail {
                        
            switch statusCode {
            case Reason.serviceUnavailable.rawValue:
                auditViewModel.updateAuditLogServerLock()
            default: break
            }
        }
    }
}
