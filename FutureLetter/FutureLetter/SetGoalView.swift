//
//  SetGoalView.swift
//  FutureLetter
//
//  Created by mac07 on 11/2/25.
//

import SwiftUI

struct SetGoalView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.presentationMode) var presentationMode

    @State private var title = ""
    @State private var description = ""
    @State private var dueDate = Date()
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        VStack(spacing: 12) {
            Text("목표 작성")
                .font(.title2)
                .foregroundColor(.white)

            TextField("제목", text: $title)
                .textFieldStyle(.roundedBorder)

            TextField("설명", text: $description)
                .textFieldStyle(.roundedBorder)

            DatePicker("완료 기한", selection: $dueDate, displayedComponents: .date)
                .datePickerStyle(.compact)

            Button {
                postGoalToServer()
            } label: {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray)
                        .cornerRadius(8)
                } else {
                    Text("저장")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.yellow)
                        .cornerRadius(8)
                        .foregroundColor(.white)
                }
            }
            .disabled(isLoading)

            Spacer()
        }
        .padding()
        .background(Color("NavyBackground").edgesIgnoringSafeArea(.all))
        .alert(isPresented: $showAlert) {
            Alert(title: Text("알림"), message: Text(alertMessage), dismissButton: .default(Text("확인")))
        }
    }
    
    // POST

    func postGoalToServer() {
        guard !title.isEmpty, !description.isEmpty else {
            alertMessage = "모든 항목을 입력해주세요."
            showAlert = true
            return
        }

        let url = URL(string: "http://localhost/SetGoal.php")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        // 날짜를 문자열로 변환
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: dueDate)

        // POST 데이터 구성
        let postString = "title=\(title)&description=\(description)&dueDate=\(dateString)"

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
                    alertMessage = "목표가 성공적으로 저장되었습니다!"
                    showAlert = true
                    // 서버 저장 후 로컬에도 추가
                    let g = Goal(title: title, description: description, dueDate: dueDate)
                    appState.goals.insert(g, at: 0)
                    presentationMode.wrappedValue.dismiss()
                } else {
                    alertMessage = "목표 저장에 실패했습니다. 다시 시도해주세요."
                    showAlert = true
                }
            }
        }.resume()
    }
}

