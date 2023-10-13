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
    
    func authenticate() throws
}
