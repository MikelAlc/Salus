//
//  ChatView.swift
//  Salus
//
//  Created by MikelAlc on 8/4/25.
//  Based on Tutorial by Xcoding by ALfian
//  https://www.youtube.com/watch?v=PLEgTCT20zU&list=PLuecTl5TrGws7XyrBor8T0DoboJk6PBW0
//

import SwiftUI

struct ChatView: View {
    
    @ObservedObject var modelView: ModelView
    @FocusState var isTextFieldFocused: Bool
    @Binding var isTextToSpeechEnabled: Bool
    
    var body: some View {
        chatListView
            .navigationTitle("Salus")
    }
    
    var chatListView: some View {
        ScrollViewReader{proxy in
            VStack(spacing:0){
                ScrollView{
                    LazyVStack(spacing: 0){
                        ForEach(modelView.messages){ message in
                            MessageRowView(message: message){ message in
                                Task { @MainActor in
                                    await modelView.retry(message,isTextToSpeechEnabled)
                                }
                            }
                        }
                    }
                    .onTapGesture {
                        isTextFieldFocused = false
                    }
                }
                Divider()
                bottomView(image:"Pug",proxy: proxy)
                Spacer()
                Divider()
            }
            .onChange(of: modelView.messages.last?.responseText){
                scrollToBottom(proxy: proxy)
            }
        }
        .background(Color("Background"))
    }
    
    func bottomView(image: String, proxy: ScrollViewProxy) -> some View {
        HStack(alignment: .top, spacing: 8) {
            if image.hasPrefix("http"), let url = URL(string: image){
                AsyncImage(url:url){ image in
                    image
                        .resizable()
                        .frame(width:30,height:30)
                } placeholder: {
                    ProgressView()
                }
            } else {
                Image(image)
                    .resizable()
                    .frame(width:30,height:30)
            }
            
            TextField("Send Message", text: $modelView.inputMessage, axis:.vertical)
                .textFieldStyle(.roundedBorder)
                .focused($isTextFieldFocused)
                .disabled(modelView.isInteractingWithChatGPT)
            
            if modelView.isInteractingWithChatGPT {
                DotLoadingView().frame(width: 60, height:30)
            } else {
                Button {
                    Task{ @MainActor in
                        isTextFieldFocused = false
                        scrollToBottom(proxy: proxy)
                        await modelView.sendTapped(isTextToSpeechEnabled)
                    }
                } label: {
                    Image(systemName: "paperplane.circle.fill")
                        .rotationEffect(.degrees(45))
                        .font(.system(size: 30))
                }
                .disabled(modelView.inputMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding(.horizontal,16)
        .padding(.top,12)
        
    }
    
    private func scrollToBottom(proxy: ScrollViewProxy){
        guard let id = modelView.messages.last?.id else { return }
        proxy.scrollTo(id,anchor: .bottomTrailing)
    }
}

#Preview{
    ContentView()
}
