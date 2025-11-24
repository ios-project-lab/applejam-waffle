import SwiftUI

struct LetterReplyView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.presentationMode) var presentationMode

    var original: Letter // 원본 편지
    @State private var bodyText = ""
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        VStack(spacing: 12) {
            Text("답장하기").font(.title2).bold()
            
            // 원본 편지 정보 표시
            HStack {
                Text("To. \(original.senderNickName ?? "알 수 없음")")
                    .font(.caption)
                    .foregroundColor(.gray)
                Spacer()
            }
            .padding(.horizontal)

            TextEditor(text: $bodyText)
                .frame(height: 200)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3))
                )
                .padding(.horizontal)

            Button {
                sendReplyToServer()
            } label: {
                HStack {
                    if isLoading { ProgressView() }
                    Text("답장 보내기")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.yellow)
                .cornerRadius(8)
                .foregroundColor(.white)
            }
            .disabled(isLoading)
            .padding()
            .alert(isPresented: $showAlert) {
                Alert(title: Text("알림"), message: Text(alertMessage), dismissButton: .default(Text("확인")))
            }

            Spacer()
        }
    }
    
    func sendReplyToServer() {
        guard let myUser = appState.currentUser else { return }
        
        // 1. 서버 주소 설정 (본인 IP로 변경)
        guard let url = URL(string: "http://localhost/fletter/LetterCompose.php") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        // 2. 답장 데이터 구성
        // 답장은 바로 도착
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let nowStr = formatter.string(from: Date())
        
        let receiverTarget = original.senderNickName ?? ""
        
        let title = "RE: \(original.title)"
        
        let body = "senderId=\(myUser.usersId)&receiverId=\(receiverTarget)&title=\(title)&content=\(bodyText)&expectedArrivalTime=\(nowStr)&parentLettersId=\(original.lettersId)"
        
        request.httpBody = body.data(using: String.Encoding.utf8)
        
        isLoading = true
        
        // 3. 전송
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async { isLoading = false }
            
            if let data = data, let responseStr = String(data: data, encoding: .utf8) {
                print("답장 응답: \(responseStr)")
                
                DispatchQueue.main.async {
                    if responseStr.contains("success") {
                        alertMessage = "답장이 전송되었습니다!"
                        showAlert = true
                        // 잠시 후 닫기
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            presentationMode.wrappedValue.dismiss()
                        }
                    } else {
                        alertMessage = "전송 실패: \(responseStr)"
                        showAlert = true
                    }
                }
            }
        }.resume()
    }
}
