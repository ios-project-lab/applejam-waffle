import SwiftUI

struct LetterComposeView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.presentationMode) var presentationMode
    
    var replyToLetter: Letter? = nil
    
    @State private var receiverIdInput: String = ""
    @State private var sendType = 0 // 0: 나, 1: 친구
    @State private var title = ""
    @State private var content = ""
    @State private var receiveDate = Date()
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
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
                                TextField("친구 아이디 입력", text: $receiverIdInput)
                                    .autocapitalization(.none)
                            }
                        }
                    }
                    
                    Section(header: Text("도착 예정일")) {
                        DatePicker("언제 도착할까요?", selection: $receiveDate, in: Date()..., displayedComponents: [.date])
                        Text("설정된 날짜까지 편지는 잠김 상태가 됩니다.")
                            .font(.caption).foregroundColor(.gray)
                    }
                    
                    Section(header: Text("편지 내용")) {
                        TextField("제목", text: $title)
                        TextEditor(text: $content).frame(height: 200)
                    }
                }
                
                Button {
                    sendLetter()
                } label: {
                    HStack {
                        if isLoading { ProgressView() }
                        Text("편지 보내기").bold()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.yellow)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .disabled(isLoading)
                .padding()
                
                Spacer().frame(height: 20)
            }
            .navigationTitle(replyToLetter == nil ? "편지 쓰기" : "답장 쓰기")
            .alert(isPresented: $showAlert) {
                Alert(title: Text("알림"), message: Text(alertMessage), dismissButton: .default(Text("확인")))
            }
        }
    }
    
    func sendLetter() {
        guard let myUser = appState.currentUser else { return }
        
        let finalReceiverId: String
        
        // 받는 사람 아이디 결정
        if let original = replyToLetter {
            // 답장: 원본 보낸 사람의 ID 사용 (우선순위: userId > nickName)
            finalReceiverId = original.senderUserId ?? original.senderNickName ?? ""
        } else {
            // 나(0) 또는 친구(1)
            if sendType == 0 {
                finalReceiverId = myUser.id
            } else {
                if receiverIdInput.isEmpty {
                    alertMessage = "받는 사람 아이디를 입력해주세요."
                    showAlert = true; return
                }
                finalReceiverId = receiverIdInput
            }
        }
        
        if title.isEmpty || content.isEmpty {
            alertMessage = "제목과 내용을 입력해주세요."
            showAlert = true; return
        }
        
        guard let url = URL(string: "http://124.56.5.77/fletter/LetterCompose.php") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateStr = formatter.string(from: receiveDate)
        let parentId = replyToLetter?.lettersId ?? 0
        
        let body = "senderId=\(myUser.usersId)&receiverId=\(finalReceiverId)&title=\(title)&content=\(content)&expectedArrivalTime=\(dateStr)&parentLettersId=\(parentId)"
        
        request.httpBody = body.data(using: .utf8)
        isLoading = true
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async { isLoading = false }
            if let data = data, let responseString = String(data: data, encoding: .utf8) {
                print("서버응답: \(responseString)")
                DispatchQueue.main.async {
                    if responseString.contains("success") {
                        alertMessage = "발송 성공!"
                        showAlert = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            presentationMode.wrappedValue.dismiss()
                        }
                    } else {
                        alertMessage = "실패: \(responseString)"
                        showAlert = true
                    }
                }
            }
        }.resume()
    }
}
