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
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.accessToken = try container.decode(String.self, forKey: .accessToken)
        
        do {
            self.expireAt = try String(container.decode(Int.self, forKey: .expireAt))
        } catch {
            self.expireAt = try container.decode(String.self, forKey: .expireAt)
        }
    }
    
}
