//
//  UserAuthentication.swift
//  PWApiWorker
//
//  Created by jinwoong Kim on 10/14/23.
//

import Foundation

public struct UserAuthentication {
    var userId: String
    var userSecret: String
    
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
