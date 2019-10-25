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
    
    private let accessService: AccessService = AccessServiceImpl()
    private let clockService: ClockService = ClockServiceImpl()
    private var cancellableSet: Set<AnyCancellable> = []
    private var auditViewModel: AuditViewModel
    
    init(auditViewModel: AuditViewModel) {
        self.auditViewModel = auditViewModel
        
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
            .store(in: &cancellableSet)
        
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
                .store(in: &self.cancellableSet)
        }
    }
    
    private func error(_ err: Subscribers.Completion<APIError>) {
        if case let .failure(fail) = err,
            case let .detailed(statusCode,_) = fail {
            cancellableSet.forEach { $0.cancel() }
                        
            switch statusCode {
            case Reason.serviceUnavailable.rawValue:
                auditViewModel.setChortle()
            default: break
            }
        }
    }
}
