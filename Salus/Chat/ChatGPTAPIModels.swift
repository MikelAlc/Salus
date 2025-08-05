//
//  ChatGPTAPIModels.swift
//  Salus
//
//  Created by MikelAlc on 8/4/24.
//  Based on Tutorial by Xcoding by ALfian
//  https://www.youtube.com/watch?v=PLEgTCT20zU&list=PLuecTl5TrGws7XyrBor8T0DoboJk6PBW0
//

import Foundation

struct Message: Codable {
    let role: String
    let content: String
}

extension Array where Element == Message {
    var contentCount: Int { reduce(0,{ $0 + $1.content.count})}
}

struct Request: Codable {
    let model: String
    let temperature: Double
    let messages: [Message]
    let stream: Bool
}

struct ErrorRootResponse: Decodable{
    let error: ErrorResponse
}

struct ErrorResponse: Decodable{
    let message: String
    let type: String?
}

struct CompletionResponse: Decodable{
    let choices: [Choice]
    let usage: Usage?
}

struct StreamCompletionResponse: Decodable{
    let choices: [StreamChoice]
}

struct Usage: Decodable{
    let promptTokens: Int?
    let completionTokens: Int?
    let totalTokens: Int?
}

struct Choice: Decodable{
    let message: Message
    let finishReason: String?
}

struct StreamChoice: Decodable {
    let finishReason: String?
    let delta: StreamMessage
}

struct StreamMessage: Decodable {
    let role: String?
    let content: String
}
