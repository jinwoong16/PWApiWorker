//
//  String+.swift
//  PWApiWorker
//
//  Created by jinwoong Kim on 11/14/23.
//

import Foundation

extension String {
    func toData() -> Data {
        Data(self.utf8)
    }
}
