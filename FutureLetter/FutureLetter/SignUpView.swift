import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.presentationMode) var presentationMode

    @State private var id = ""
    @State private var pwd = ""
    @State private var displayName = ""
    @State private var birthday = Date()
    @State private var gender = "모름"

    let genders = ["남성", "여성", "모름"]

    var body: some View {
        VStack(spacing: 12) {
            Text("회원가입")
                .font(.title2)
                .foregroundColor(.white)
            
            TextField("ID", text: $id)
                .textFieldStyle(.roundedBorder)
            
            SecureField("비밀번호", text: $pwd)
                .textFieldStyle(.roundedBorder)
            
            TextField("닉네임", text: $displayName)
                .textFieldStyle(.roundedBorder)
            
            DatePicker("생년월일", selection: $birthday, displayedComponents: .date)
                .datePickerStyle(.compact)
                .labelsHidden()
            
            Picker("성별", selection: $gender) {
                ForEach(genders, id: \.self) { g in
                    Text(g)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            
            Button {
                signUp()
            } label: {
                Text("가입하기")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.yellow)
                    .cornerRadius(8)
                    .foregroundColor(.white)
            }
            
            Spacer()
        }
        .padding()
        .background(Color("NavyBackground").edgesIgnoringSafeArea(.all))
        .navigationTitle("회원가입")
    }

    func signUp() {
        // 앱 상태에 저장
        appState.currentUser = User(username: id, displayName: displayName.isEmpty ? id : displayName)
        
        // PHP 서버 연동
        guard let url = URL(string: "http://localhost:80/fletter/signup.php") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let birthdayString = dateFormatter.string(from: birthday)
        
        let body = "id=\(id)&pwd=\(pwd)&displayName=\(displayName)&birthday=\(birthdayString)&gender=\(gender)"
        request.httpBody = body.data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("회원가입 에러:", error)
                return
            }
            if let data = data, let responseString = String(data: data, encoding: .utf8) {
                print("서버 응답:", responseString)
            }
        }.resume()
        
        presentationMode.wrappedValue.dismiss()
    }
}
