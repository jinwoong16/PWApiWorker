//
//  VitoObject.swift
//  PWApiWorker
//
//  Created by jinwoong Kim on 11/14/23.
//

import Foundation

struct VitoObject: UserAuthentication {
    var userId: String {
        guard let id = Bundle.main.object(forInfoDictionaryKey: "CLIENT_VITO_ID") as? String else {
            fatalError("‼️ NO CLIENT VITO ID was found.")
        }
        return id
    }
    
    var userSecret: String {
        guard let secret = Bundle.main.object(forInfoDictionaryKey: "CLIENT_VITO_SECRET") as? String else {
            fatalError("‼️ NO CLIENT VITO SECRET was found.")
        }
        return secret
    }
}
