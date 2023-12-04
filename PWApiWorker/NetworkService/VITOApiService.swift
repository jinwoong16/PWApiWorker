//
//  VITOApiService.swift
//  PWApiWorker
//
//  Created by jinwoong Kim on 10/14/23.
//

import Foundation
import PWKeychainKit
import PWNetworkingKit

public final class VITOApiService: AuthenticatedAudioAPIService, Pollingable {
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
    
    /// How to request with audio url?
    /// 1. request with audio url
    /// 2. check the token.
    ///     - if the token is not valid, request access and jump to 3
    ///     - if the token is valid, jump to 3
    /// 3. generate binary with audio url and build endpoint
    ///     with audio binary(into body) and token(into header)
    ///     - if failed to build, return an error message.
    /// 4. request transcribing.
    /// 5. poll every 5 secs until 60 seconds over or success
    ///     to retrive data
    /// 6. finally, return the text data.
    public func request(with audioURL: URL) async -> String {
        do {
            // 2.
            var token: UserToken = try keychainHelper.read(by: serviceName)
            
            if !isValidToken(target: token) {
                token = try await requireAccess()
            }
            
            // 3.
            let boundary = UUID().uuidString
            let audioData = try transform(audio: audioURL)
            let endpoint: Endpoint<VitoResponse> = .init(
                baseURL: baseURL,
                path: transcribePath,
                method: .POST,
                headers: [
                    .authorization(.bearer(token.token)),
                    .contentType(.multipartForm(boundary: boundary)),
                    .accept(.json)
                ],
                boundary: boundary
            ) {
                MultipartFormDataComponent.file(
                    name: "file",
                    filename: "audio.m4a",
                    data: audioData
                )
                MultipartFormDataComponent.text(name: "config", value: "{}")
            }
            
            // 4.
            let response = try await request(with: endpoint)
            let transcribeId = response.id
            
            // 5.
            let resultEndpoint: Endpoint<VitoTranscribeResponse> = .init(
                baseURL: baseURL,
                path: "\(transcribePath)/\(transcribeId)",
                method: .GET,
                headers: [
                    .accept(.json),
                    .authorization(.bearer(token.token))
                ]
            )
            
            let transcribedData: Results = try await poll(
                interval: 5.0,
                timeout: 60.0
            ) { [weak self] in
                let response = try await self?.request(with: resultEndpoint)
                if let response = response,
                   let results = response.results {
                    return results
                } else {
                    return nil
                }
            }
            
            return transcribedData
                .utterances
                .map { $0.msg }
                .joined(separator: " ")
        } catch {
            print(error)
            return "Empty by error"
        }
    }
}

private extension VITOApiService {
    func transform(audio: URL) throws -> Data {
        guard let data = try? Data(contentsOf: audio) else {
            throw VITOServiceError.fileNotFound
        }
        
        return data
    }
    
    func isValidToken(target: UserToken) -> Bool {
        return target.expireAt > Date().timeIntervalSince1970.description
    }
    
    func requireAccess() async throws -> UserToken {
        let endpoint: Endpoint<VitoTokenBody> = .init(
            baseURL: baseURL,
            path: authPath,
            method: .POST,
            headers: [
                .accept(.json),
                .contentType(.urlencoded)
            ],
            body: [
                "client_id": userAuth.userId,
                "client_secret": userAuth.userSecret
            ]
        )
        
        return try await requireAccess(with: endpoint, serviceName: serviceName)
    }
}
