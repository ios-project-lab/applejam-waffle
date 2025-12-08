import SwiftUI

struct LetterDetailView: View {
    @State var letter: Letter
    @State private var replies: [Letter] = []
    @State private var showReply = false
    @State private var isLoadingReplies = false
    @State private var aiCheer: AICheering? = nil
  
    func getEmotionName(_ id: Int) -> String {
        switch id {
        case 1: return "기쁨 😊"
        case 2: return "슬픔 😢"
        case 3: return "분노 😡"
        case 4: return "불안 😟"
        case 5: return "평온 😌"
        case 6: return "설렘 🤩"
        default: return ""
        }
    }
    
    var body: some View {
        VStack {
            if letter.isActuallyLocked {
                // 잠긴 편지 UI
                Spacer()
                Image(systemName: "lock.circle.fill")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.orange)
                    .padding()
                
                Text("타임캡슐 편지입니다")
                    .font(.title).bold()
                
                Text("\(letter.arrivalDate, style: .date)에\n열어볼 수 있습니다.")
                    .multilineTextAlignment(.center)
                    .padding()
                    .foregroundColor(.gray)
                Spacer()
                
            } else {
                // 열린 편지 UI
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text(letter.title).font(.largeTitle).bold()
                            Spacer()
                        }
                        HStack {
                            Text("From. \(letter.senderNickName ?? "익명")")
                                .bold()
                            Spacer()
                            Text(letter.arrivalDate, style: .date)
                                .foregroundColor(.gray)
                        }
                        
                        // 감정 표시
                        let emotionText = getEmotionName(letter.emotionsId ?? 0)
                        if !emotionText.isEmpty {
                            HStack {
                                Text(emotionText)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.yellow.opacity(0.3))
                                    .foregroundColor(.orange)
                                    .cornerRadius(20)
                                Spacer()
                            }
                            .padding(.top, 4)
                        }
                        
                        Divider()
                        
                        // 내용
                        Text(letter.content)
                            .font(.body)
                            .lineSpacing(6)
                            .padding(.vertical)
                        
                        Divider()
                        
                        // AI 분석 섹션
                        if let ai = aiCheer {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("🧠 AI 응원 요약").font(.title3).bold().padding(.top)
                                Text(ai.overall_analysis).font(.body).padding(.bottom, 8)
                                Divider()
                                Text("💬 감정 분석 결과").font(.headline)
                                Text("• 감정: \(ai.sentiment_analysis.sentiment)")
                                Text("• 점수: \(ai.sentiment_analysis.score)")
                                Text("• 이유: \(ai.sentiment_analysis.reason)").padding(.bottom, 8)
                                Divider()
                                Text("🎯 목표 분석").font(.headline)
                                Text("• 진행도: \(ai.goal_analysis.progress_percent)%")
                                Text("• 피드백: \(ai.goal_analysis.feedback)")
                                Text("• 다음 단계: \(ai.goal_analysis.next_step)").padding(.bottom, 8)
                                Divider()
                                Text("📣 응원 메시지").font(.headline)
                                Text(makeEncouragement(ai)).font(.body).padding(.bottom, 20)
                            }
                            .padding(.vertical)
                        }
                        Divider()
                        
                        // 답장 목록
                        if !replies.isEmpty {
                            Text("답장 (\(replies.count))")
                                .font(.headline)
                                .padding(.top, 10)
                            ForEach(replies) { reply in
                                ReplyRow(reply: reply)
                            }
                        } else if isLoadingReplies {
                            ProgressView()
                        }
                        Spacer().frame(height: 50)
                    }
                    .padding()
                }
                
                Button(action: { showReply = true }) {
                    Text("답장 보내기")
                        .frame(maxWidth: .infinity).padding()
                        .background(Color.blue).foregroundColor(.white)
                        .cornerRadius(10).padding()
                }
            }
        }
        .navigationTitle(letter.isActuallyLocked ? "발송 중" : "편지 내용")
        .sheet(isPresented: $showReply) {
            LetterComposeView(replyToLetter: letter)
        }
        .onAppear {
            if !letter.isActuallyLocked {
                markAsRead()
                fetchReplies()
                decodeAiCheering()
            }
        }
        .onChange(of: showReply) { _, isShowing in
            if !isShowing { fetchReplies() }
        }
    }
    
    func markAsRead() {
        guard let url = URL(string: "http://124.56.5.77/fletter/ReadLetter.php") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = "lettersId=\(letter.lettersId)".data(using: .utf8)
        URLSession.shared.dataTask(with: request).resume()
    }
    
    func fetchReplies() {
        let urlString = "http://124.56.5.77/fletter/getReplies.php?parentId=\(letter.lettersId)"
        guard let url = URL(string: urlString) else { return }
        isLoadingReplies = true
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async { isLoadingReplies = false }
            if let data = data {
                do {
                    let decoded = try JSONDecoder().decode([Letter].self, from: data)
                    DispatchQueue.main.async { self.replies = decoded }
                } catch { print("답장 디코딩 에러: \(error)") }
            }
        }.resume()
    }
    
    func decodeAiCheering() {
        guard let jsonString = letter.aiCheering, !jsonString.isEmpty else { return }
        guard let data = jsonString.data(using: .utf8) else { return }
        do {
            let decoded = try JSONDecoder().decode(AICheering.self, from: data)
            DispatchQueue.main.async { self.aiCheer = decoded }
        } catch { print("AI 디코딩 에러: \(error)") }
    }
    
    func makeEncouragement(_ ai: AICheering) -> String {
        """
        지금 감정 상태는 "\(ai.sentiment_analysis.sentiment)" 이지만,
        너무 걱정하지 않아도 돼요!
        
        \(ai.sentiment_analysis.reason)
        
        앞으로 이렇게 하면 더 좋아질 거예요:
        \(ai.goal_analysis.next_step)
        
        언제든지 당신의 성장을 응원하고 있어요 😊
        """
    }

    struct ReplyRow: View {
        var reply: Letter
        var body: some View {
            HStack(alignment: .top) {
                Image(systemName: "arrow.turn.down.right").foregroundColor(.gray).padding(.top, 5)
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(reply.senderNickName ?? "익명").font(.subheadline).bold()
                        Spacer()
                        Text(reply.arrivalDate, style: .date).font(.caption).foregroundColor(.gray)
                    }
                    Text(reply.title).font(.subheadline).fontWeight(.semibold)
                    Text(reply.content).font(.subheadline).foregroundColor(.secondary)
                }
                .padding(10).background(Color.gray.opacity(0.1)).cornerRadius(8)
            }
            .padding(.vertical, 4)
        }
    }
}
