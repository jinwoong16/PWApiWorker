//
//  MultipartFormDataComponent.swift
//  PWApiWorker
//
//  Created by jinwoong Kim on 11/14/23.
//

import Foundation

enum MultipartFormDataComponent {
    case text(name: String, value: String)
    case file(name: String, filename: String, data: Data)
}
