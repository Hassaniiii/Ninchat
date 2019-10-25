//
//  AuditViewModel.swift
//  Ninchat
//
//  Created by Hassaniiii on 10/25/19.
//  Copyright © 2019 Hassaniiii. All rights reserved.
//

import Foundation
import Combine

final class AuditViewModel: ObservableObject {
    @Published var auditLog: String = ""
    
    private let auditService: AuditService = AuditServiceImpl()
    private var cancellableSet: Set<AnyCancellable> = []
    private var auditLogLen: Int = 0
    
    init() {
        let timer = Timer(fire: Date().addingTimeInterval(0.500), interval: ServiceConstants.timeInterval, repeats: true) { [unowned self] _ in
            self.getBurbles()
        }
        RunLoop.main.add(timer, forMode: .common)
    }
    
    func getBurbles() {
        auditService.emptyAction()
            .receive(on: RunLoop.main)
            .flatMap { [unowned self] offset -> AnyPublisher<String?, APIError> in
                let currentOffset = Int(offset!.unwrapped)!
                return self.auditService.burbleAction(offset: currentOffset)
            }
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { [unowned self] completion in
                self.parse(completion)
            }, receiveValue: { [unowned self] burbles in
                let burblesComponents = burbles!.components(separatedBy: .newlines).dropLast()
                self.auditLogLen = burblesComponents.count
                self.auditLog = burblesComponents.joined(separator: "\n")
            })
            .store(in: &cancellableSet)
    }
    
    func setChortle() {
        auditService.emptyAction()
            .receive(on: RunLoop.main)
            .flatMap { [unowned self] offset -> AnyPublisher<Void, APIError> in
                let newOffset = Int(offset!.unwrapped)! + self.auditLogLen
                return self.auditService.chortleAction(offset: newOffset)
            }
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { [unowned self] completion in
                self.parse(completion)
            }, receiveValue: { })
            .store(in: &cancellableSet)
    }
    
    private func parse(_ err: Subscribers.Completion<APIError>) {
        if case .failure(_) = err {
            self.cancellableSet.forEach { $0.cancel() }
        }
    }
}
