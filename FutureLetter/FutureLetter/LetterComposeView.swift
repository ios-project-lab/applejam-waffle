import SwiftUI

struct LetterComposeView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.presentationMode) var presentationMode

    @State private var to = ""
    @State private var from = ""
    @State private var receiveDate = Date()
    @State private var subject = ""
    @State private var bodyText = ""
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    private let viewModel = LetterViewModel()

    var body: some View {
        VStack(spacing: 12) {
            Button("AI 테스트 실행") {
                viewModel.testAnalyze()
            }
            
            Text("편지 작성")
                .font(.title2)
                .bold()

            TextField("받는 사람", text: $to)
                .textFieldStyle(.roundedBorder)

            TextField("보내는 사람", text: $from)
                .textFieldStyle(.roundedBorder)

            DatePicker("받는 날짜", selection: $receiveDate, displayedComponents: .date)
                .datePickerStyle(.compact)

            TextField("제목", text: $subject)
                .textFieldStyle(.roundedBorder)

            TextEditor(text: $bodyText)
                .frame(height: 200)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3))
                )

            Button {
                postLetterToServer()
            } label: {
                HStack {
                    if isLoading { ProgressView().scaleEffect(0.8) }
                    Text("보내기")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.yellow)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .disabled(isLoading)

            Spacer()
        }
        .padding()
        .alert(isPresented: $showAlert) {
            Alert(title: Text("알림"), message: Text(alertMessage), dismissButton: .default(Text("확인")))
        }
        .onAppear {
            if from.isEmpty {
                from = appState.currentUser?.displayName ?? "나"
            }
        }
    }

    func postLetterToServer() {
        guard let currentUserID = appState.currentUser?.id else {
            alertMessage = "로그인 정보가 없습니다. 다시 로그인해주세요."
            showAlert = true
            return
        }
        
        let receiverFriend = appState.friends.first(where: { $0.displayName == to })
        let receiverUserID = receiverFriend?.id ?? (to == from ? currentUserID : "0")

        // 검증
        guard !to.trimmingCharacters(in: .whitespaces).isEmpty,
              !subject.trimmingCharacters(in: .whitespaces).isEmpty,
              !bodyText.trimmingCharacters(in: .whitespaces).isEmpty,
              !from.trimmingCharacters(in: .whitespaces).isEmpty else {
            alertMessage = "모든 항목을 입력해주세요."
            showAlert = true
            return
        }

        guard let url = URL(string: "http://localhost/fletter/LetterCompose.php") else {
            alertMessage = "잘못된 서버 URL입니다."
            showAlert = true
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")

        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let receiveDateString = dateFormatter.string(from: receiveDate)

        let params: [String: String] = [
            "senderId": currentUserID,
            "receiverId": receiverUserID,
            "title": subject,
            "content": bodyText,
            "receiveDate": receiveDateString
        ]

        let postString = params.map { key, value in
            let escapedKey = key.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            let escapedValue = value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            return "\(escapedKey)=\(escapedValue)"
        }.joined(separator: "&")

        request.httpBody = postString.data(using: .utf8)

        isLoading = true

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
            }

            if let error = error {
                DispatchQueue.main.async {
                    self.alertMessage = "서버 요청 실패: \(error.localizedDescription)"
                    self.showAlert = true
                }
                return
            }

            guard let data = data, let responseString = String(data: data, encoding: .utf8) else {
                DispatchQueue.main.async {
                    self.alertMessage = "서버 응답이 올바르지 않습니다."
                    self.showAlert = true
                }
                return
            }

            print("서버 응답: \(responseString)")

            DispatchQueue.main.async {
                if responseString.lowercased().contains("success") {
                    self.alertMessage = "편지가 성공적으로 작성되었습니다!"
                    self.showAlert = true

                    let newLetter = Letter(from: self.from, to: self.to, subject: self.subject, body: self.bodyText, date: self.receiveDate)
                    self.appState.inbox.insert(newLetter, at: 0)
                    self.presentationMode.wrappedValue.dismiss()
                } else {
                    self.alertMessage = "편지 작성에 실패했습니다. 서버 응답: \(responseString)"
                    self.showAlert = true
                }
            }
        }.resume()
    }
}

