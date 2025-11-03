import SwiftUI

struct LoginView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.presentationMode) var presentationMode

    @State private var id = ""
    @State private var pwd = ""
    @State private var showSignUp = false

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

                Button {
                    // 임시 로그인 처리
                    appState.currentUser = User(username: id.isEmpty ? "futureme" : id,
                                                displayName: id.isEmpty ? "나" : id)
                    appState.isLoggedIn = true
                } label: {
                    Text("로그인")
                        .fontWeight(.bold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.yellow)
                        .cornerRadius(8)
                        .foregroundColor(.white)
                }

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
}
