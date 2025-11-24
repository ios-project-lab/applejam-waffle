//
//  ProfileUpdateView.swift
//  FutureLetter
//
//  Created by Chaemin Yu on 10/27/25.
//

import SwiftUI

struct ProfileUpdateView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.presentationMode) var presentationMode
    
    @State private var nickName = ""

    var body: some View {
        VStack(spacing: 12) {
            TextField("표시 이름", text: $nickName).textFieldStyle(.roundedBorder)
            
            Button {
                if let u = appState.currentUser {
                    let newNickName = nickName.isEmpty ? u.nickName : nickName
                    
                    appState.currentUser = User(
                        usersId: u.usersId,
                        id: u.id,
                        nickName: newNickName, // 변경된 닉네임 적용
                        password: u.password,
                        birthDay: u.birthDay,
                        gender: u.gender,
                        userStatus: u.userStatus,
                        profileImage: u.profileImage,
                        createdAt: u.createdAt
                    )
                }
                presentationMode.wrappedValue.dismiss()
            } label: {
                Text("저장").frame(maxWidth: .infinity).padding().background(Color.yellow).cornerRadius(8)
            }
            Spacer()
        }
        .padding()
        .onAppear {
            nickName = appState.currentUser?.nickName ?? ""
        }
    }
}
