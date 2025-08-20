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
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var manager: HealthManager
    @Query private var items: [Item]
    

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
                }.tag(0)
            
            StatisticsView()
                .tabItem {
                    Image(systemName: "chart.bar")
                    Text("Stats")
                }.tag(1)
                .environmentObject(manager)
            
           
            NavigationSplitView {
                List {
                    ForEach(items) { item in
                        NavigationLink {
                            Text("Item at \(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))")
                        } label: {
                            Text(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))
                        }
                    }
                    .onDelete(perform: deleteItems)
                }
                .toolbar {
                    ToolbarItem{
                        Button(action: scheduleNotification) {
                            Label("Test",systemImage: "bell")
                        }
                    }
                    ToolbarItem {
                        Button(action: addItem) {
                            Label("Add Item", systemImage: "plus")
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        EditButton()
                    }
                    
                }
            } detail: {
                Text("Select an item")
            } .onAppear{
                requestNotificationPermission()
            }.tabItem {
                Image(systemName:"bell")
                Text("Notifs")
            }.tag(2)
            
            SettingsView(isTextToSpeechEnabled: $isTextToSpeechEnabled, speak: speak)
                .tabItem{
                    Image(systemName: "gearshape.fill")
                    Text("Settings")
                }.tag(3)
        }.onChange(of: selectedTab){
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

    private func addItem() {
        withAnimation {
            let newItem = Item(timestamp: Date())
            modelContext.insert(newItem)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.sound,.badge]){
            (granted,error) in
        }
          
    }
    
    private func scheduleNotification(){
                       
        let content = UNMutableNotificationContent()
        content.title = "Hey listen"
        content.body = "QUACK!"
        content.sound = UNNotificationSound.defaultCritical
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request){ error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
            
        }
        
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
