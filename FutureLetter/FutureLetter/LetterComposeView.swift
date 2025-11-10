//
//  LetterComposeView.swift
//  FutureLetter
//
//  Created by Chaemin Yu on 10/27/25.
//

import SwiftUI

struct LetterComposeView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.presentationMode) var presentationMode

    @State private var to = ""
    @State private var from = ""
    @State private var sendDate = Date()
    @State private var subject = ""
    @State private var bodyText = ""
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        VStack(spacing: 12) {
            Text("편지 작성")
                .font(.title2)
                .bold()

            TextField("받는 사람", text: $to)
                .textFieldStyle(.roundedBorder)
            
            TextField("보내는 사람", text: $from)
                .textFieldStyle(.roundedBorder)
            
            DatePicker("보내는 날짜", selection: $sendDate, displayedComponents: .date)
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
                Text("보내기")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.yellow)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }

            Spacer()
        }
        .padding()
    }
    // POST

    func postLetterToServer() {
        guard !to.isEmpty, !subject.isEmpty, !bodyText.isEmpty, !from.isEmpty, !sendDate.description.isEmpty else {
            alertMessage = "모든 항목을 입력해주세요."
            showAlert = true
            return
        }

        let url = URL(string: "http://localhost/LetterCompose.php")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        // POST 데이터 구성
        let postString = "to=\(to)&subject=\(subject)&bodyText=\(bodyText)&from=\(from)&sendDate=\(sendDate)"

        request.httpBody = postString.data(using: .utf8)

        isLoading = true

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
            }

            if let error = error {
                print("요청 실패:", error)
                DispatchQueue.main.async {
                    alertMessage = "서버 요청 실패: \(error.localizedDescription)"
                    showAlert = true
                }
                return
            }

            guard let data = data,
                  let responseString = String(data: data, encoding: .utf8) else {
                DispatchQueue.main.async {
                    alertMessage = "서버 응답이 올바르지 않습니다."
                    showAlert = true
                }
                return
            }

            print("서버 응답:", responseString)

            DispatchQueue.main.async {
                if responseString.contains("success") {
                    alertMessage = "편지가 성공적으로 작성되었습니다!"
                    showAlert = true
                    // 서버 저장 후 로컬에도 추가
                    let l = Letter(from: from, to: to, subject: subject, body: bodyText, date:sendDate)
                    appState.inbox.insert(l, at: 0)
                    presentationMode.wrappedValue.dismiss()
                } else {
                    alertMessage = "편지 작성에 실패했습니다. 다시 시도해주세요."
                    showAlert = true
                }
            }
        }.resume()
    }
}

