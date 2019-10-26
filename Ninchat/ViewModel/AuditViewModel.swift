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
    private let auditService: AuditService
        
    init() {
        self.auditService = AuditServiceImpl()
    }
    
    func updateAuditLogServerLock() {
        _ = auditService.emptyAction()
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { _ in }, receiveValue: { [unowned self] offset in
                let currentOffset = Int(offset!.unwrapped)!
                self.auditService.burbleAction(offset: currentOffset)
                        .receive(on: RunLoop.main)
                        .flatMap { [unowned self] burbles  -> AnyPublisher<Void, APIError> in
                            let burblesComponents = burbles!.components(separatedBy: .newlines).dropLast()
                            self.auditLog = burblesComponents.joined(separator: "\n")
                            return self.auditService.chortleAction(offset: currentOffset + burblesComponents.count)
                        }
                        .receive(on: RunLoop.main)
                        .sink(receiveCompletion: { _ in }, receiveValue: { })
                        .cancel()
            })
    }
}
