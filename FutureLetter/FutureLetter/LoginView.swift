import SwiftUI

struct LoginResponse: Codable {
    let pk: Int
    let id: String
    let nickName: String
    enum CodingKeys: String, CodingKey {
            case pk = "usersId"  // JSON key 'usersId'를 Swift의 'pk'에 매핑
            case id
            case nickName
        }
}

struct LoginView: View {
    @EnvironmentObject var appState: AppState
    @State private var id = ""
    @State private var pwd = ""
    @State private var showSignUp = false
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                Text("로그인")
                    .font(.title2)
                    .foregroundColor(.white)

                TextField("ID", text: $id)
                    .textFieldStyle(.roundedBorder)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)

                SecureField("비밀번호", text: $pwd)
                    .textFieldStyle(.roundedBorder)

                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                }

                Button {
                    login()
                } label: {
                    if isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else {
                        Text("로그인")
                            .fontWeight(.bold)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.yellow)
                            .cornerRadius(8)
                            .foregroundColor(.white)
                    }
                }
                .disabled(isLoading)

                Button {
                    showSignUp = true
                } label: {
                    Text("회원가입")
                        .fontWeight(.medium)
                        .foregroundColor(.yellow)
                }
                .padding(.top, 8)

                Spacer()
            }
            .padding()
            .background(Color("NavyBackground").edgesIgnoringSafeArea(.all))
            .sheet(isPresented: $showSignUp) {
                SignUpView()
                    .environmentObject(appState)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .navigationTitle("로그인")
    }

    func login() {
            guard let url = URL(string: "http://localhost/fletter/login.php") else { return }

            var request = URLRequest(url: url)
            request.httpMethod = "POST"

            // URL 인코딩 적용
            let body = "id=\(id.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&pwd=\(pwd.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
            request.httpBody = body.data(using: .utf8)
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            
            isLoading = true
            errorMessage = nil

            URLSession.shared.dataTask(with: request) { data, response, error in
                DispatchQueue.main.async {
                    isLoading = false

                    if let error = error {
                        errorMessage = "서버 오류: \(error.localizedDescription)"
                        return
                    }

                    guard let httpResponse = response as? HTTPURLResponse, let data = data else {
                        errorMessage = "서버 응답 오류"
                        return
                    }

                    // 상태 코드별 처리
                    if httpResponse.statusCode == 200 {
                        if let loginData = try? JSONDecoder().decode(LoginResponse.self, from: data) {
                            print("로그인 성공:", loginData)
                            // 로컬에 저장 -> api호출 시, 함께 전송
                            UserDefaults.standard.set(loginData.pk, forKey: "currentUserPK")
                            
                            appState.currentUser = User(id: String(loginData.pk),
                                                        username: loginData.id,
                                                        displayName: loginData.nickName)
                            appState.isLoggedIn = true
                        } else {
                            errorMessage = "로그인 데이터 디코딩 실패"
                            print(String(data: data, encoding: .utf8) ?? "데이터 없음")
                        }
                    } else {
                        // 400 등 실패 시 PHP에서 전달한 message 읽기
                        if let errResponse = try? JSONDecoder().decode([String: String].self, from: data),
                           let msg = errResponse["message"] {
                            errorMessage = msg
                        } else {
                            errorMessage = "로그인 실패"
                        }
                        print(errorMessage)
                        print(String(data: data, encoding: .utf8) ?? "데이터 없음")
                    }
                }
            }.resume()
        }
}
