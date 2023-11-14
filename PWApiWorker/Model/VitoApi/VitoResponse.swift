//
//  VitoResponse.swift
//  PWApiWorker
//
//  Created by jinwoong Kim on 11/14/23.
//

import Foundation

struct VitoResponse: Decodable {
    let id: String
}

struct VitoTranscribeResponse: Decodable {
    let id: String
    let status: String
    let results: Results?
}

struct Results: Decodable {
    let utterances: [Utterance]
}

struct Utterance: Decodable {
    let startAt: Int
    let duration: Int
    let msg: String
    let spk: Int
    
    enum CodingKeys: String, CodingKey {
        case startAt = "start_at"
        case duration, msg, spk
    }
}
