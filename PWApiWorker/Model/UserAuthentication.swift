//
//  UserAuthentication.swift
//  PWApiWorker
//
//  Created by jinwoong Kim on 10/14/23.
//

import Foundation

/// An object where user information on the API server is located.
public struct UserAuthentication {
    /// A user id from the api server.
    var userId: String
    
    /// A user secret from the api server.
    var userSecret: String
    
    /// An encrypted string based on base64 encoding.
    var encryptedString: String? {
        String(
            format: "%@:%@",
            userId,
            userSecret
        )
        .data(using: .utf8)?
        .base64EncodedString()
    }
}
