//
//  MessageRowView.swift
//  Insight
//
//  Created by Mikel on 12/7/24.
//

import SwiftUI

struct MessageRowView: View {
    @Environment(\.colorScheme) private var colorScheme
    let message: MessageRow
    let retryCallback: (MessageRow) -> Void
    
    var body: some View {
        VStack(spacing:0){
            messageRow(text: message.sendText, image: message.sendImage, bgColor: colorScheme == .light ? .white : Color(red:52/255,green:53/255,blue:65/255,opacity:0.5))
            
            if let text = message.responseText {
                Divider()
                messageRow(text:message.responseText ?? "", image:message.responseImage  , bgColor:  colorScheme == .light ? .white : Color(red:52/255,green:53/255,blue:65/255,opacity:1),responseError: message.responseError, showDotLoading: message.isInteractingWithChatGPT)
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
        responseImage: "Insight",
        responseText: "It is a tool.")
    
    static let message2 = MessageRow(
        isInteractingWithChatGPT: false, sendImage: "Pug",
        sendText: "What is SwiftUI?",
        responseImage: "Insight",
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
