//
//  VITOApiService.swift
//  PWApiWorker
//
//  Created by jinwoong Kim on 10/14/23.
//

import Foundation
import PWKeychainKit
import PWNetworkingKit

public struct VITOApiService: AuthenticatedAudioAPIService {
    private let userAuth: UserAuthentication
    private let serviceName: String = "VITO"
    private let baseURL: String = "https://openapi.vito.ai"
    private let authPath: String = "/v1/authenticate"
    private let transcribePath: String = "/v1/transcribe"
    
    public var keychainHelper: KeychainHelper
    public var session: URLSession
    
    public init(
        userAuth: UserAuthentication,
        keychainHelper: KeychainHelper = DefaultKeychainHelper(.genericPassword),
        session: URLSession = .shared
    ) {
        self.userAuth = userAuth
        self.keychainHelper = keychainHelper
        self.session = session
    }
    
    // TODO: Request with audio and polling.
    public func request(with audioURL: URL) async -> String {
        do {
            let data = try transform(audio: audioURL)
            
        } catch {
            // TODO: Handling error by cases.
            print(error)
        }
    
        return ""
    }
}

private extension VITOApiService {
    func transform(audio: URL) throws -> Data {
        guard let data = try? Data(contentsOf: audio) else {
            throw VITOServiceError.fileNotFound
        }
        
        return data
    }
    
    func buildEndpoint<R: Decodable>(
        baseURL: String,
        path: String,
        method: HttpMethod,
        headers: [HttpHeader]? = nil,
        body: Data? = nil
    ) -> Endpoint<R> {
        Endpoint<R>(baseURL: baseURL, path: path, method: method, headers: headers, body: body)
    }
    
    func isValidToken(target: UserToken) -> Bool {
        return target.expireAt > Date().timeIntervalSince1970.description
    }

}
