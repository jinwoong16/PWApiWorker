//
//  MultipartFormDataBuilder.swift
//  PWApiWorker
//
//  Created by jinwoong Kim on 11/14/23.
//

import Foundation

@resultBuilder
struct MultipartFormDataBuilder {
    typealias Component = MultipartFormDataComponent
    
    static func buildBlock(_ components: Component...) -> [Component] {
        components
    }
}
