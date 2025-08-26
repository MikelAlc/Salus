//
//  NotificationsView.swift
//  Salus
//
//  Created by Mikel on 7/28/25.
//

import SwiftUI
import SwiftData

struct NotificationsView: View {
    @Query private var items: [Item]
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        NavigationSplitView {
            List {
                ForEach(items) { item in
                    NavigationLink {
                        Text("Item at \(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))")
                    } label: {
                        Text(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))
                    }
                    .listRowBackground(Color(.systemGray4))
                    
                }
                .onDelete(perform: deleteItems)
            }
            .scrollContentBackground(.hidden)
            .background(Color("Background"))
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
    NotificationsView()
        .modelContainer(for: Item.self, inMemory: true)
}
