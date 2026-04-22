import SwiftUI

struct MessagesView: View {
    @EnvironmentObject var vm: AppViewModel
    
    var body: some View {
        NavigationStack {
            Group {
                if vm.chatThreads.isEmpty {
                    EmptyStateView(icon: "message", title: "No Messages", subtitle: "Start chatting with a farmer by messaging them on their product page.")
                } else {
                    List {
                        ForEach(vm.chatThreads) { thread in
                            NavigationLink(destination: ChatView(thread: thread)) {
                                MessageRow(thread: thread)
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Messages")
            .background(Theme.background.ignoresSafeArea())
        }
    }
}

struct MessageRow: View {
    let thread: ChatThread
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle().fill(Color.gray.opacity(0.15)).frame(width: 52, height: 52)
                Image(systemName: "person.fill").foregroundColor(.gray).font(.title2)
                
                if thread.unreadCount > 0 {
                    Circle().fill(Color.red)
                        .frame(width: 18, height: 18)
                        .overlay(Text("\(thread.unreadCount)").font(.caption2).foregroundColor(.white))
                        .offset(x: 18, y: -18)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(thread.participantName).font(.headline)
                Text(thread.lastMessage)
                    .font(.subheadline).foregroundColor(.gray).lineLimit(1)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(thread.lastMessageTime.formatted(.relative(presentation: .numeric)))
                    .font(.caption2).foregroundColor(.gray)
                Image(systemName: thread.participantRole == .farmer ? "tractor.fill" : "cart.fill")
                    .font(.caption)
                    .foregroundColor(thread.participantRole == .farmer ? Theme.primary : Theme.accent)
            }
        }
        .padding(.vertical, 8)
    }
}

struct ChatView: View {
    @EnvironmentObject var vm: AppViewModel
    let thread: ChatThread
    @State private var messageText = ""
    @State private var localThread: ChatThread
    
    init(thread: ChatThread) {
        self.thread = thread
        _localThread = State(initialValue: thread)
    }
    
    var currentThread: ChatThread {
        vm.chatThreads.first(where: { $0.id == thread.id }) ?? thread
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Chat header
            HStack(spacing: 12) {
                ZStack {
                    Circle().fill(Color.gray.opacity(0.15)).frame(width: 40, height: 40)
                    Image(systemName: "person.fill").foregroundColor(.gray)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(currentThread.participantName).font(.headline)
                    Text(currentThread.participantRole.rawValue)
                        .font(.caption).foregroundColor(Theme.textLight)
                }
                Spacer()
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
            .background(Color.white)
            .shadow(color: Color.black.opacity(0.04), radius: 4, y: 2)
            
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(currentThread.messages) { message in
                            ChatBubble(message: message)
                                .id(message.id)
                        }
                    }
                    .padding()
                }
                .onChange(of: currentThread.messages.count) { _ in
                    if let last = currentThread.messages.last {
                        withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                    }
                }
            }
            
            // Input bar
            HStack(spacing: 10) {
                TextField("Type a message...", text: $messageText)
                    .padding(12)
                    .background(Color(.systemGray6))
                    .cornerRadius(20)
                
                Button(action: sendMessage) {
                    Circle()
                        .fill(messageText.isEmpty ? Color.gray.opacity(0.3) : Theme.accent)
                        .frame(width: 44, height: 44)
                        .overlay(Image(systemName: "paperplane.fill").foregroundColor(.white))
                }
                .disabled(messageText.isEmpty)
            }
            .padding()
            .background(Color.white)
        }
        .background(Theme.background.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("")
    }
    
    func sendMessage() {
        guard !messageText.isEmpty else { return }
        vm.sendMessage(threadId: thread.id, text: messageText)
        messageText = ""
    }
}

struct ChatBubble: View {
    let message: ChatMessage
    var body: some View {
        HStack {
            if message.isFromCurrentUser { Spacer(minLength: 60) }
            VStack(alignment: message.isFromCurrentUser ? .trailing : .leading, spacing: 4) {
                Text(message.text)
                    .padding(.horizontal, 14).padding(.vertical, 10)
                    .background(message.isFromCurrentUser ? Theme.primary : Color.white)
                    .foregroundColor(message.isFromCurrentUser ? .white : Theme.textDark)
                    .cornerRadius(18)
                    .shadow(color: Color.black.opacity(0.05), radius: 3, y: 2)
                Text(message.timestamp.formatted(date: .omitted, time: .shortened))
                    .font(.caption2).foregroundColor(Theme.textLight)
            }
            if !message.isFromCurrentUser { Spacer(minLength: 60) }
        }
    }
}
