import SwiftUI

struct Emotion: Identifiable, Hashable {
    let id: Int
    let name: String
}

let emotions = [
    Emotion(id: 1, name: "기쁨 😊"),
    Emotion(id: 2, name: "슬픔 😢"),
    Emotion(id: 3, name: "분노 😡"),
    Emotion(id: 4, name: "불안 😟"),
    Emotion(id: 5, name: "평온 😌"),
    Emotion(id: 6, name: "설렘 🤩")
]

struct LetterComposeView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.presentationMode) var presentationMode
    
    var replyToLetter: Letter? = nil
    
    @State private var receiverIdInput: String = ""
    @State private var sendType = 0
    @State private var title = ""
    @State private var content = ""
    @State private var receiveDate = Date()
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var selectedGoalId: Int? = nil
    @State private var selectedEmotionId: Int? = nil
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    // 받는 사람
                    Section(header: Text("받는 사람")) {
                        if let original = replyToLetter {
                            Text("To: \(original.senderNickName ?? "알 수 없음") (답장)")
                                .foregroundColor(.gray)
                        } else {
                            Picker("대상", selection: $sendType) {
                                Text("미래의 나").tag(0)
                                Text("친구").tag(1)
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            
                            if sendType == 1 {
                                TextField("친구 아이디 입력", text: $receiverIdInput).autocapitalization(.none)
                            }
                        }
                    }
                    
                    // 답장이 아닐 때만(새 편지일 때만) 표시되는 항목들
                    if replyToLetter == nil {
                        
                        // 도착 예정일
                        Section(header: Text("도착 예정일")) {
                            DatePicker("언제 도착할까요?", selection: $receiveDate, in: Date()..., displayedComponents: [.date])
                        }
                        
                        // 감정 선택 (답장 시 숨김)
                        Section(header: Text("편지에 담긴 감정")) {
                            Picker("감정 선택", selection: $selectedEmotionId) {
                                Text("선택 안 함").tag(nil as Int?)
                                ForEach(emotions, id: \.self) { emotion in
                                    Text(emotion.name).tag(emotion.id as Int?)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                        }
                        
                        // 목표 선택 (답장 시 숨김)
                        Section(header: Text("어떤 목표를 위한 편지인가요?")) {
                            if appState.goals.isEmpty {
                                Text("목표 불러오는 중...").foregroundColor(.gray)
                            } else {
                                Picker("목표 선택", selection: $selectedGoalId) {
                                    Text("선택 안 함").tag(nil as Int?)
                                    ForEach(appState.goals) { goal in
                                        Text(goal.title).tag(goal.goalsId as Int?)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                            }
                        }
                    }
                    
                    // 내용 입력 (항상 표시)
                    Section(header: Text("편지 내용")) {
                        TextField("제목", text: $title)
                        TextEditor(text: $content).frame(height: 200)
                    }
                }
                
                Button { sendLetter() } label: {
                    HStack {
                        if isLoading { ProgressView() }
                        Text("편지 보내기").bold()
                    }
                    .frame(maxWidth: .infinity).padding()
                    .background(Color.yellow).foregroundColor(.white).cornerRadius(8)
                }
                .disabled(isLoading).padding()
            }
            .navigationTitle(replyToLetter == nil ? "편지 쓰기" : "답장 쓰기")
            .onAppear {
                // 답장이 아닐 때만 목표를 불러옴
                if replyToLetter == nil {
                    fetchGoals()
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("알림"), message: Text(alertMessage), dismissButton: .default(Text("확인")))
            }
        }
    }
    
    func fetchGoals() {
        guard let myUser = appState.currentUser else { return }
        if !appState.goals.isEmpty { return }
        
        let urlString = "http://124.56.5.77/fletter/getGoals.php?userId=\(myUser.usersId)"
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    let decodedGoals = try JSONDecoder().decode([Goal].self, from: data)
                    DispatchQueue.main.async {
                        appState.goals = decodedGoals
                    }
                } catch {
                    print("디코딩 실패: \(error)")
                }
            }
        }.resume()
    }
    
    func sendLetter() {
        guard let myUser = appState.currentUser else { return }
        
        var finalReceiverId: String
        if let original = replyToLetter {
            finalReceiverId = original.senderUserId ?? original.senderNickName ?? ""
            receiveDate = Date()
        } else {
            if sendType == 0 { finalReceiverId = myUser.id }
            else {
                if receiverIdInput.isEmpty { showAlert = true; alertMessage = "ID 입력"; return }
                finalReceiverId = receiverIdInput
            }
        }
        
        if title.isEmpty || content.isEmpty { showAlert = true; alertMessage = "내용 입력"; return }
        
        guard let url = URL(string: "http://124.56.5.77/fletter/LetterCompose.php") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateStr = formatter.string(from: receiveDate)
        
        let parentId = replyToLetter?.lettersId ?? 0
        let goalIdValue = selectedGoalId ?? 0
        let emotionIdValue = selectedEmotionId ?? 0
        
        let body = "senderId=\(myUser.usersId)&receiverId=\(finalReceiverId)&title=\(title)&content=\(content)&expectedArrivalTime=\(dateStr)&parentLettersId=\(parentId)&goalId=\(goalIdValue)&emotionsId=\(emotionIdValue)"
        
        request.httpBody = body.data(using: .utf8)
        isLoading = true
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async { isLoading = false }
            if let data = data, let str = String(data: data, encoding: .utf8) {
                DispatchQueue.main.async {
                    if str.contains("success") {
                        alertMessage = "성공!"
                        showAlert = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { presentationMode.wrappedValue.dismiss() }
                    } else {
                        alertMessage = "실패: \(str)"
                        showAlert = true
                    }
                }
            }
        }.resume()
    }
}
