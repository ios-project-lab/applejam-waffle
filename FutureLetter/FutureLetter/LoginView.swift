import SwiftUI

struct LoginResponse: Codable {
    let pk: Int
    let id: String
    let nickName: String
    
    enum CodingKeys: String, CodingKey {
        case pk = "usersId"
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

                // 에러 메시지가 있을 때만 표시
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
        .navigationTitle("")
        .navigationBarHidden(true)
    }

    func login() {
        guard let url = URL(string: "http://localhost/fletter/login.php") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

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

                if httpResponse.statusCode == 200 {
                    if let loginData = try? JSONDecoder().decode(LoginResponse.self, from: data) {
                        print("로그인 성공:", loginData)
                        
                        UserDefaults.standard.set(loginData.pk, forKey: "currentUserPK")
                        
                        appState.currentUser = User(
                            usersId: loginData.pk,
                            id: loginData.id,
                            nickName: loginData.nickName,
                            password: nil,
                            birthDay: nil,
                            gender: nil,
                            userStatus: 1,
                            profileImage: nil,
                            createdAt: nil
                        )
                        
                        appState.isLoggedIn = true
                        
                    } else {
                        errorMessage = "데이터 디코딩 실패"
                        print(String(data: data, encoding: .utf8) ?? "")
                    }
                }
                else {
                    if let errResponse = try? JSONDecoder().decode([String: String].self, from: data),
                       let msg = errResponse["message"] {
                        errorMessage = msg
                    } else {
                        errorMessage = "로그인 실패 (코드: \(httpResponse.statusCode))"
                    }
                }
            }
        }.resume()
    }
}
