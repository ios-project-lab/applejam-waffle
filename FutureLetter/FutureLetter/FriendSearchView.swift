//
//  FriendSearchView.swift
//  FutureLetter
//
//  Created by Chaemin Yu on 10/27/25.
//

import SwiftUI

struct FriendSearchView: View {
    @State private var nickName = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    private let friendService = FriendService()

    var body: some View {
        VStack {
            TextField("검색할 사용자명", text: $nickName).textFieldStyle(.roundedBorder).padding()
            Button { // 비동기 처리
                friendService.sendFriendRequest(
                    friendNickName: nickName
                ) { result in
                    switch result {
                    case .success(let message):
                        print("성공:", message)
                        alertMessage = "친구 요청을 보냈습니다!"
                        showAlert = true

                    case .failure(let error):
                        print("실패:", error.localizedDescription)
                    }
                }

            } label: {
                Text("친구 추가").frame(maxWidth: .infinity).padding().background(Color.yellow).cornerRadius(8)
            }.padding(.horizontal)
            .alert(isPresented: $showAlert) {
                Alert(title: Text("알림"), message: Text(alertMessage), dismissButton: .default(Text("확인")))
            }
            Spacer()
        }.navigationTitle("친구 검색")
    }
}

