import SwiftUI

struct AIChatBotView: View {
    @EnvironmentObject var vm: AppViewModel
    @State private var messageText = ""
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                // Chat Header
                HStack {
                    VStack(alignment: .leading) {
                        Text("Farmers Connect AI")
                            .font(.headline)
                        Text("Powered by Gemini Flash")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                
                // Chat Area
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(vm.aiChatHistory) { message in
                                ChatBubbleView(message: message)
                                    .id(message.id)
                            }
                            
                            if vm.isAILoading {
                                HStack {
                                    ProgressView()
                                        .padding(.trailing, 4)
                                    Text("Gemini is thinking...")
                                        .font(.caption)
                                        .italic()
                                    Spacer()
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding()
                    }
                    .onChange(of: vm.aiChatHistory.count) { _ in
                        withAnimation {
                            proxy.scrollTo(vm.aiChatHistory.last?.id, anchor: .bottom)
                        }
                    }
                }
                
                // Input Area
                HStack {
                    TextField("Ask about Crops, Weather, or Markets...", text: $messageText)
                        .padding(12)
                        .background(Color(.systemGray6))
                        .cornerRadius(20)
                    
                    Button(action: {
                        guard !messageText.isEmpty else { return }
                        vm.sendAIChatMessage(messageText)
                        messageText = ""
                    }) {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.green)
                            .clipShape(Circle())
                    }
                    .disabled(vm.isAILoading)
                }
                .padding()
            }
            .navigationBarHidden(true)
        }
    }
}

struct ChatBubbleView: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isFromCurrentUser { Spacer() }
            
            Text(message.text)
                .padding(12)
                .background(message.isFromCurrentUser ? Color.green : Color(.systemGray5))
                .foregroundColor(message.isFromCurrentUser ? .white : .primary)
                .cornerRadius(16)
                .overlay(
                    Text(message.senderName)
                        .font(.system(size: 8))
                        .foregroundColor(.gray)
                        .offset(y: 12),
                    alignment: .bottomTrailing
                )
            
            if !message.isFromCurrentUser { Spacer() }
        }
    }
}

#Preview {
    AIChatBotView()
        .environmentObject(AppViewModel())
}
