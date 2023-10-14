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
}

public extension AuthenticatedService {
    @discardableResult
    func requireAccess<R: TokenContainable, E: Requestable & Responsable>(
        with endpoint: E,
        serviceName: String
    ) async throws -> UserToken where E.Response == R {
        let result = try await request(with: endpoint)
        let userToken = UserToken(service: serviceName, token: result.accessToken, expireAt: result.expireAt)
        try keychainHelper.save(item: userToken, service: serviceName)
        
        return userToken
    }
}
