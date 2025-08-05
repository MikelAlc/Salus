//
//  ModelView.swift
//  Salus
//
//  Created by MikelAlc on 8/4/25.
//  Based on Tutorial by Xcoding by ALfian
//  https://www.youtube.com/watch?v=PLEgTCT20zU&list=PLuecTl5TrGws7XyrBor8T0DoboJk6PBW0
//

import Foundation
import SwiftUI
import AVFoundation

class ModelView: ObservableObject {
    @Published var isInteractingWithChatGPT = false
    @Published var messages: [MessageRow] = []
    @Published var inputMessage: String = ""
    
    private let speechSynth = AVSpeechSynthesizer()
    private let api: ChatGPTAPI
    
    
    init(api: ChatGPTAPI) {
        self.api = api
    }
    
    @MainActor
    func sendTapped(_ isTextToSpeechEnabled: Bool) async {
        let text = inputMessage
        inputMessage = ""
        await send(text, isTextToSpeechEnabled)
    }
    
    @MainActor
    func retry(_ message: MessageRow, _ isTextToSpeechEnabled: Bool) async{
        guard let index = messages.firstIndex(where: {$0.id == message.id}) else { return }
        self.messages.remove(at: index)
        await send(message.sendText,isTextToSpeechEnabled)
        
    }
    
    @MainActor
    private func send(_ text: String, _ isTextToSpeechEnabled: Bool) async{
        isInteractingWithChatGPT = true
        
        var streamText = ""
        var messageRow = MessageRow(isInteractingWithChatGPT: true, sendImage: "Pug", sendText: text, responseImage: "Salus", responseText: streamText, responseError: nil)
        
        self.messages.append(messageRow)
        
        do {
            let stream = try await api.sendMessageStream(text: text)
            for try await text in stream {
                streamText += text
               
                messageRow.responseText = streamText.trimmingCharacters(in: .whitespacesAndNewlines)
                self.messages[self.messages.count - 1] = messageRow
            }
            if(isTextToSpeechEnabled){
                speak(streamText)
            }
            
        } catch {
            messageRow.responseError = error.localizedDescription
        }
        
        messageRow.isInteractingWithChatGPT = false
        self.messages[self.messages.count - 1] = messageRow
        isInteractingWithChatGPT = false
        
    }
    
    func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        speechSynth.speak(utterance)
    }
    
    func stopSpeaking(){
        speechSynth.stopSpeaking(at: .immediate)
    }
}

