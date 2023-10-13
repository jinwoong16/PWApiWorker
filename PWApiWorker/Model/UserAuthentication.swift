//
//  UserAuthentication.swift
//  PWApiWorker
//
//  Created by jinwoong Kim on 10/14/23.
//

import Foundation

/// An object where user information on the API server is located.
public protocol UserAuthentication {
    /// A user id from the api server.
    var userId: String { get }
    
    /// A user secret from the api server.
    var userSecret: String { get }
}

extension UserAuthentication {
    /// An encrypted string based on base64 encoding.
    public var encryptedString: String? {
        String(
            format: "%@:%@",
            userId,
            userSecret
        )
        .data(using: .utf8)?
        .base64EncodedString()
    }
}
