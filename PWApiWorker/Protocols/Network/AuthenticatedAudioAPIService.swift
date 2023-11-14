//
//  AuthenticatedAudioAPIService.swift
//  PWApiWorker
//
//  Created by jinwoong Kim on 10/14/23.
//

import Foundation

public protocol AuthenticatedAudioAPIService: AuthenticatedService {
    func request(with audioURL: URL) async -> String
}
