//
//  AuthenticatedService.swift
//  PWApiWorker
//
//  Created by jinwoong Kim on 10/14/23.
//

import Foundation
import PWNetworkingKit
import PWKeychainKit

public protocol AuthenticatedService: APIService {
    var keychainHelper: KeychainHelper { get }
    var userAuth: UserAuthentication { get }
    
    func requireAccess<R: Decodable, E: Requestable & Responsable>(
        with endpoint: E
    ) async throws -> UserToken where E.Response == R
}
