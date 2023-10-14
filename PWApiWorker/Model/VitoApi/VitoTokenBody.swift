//
//  VitoTokenBody.swift
//  PWApiWorker
//
//  Created by jinwoong Kim on 10/14/23.
//

import Foundation

struct VitoTokenBody: TokenContainable {
    var accessToken: String
    var expireAt: String
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case expireAt = "expire_at"
    }
}
