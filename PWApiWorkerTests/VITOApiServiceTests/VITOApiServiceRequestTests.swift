//
//  VITOApiServiceRequestTests.swift
//  PWApiWorkerTests
//
//  Created by jinwoong Kim on 12/6/23.
//

import XCTest

import XCTest
@testable import PWApiWorker

final class VITOApiServiceRequestTests: XCTestCase {
    private var vito: VITOApiService!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        vito = VITOApiService(
            userAuth: VITOObjectMock(),
            keychainHelper: KeychainHelperDummy(),
            session: .shared
        )
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        vito = nil
    }

    func test_request() async throws {
        guard let path = Bundle(for: PWApiWorkerTests.self).url(forResource: "last", withExtension: "m4a") else {
            XCTFail("Failed to load the audio file.")
            return
        }
        print(path)
        
        let result = await vito.request(with: path)
        
        print("result: \(result)")
    }
}
