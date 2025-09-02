//
//  ContentView.swift
//  Salus
//
//  Created by MikelAlc on 7/16/25.
//

import AVFoundation
import SwiftUI
import SwiftData
import UserNotifications

struct ContentView: View {
    
    //ChatView
    @StateObject private var modelView = ModelView(api: ChatGPTAPI(apiKey: Secrets.apiKey))
    private let speechSynth = AVSpeechSynthesizer()
    @State private var isTextToSpeechEnabled = false
    
    //StatsView
    @EnvironmentObject var healthManager: HealthManager
    
    @State private var selectedTab = 0
    
    func speak(text: String){
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        speechSynth.speak(utterance)
    }

    var body: some View {
        
        TabView(selection: $selectedTab) {
            NavigationStack{
                ChatView(modelView: modelView, isTextToSpeechEnabled: $isTextToSpeechEnabled)
            }
                .tabItem(){
                    Image(systemName: "ellipsis.message.fill")
                    Text("Chat")
                }.tag("Chat")
            
            StatisticsView()
                .tabItem {
                    Image(systemName: "chart.bar")
                    Text("Stats")
                }.tag(1)
                .environmentObject(healthManager)
            
            NotificationsView()
               .tabItem {
                    Image(systemName:"bell")
                    Text("Notifs")
                }.tag(2)
                
            SettingsView(isTextToSpeechEnabled: $isTextToSpeechEnabled, speak: speak)
                .tabItem{
                    Image(systemName: "gearshape.fill")
                    Text("Settings")
                }.tag(3)
        }.onChange(of: selectedTab){
            speakTabName()
        }
    }
    
    func speakTabName() {
        modelView.stopSpeaking()
        if(self.isTextToSpeechEnabled){
            let textToSpeak: String
            switch selectedTab{
            case 0:
                textToSpeak = "Chat"
            case 1:
                textToSpeak = "Stats"
            case 2:
                textToSpeak = "Notifications"
            case 3:
                textToSpeak = "Settings"
            default:
                textToSpeak = "Oh no, something went wrong!"
            }
            
            speak(text: textToSpeak)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
