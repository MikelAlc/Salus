//
//  SettingsView.swift
//  Salus
//
//  Created by MikelAlc on 8/4/25.
//

import SwiftUI

struct SettingsView: View {
    @Binding var isTextToSpeechEnabled: Bool
    var speak: (String) -> Void
        
    var body: some View {
        ScrollView {
            Spacer()
            Toggle(isOn:    $isTextToSpeechEnabled) {
                Text("Text to Speech")
            }
            .onTapGesture {
                if(isTextToSpeechEnabled){
                    speak("Text to Speech")
                }
            }
            .onChange(of: isTextToSpeechEnabled){
                speak("Text to Speech, \(isTextToSpeechEnabled ? "Enabled" : "Disabled")")
            }.padding(.top, 50)
            .padding()
            Spacer()
            
        }
    }
}
    
