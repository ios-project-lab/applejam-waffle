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
    @State private var birthday = Date()
    @State private var gender = "모름"

    let genders = ["남성", "여성", "모름"]

    var body: some View {
        VStack(spacing: 12) {
            Text("회원가입")
                .font(.title2)
                .foregroundColor(.white)
            TextField("ID", text: $id).textFieldStyle(.roundedBorder)
            SecureField("비밀번호", text: $pwd).textFieldStyle(.roundedBorder)
            TextField("닉네임", text: $displayName).textFieldStyle(.roundedBorder)
            DatePicker("생년월일", selection: $birthday, displayedComponents: .date)
                            .datePickerStyle(.compact)
                            .labelsHidden()
                        
                        Picker("성별", selection: $gender) {
                            ForEach(genders, id: \.self) { g in
                                Text(g)
                            }
                        }
            Button {
                appState.currentUser = User(username: id, displayName: displayName.isEmpty ? id : displayName, birthday, gender)
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
        .navigationTitle("회원가입")
    }
}
