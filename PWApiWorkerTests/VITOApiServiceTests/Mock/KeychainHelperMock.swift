//
//  KeychainHelperMock.swift
//  PWApiWorkerTests
//
//  Created by jinwoong Kim on 12/6/23.
//

import Foundation
import PWKeychainKit
@testable import PWApiWorker

struct ReadMock: Decodable {}

struct KeychainHelperDummy: KeychainHelper {
    func read<T>(by service: String) throws -> T where T : Decodable {
        UserToken(
            service: service,
            token: "",
            expireAt: Date(timeIntervalSinceReferenceDate: -123456789.0).description
        ) as! T
    }
    
    func save<T>(item: T, service: String) throws where T : Decodable, T : Encodable {
        
    }
    
    func delete(by service: String) throws {
        
    }
}
