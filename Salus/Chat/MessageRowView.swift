//
//  MessageRowView.swift
//  Salus
//
//  Created by Mikel on 8/4/24.
//  Based on Tutorial by Xcoding by ALfian
//  https://www.youtube.com/watch?v=PLEgTCT20zU&list=PLuecTl5TrGws7XyrBor8T0DoboJk6PBW0
//

import SwiftUI

struct MessageRowView: View {
    @Environment(\.colorScheme) private var colorScheme
    let message: MessageRow
    let retryCallback: (MessageRow) -> Void
    
    var body: some View {
        VStack(spacing:0){
            messageRow(text: message.sendText, image: message.sendImage, bgColor: Color("Background"))
            
            if message.responseText != nil {
                Divider()
                messageRow(text:message.responseText ?? "", image:message.responseImage  , bgColor:  Color("Background"), responseError: message.responseError, showDotLoading: message.isInteractingWithChatGPT)
                Divider()
            }
        
        }
       
    }
    
    func messageRow(text:String, image:String, bgColor: Color, responseError: String?=nil, showDotLoading: Bool = false) -> some View {
        HStack(alignment:.top, spacing:24){
            if image.hasPrefix("http"), let url = URL(string: image){
                AsyncImage(url:url){ image in
                    image
                        .resizable()
                        .frame(width:25,height:25)
                } placeholder: {
                    ProgressView()
                }
            } else {
                Image(image)
                    .resizable()
                    .frame(width:25,height:25)
            }
            
            VStack(alignment: .leading){
                if !text.isEmpty{
                    Text(text)
                        .multilineTextAlignment(.leading)
                        .textSelection(.enabled)
                }
                
                if let error = responseError{
                    Text("Error: \(error)")
                        .foregroundColor(Color.red)
                        .multilineTextAlignment(.leading)
                    Button("Regenerate Response"){
                        retryCallback(message)
                    }
                    .foregroundColor(.accentColor)
                    .padding(.top)
                }
                
                if showDotLoading {
                    DotLoadingView()
                        .frame(width:60,height:30)
                }
            }
            
        }
        .padding(16)
        .frame(maxWidth: .infinity,alignment: .leading)
        .background(bgColor)
        
    
    }
    
}


struct MessageRowView_Previews: PreviewProvider {
    
    static let message = MessageRow(
        isInteractingWithChatGPT:  true, sendImage: "Pug",
        sendText: "What is SwiftUI?",
        responseImage: "Salus",
        responseText: "It is a tool.")
    
    static let message2 = MessageRow(
        isInteractingWithChatGPT: false, sendImage: "Pug",
        sendText: "What is SwiftUI?",
        responseImage: "Salus",
        responseText: "",
        responseError: "ChatGPT is currently not available")
    
    static var previews: some View {
        NavigationStack {
            ScrollView {
                MessageRowView(message: message, retryCallback: { messageRow in
                    
                })
                
                MessageRowView(message: message2, retryCallback: { messageRow in
                    
                })
                
            }
            .previewLayout(.sizeThatFits)
        }
    }
}
