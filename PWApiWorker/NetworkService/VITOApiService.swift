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
    
    // TODO: Request with audio and polling.
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
            let bodyData = createMultipartFormData(boundary: boundary) {
                MultipartFormDataComponent.file(
                    name: "file",
                    filename: "audio.p4a",
                    data: audioData
                )
                MultipartFormDataComponent.text(name: "config", value: "{}")
            }
            
            let endpoint: Endpoint<VitoResponse> = buildEndpoint(
                baseURL: baseURL,
                path: transcribePath,
                method: .POST,
                headers: [
                    .authorization(.bearer(token.token)),
                    .contentType(.multipartForm(boundary: boundary)),
                    .accept(.json)
                ],
                body: bodyData
            )
            
            // 4.
            let response = try await request(with: endpoint)
            let transcribeId = response.id

            // 5.
            let resultEndpoint: Endpoint<VitoTranscribeResponse> = buildEndpoint(
                baseURL: baseURL,
                path: "\(transcribePath)/\(transcribeId)",
                method: .GET,
                headers: [
                    .accept(.json),
                    .authorization(.bearer(token.token))
                ]
            )
            
            let transcribedData:Results = try await poll(interval: 5.0, timeout: 60.0, operation: { [weak self] in
                let response = try await self?.request(with: resultEndpoint)
                if let response = response,
                   let results = response.results {
                    return results
                } else {
                    return nil
                }
            })
            
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

    func requireAccess() async throws -> UserToken {
        let body = "client_id=\(userAuth.userId)&client_secret=\(userAuth.userSecret)".toData()
        
        let endpoint: Endpoint<VitoTokenBody> = buildEndpoint(
            baseURL: baseURL,
            path: authPath,
            method: .POST,
            headers: [
                .accept(.json),
                .contentType(.urlencoded)
            ],
            body: body
        )
        
        return try await requireAccess(with: endpoint, serviceName: serviceName)
    }
}

private extension VITOApiService {
    func createMultipartFormData(
        boundary: String,
        @MultipartFormDataBuilder body: () -> [MultipartFormDataComponent]
    ) -> Data {
        let components = body()
        let boundary = "Boundary-\(boundary)"
        var formData = Data()
        
        for component in components {
            formData.append("\(boundary)\r\n".toData())
            
            switch component {
                case .text(let name, let value):
                    formData.append("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n".toData())
                    formData.append("\(value)\r\n".toData())
                case .file(let name, let filename, let data):
                    formData.append("Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(filename)\"\r\n".toData())
                    formData.append("Content-Type: application/octet-stream\r\n\r\n".toData())
                    formData.append(data)
                    formData.append("\r\n".toData())
            }
        }
        formData.append("\(boundary)--\r\n".toData())
        
        return formData
    }
}
