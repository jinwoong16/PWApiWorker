//
//  TokenContainable.swift
//  PWApiWorker
//
//  Created by jinwoong Kim on 10/14/23.
//

import Foundation

public protocol TokenContainable: Decodable {
    var accessToken: String { get }
    var expireAt: String { get }
}
