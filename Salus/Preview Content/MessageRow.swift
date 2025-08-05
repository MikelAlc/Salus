//
//  MessageRow.swift
//  Salus
//
//  Created by MikelAlc on 8/4/25.
//  Based on Tutorial by Xcoding by ALfian
//  https://www.youtube.com/watch?v=PLEgTCT20zU&list=PLuecTl5TrGws7XyrBor8T0DoboJk6PBW0
//

import SwiftUI

struct MessageRow: Identifiable {
    let id = UUID()
    
    var isInteractingWithChatGPT: Bool
    
    let sendImage: String
    let sendText: String
    
    let responseImage: String
    var responseText: String?
    
    var responseError: String?
    
}




