//
//  SignUpView.swift
//  FutureLetter
//
//  Created by Chaemin Yu on 10/27/25.
//

import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.presentationMode) var presentationMode

    @State private var id = ""
    @State private var pwd = ""
    @State private var displayName = ""

    var body: some View {
        VStack(spacing: 12) {
            Text("회원가입")
                .font(.title2)
                .foregroundColor(.white)
            TextField("ID", text: $id).textFieldStyle(.roundedBorder)
            SecureField("비밀번호", text: $pwd).textFieldStyle(.roundedBorder)
            TextField("닉네임", text: $displayName).textFieldStyle(.roundedBorder)
            Button {
                appState.currentUser = User(username: id, displayName: displayName.isEmpty ? id : displayName)
                presentationMode.wrappedValue.dismiss()
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
    }
}
