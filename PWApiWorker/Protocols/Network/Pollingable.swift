//
//  Pollingable.swift
//  PWApiWorker
//
//  Created by jinwoong Kim on 11/14/23.
//

import Foundation

enum PollingError: Error {
    case taskCancelled
    case timeover
}

protocol Pollingable {
}

extension Pollingable {
    func poll<R: Decodable>(
        interval: Double,
        timeout: Double,
        operation: @escaping () async throws -> R?
    ) async throws -> R {
        let startedOn = Date()
        
        while(Date().timeIntervalSince(startedOn) < timeout) {
            if let data = try await operation() {
                return data
            }
            
            try? await Task.sleep(
                nanoseconds: UInt64(
                    (interval * 1_000_000_000).rounded(.up)
                )
            )
            
            if Task.isCancelled {
                throw PollingError.taskCancelled
            }
        }
        
        throw PollingError.timeover
    }
}
