import SwiftUI

struct LetterDetailView: View {
    @State var letter: Letter
    @State private var replies: [Letter] = []
    @State private var showReply = false
    @State private var isLoadingReplies = false
    @State private var aiCheer: AICheering? = nil

    
    var body: some View {
        VStack {
            if letter.isActuallyLocked {
                // 잠긴 상태
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
                // 열린 상태 (내용 + 답장)
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // 원본 편지 헤더
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
                        Divider()
                        
                        // 원본 편지 내용
                        Text(letter.content)
                            .font(.body)
                            .lineSpacing(6)
                            .padding(.vertical)
                        
                        Divider()
                        
                        // AI 분석 섹션
                        if let ai = aiCheer {
                                                VStack(alignment: .leading, spacing: 10) {
                                                    
                                                    Text("🧠 AI 응원 요약")
                                                        .font(.title3).bold()
                                                        .padding(.top)

                                                    Text(ai.overall_analysis)
                                                        .font(.body)
                                                        .padding(.bottom, 8)

                                                    Divider()

                                                    Text("💬 감정 분석 결과")
                                                        .font(.headline)

                                                    Text("• 감정: \(ai.sentiment_analysis.sentiment)")
                                                    Text("• 점수: \(ai.sentiment_analysis.score)")
                                                    Text("• 이유: \(ai.sentiment_analysis.reason)")
                                                        .padding(.bottom, 8)

                                                    Divider()
                                                    
                                                    Text("🎯 목표 분석")
                                                        .font(.headline)

                                                    Text("• 진행도: \(ai.goal_analysis.progress_percent)%")
                                                    Text("• 피드백: \(ai.goal_analysis.feedback)")
                                                    Text("• 다음 단계: \(ai.goal_analysis.next_step)")
                                                        .padding(.bottom, 8)

                                                    Divider()

                                                    Text("📣 응원 메시지")
                                                        .font(.headline)
                                                    
                                                    Text(makeEncouragement(ai))
                                                        .font(.body)
                                                        .padding(.bottom, 20)
                                                }
                                                .padding(.vertical)
                                            }

                                            Divider()
                        
                        // 답장 목록 (댓글처럼 표시)
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
                
                // 4. 답장하기 버튼
                Button(action: { showReply = true }) {
                    Text("답장 보내기")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding()
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
                fetchReplies() // 답장 불러오기
                decodeAiCheering()
            }
        }
        // 답장 보내고 돌아왔을 때 새로고침
        .onChange(of: showReply) { _, isShowing in
            if !isShowing {
                fetchReplies()
            }
        }
    }
    
    // 읽음 처리
    func markAsRead() {
        guard let url = URL(string: "http://124.56.5.77/fletter/ReadLetter.php") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = "lettersId=\(letter.lettersId)".data(using: .utf8)
        URLSession.shared.dataTask(with: request).resume()
    }
    
    // 답장 목록 불러오기
    func fetchReplies() {
        let urlString = "http://124.56.5.77/fletter/getReplies.php?parentId=\(letter.lettersId)"
        guard let url = URL(string: urlString) else { return }
        
        print("[답장 불러오기] 시작: \(urlString)")
        isLoadingReplies = true
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async { isLoadingReplies = false }
            
            if let error = error {
                print("[답장 에러] 네트워크 실패: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else { return }
            
            // 서버가 준 원본 데이터 확인
            if let rawString = String(data: data, encoding: .utf8) {
                print("[답장 원본 데이터]: \(rawString)")
            }
            
            do {
                let decoded = try JSONDecoder().decode([Letter].self, from: data)
                DispatchQueue.main.async {
                    self.replies = decoded
                    print("[답장 로딩 성공] 총 \(decoded.count)개의 답장을 가져왔습니다.")
                }
            } catch {
                print("[답장 디코딩 실패] 데이터 모양이 안 맞습니다: \(error)")
            }
        }.resume()
    }
    
    func decodeAiCheering() {
        guard let json = letter.aiCheering else { return }
        
        if let data = json.data(using: .utf8) {
            do {
                let decoded = try JSONDecoder().decode(AICheering.self, from: data)
                self.aiCheer = decoded
            } catch {
                print("[AI 디코딩 실패] \(error)")
            }
        }
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
                Image(systemName: "arrow.turn.down.right")
                    .foregroundColor(.gray)
                    .padding(.top, 5)
                
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(reply.senderNickName ?? "익명")
                            .font(.subheadline).bold()
                        Spacer()
                        Text(reply.arrivalDate, style: .date)
                            .font(.caption).foregroundColor(.gray)
                    }
                    
                    Text(reply.title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    // 답장 내용
                    Text(reply.content)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(10)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            }
            .padding(.vertical, 4)
        }
    }
}
