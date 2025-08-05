//
//  Secrets.swift
//  Salus
//
//  Created by MikelAlc on 8/4/25.
//

import Foundation

enum Secrets {
    static var apiKey: String {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "API_KEY") as? String else {
            fatalError("API_KEY not set in build settings")
        }
        return key
    }
}
