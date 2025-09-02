//
//  ChatGPTAPI.swift
//  Salus
//
//  Created by MikelAlc on 8/4/25.
//  Based on Tutorial by Xcoding by ALfian
//  https://www.youtube.com/watch?v=PLEgTCT20zU&list=PLuecTl5TrGws7XyrBor8T0DoboJk6PBW0
//

import Foundation

class ChatGPTAPI {
    private let systemMessage: Message
    private let temperature: Double
    private let model: String
    
    private let apiKey: String
    private var historyList = [Message]()
    private let urlSession = URLSession.shared
    private var urlRequest: URLRequest{
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        headers.forEach { urlRequest.setValue($1, forHTTPHeaderField: $0)}
        
        return urlRequest
    }
    
    private let jsonDecoder:JSONDecoder = {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        return jsonDecoder
    }()

    
    private var headers: [String: String] {
        [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(apiKey)"
        ]
    }
    

    
    init(apiKey: String, model: String = "gpt-4o", systemPrompt: String = "You are Salus, a large language model that educates the user about health and how to lose weight. Answer with max 256 tokens. If a language is mentioned respond in that language.\n\n\n", temperature: Double = 0.1) {
        self.apiKey = apiKey
        self.model = model
        self.systemMessage = .init(role:"system",content:systemPrompt)
        self.temperature = temperature
        
    }
    
    private func generateMessages(from text: String) -> [Message] {
        var messages = [systemMessage] + historyList + [Message(role:"user", content: text)]
        
        if messages.contentCount > (4000 * 4){
            _ = historyList.dropFirst()
            messages = generateMessages(from: text)
        }
        
        return messages
    }
    
    private func jsonBody(text: String, stream: Bool = true) throws -> Data {
        let request = Request(model:model, temperature: temperature, messages: generateMessages(from: text), stream: stream)
        return try JSONEncoder().encode(request)
    }
    
    private func appendToHistoryList(userText: String, responseText: String){
        self.historyList.append(.init(role: "user", content: userText))
        self.historyList.append(.init(role: "assistant", content: responseText))
    }
    
    
    func sendMessageStream(text: String) async throws-> AsyncThrowingStream<String,Error> {
        var urlRequest = self.urlRequest
        urlRequest.httpBody = try jsonBody(text: text, stream: true)
        
        let (result,response) = try await urlSession.bytes(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw "invalid response"
        }
        
        guard 200...299 ~= httpResponse.statusCode else {
            var errorText = ""
            for try await line in result.lines {
                try Task.checkCancellation()
                errorText += line
            }
            
            if let data = errorText.data(using: .utf8), let errorResponse = try? jsonDecoder.decode(ErrorRootResponse.self, from: data).error {
                errorText = "\n\(errorResponse.message)"
            }
            
            throw "Bad Response: \(httpResponse.statusCode), \(errorText)"
        }
        
        return AsyncThrowingStream<String, Error> {  continuation in
            Task(priority:.userInitiated){ [weak self] in
                guard let self else {return}
                do{
                    var responseText = ""
                    for try await line in result.lines{
                        if line.hasPrefix("data:"),
                           let data = line.dropFirst(6).data(using: .utf8),
                           let response = try? self.jsonDecoder.decode(StreamCompletionResponse.self, from: data),
                           let text = response.choices.first?.delta.content {
                            responseText+=text
                            continuation.yield(text)
                        }
                    }
                    self.appendToHistoryList(userText: text, responseText: responseText)
                    continuation.finish()
                }catch{
                    continuation.finish(throwing: error)
                }
            }
        }
    }
    
    func sendMessage(_ text: String) async throws -> String{
        var urlRequest = self.urlRequest
        urlRequest.httpBody = try jsonBody(text: text, stream: false)
        
        let (data,response) = try await urlSession.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw "invalid response"
        }
        
        guard 200...299 ~= httpResponse.statusCode else {
            var error = "Bad Response: \(httpResponse.statusCode)"
            if let errorResponse = try? jsonDecoder.decode(ErrorRootResponse.self, from: data).error{
                error.append("\n\(errorResponse.message)")
            }
            throw error
        }
        
        do {
            let completionResponse = try self.jsonDecoder.decode(CompletionResponse.self, from: data)
            let responseText = completionResponse.choices.first?.message.content ?? ""
            self.appendToHistoryList(userText: text, responseText: responseText)
            return responseText
        }catch{
            throw error
        }
    }
    
    func deleteHistoryList(){
        self.historyList.removeAll()
    }
}

extension String: @retroactive Error {}
extension String: @retroactive CustomNSError {
    public var errorUserInfo: [String: Any]{
        [
            NSLocalizedDescriptionKey: self
        ]
    }
}
