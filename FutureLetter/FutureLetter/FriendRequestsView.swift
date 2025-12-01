//
//  FriendRequestsView.swift
//  FutureLetter
//
//  Created by Chaemin Yu on 10/27/25.
//

import SwiftUI

struct FriendRequest: Codable {
    let friendsId: Int
    let requesterId: Int
    let receiverId: Int
    let friendStatus: Int
    let requesterNick: String?
    let receiverNick: String?
}

struct FriendRequestResponse: Codable {
    let received: [FriendRequest]
    let sent: [FriendRequest]
}
struct FriendBlockResponse: Codable {
    let sent: [FriendRequest]
}

struct FriendRequestsView: View {
    @State private var received: [FriendRequest] = []
    @State private var sent: [FriendRequest] = []
    @State private var showAlert = false
    @State private var alertMessage = ""

    private let friendService = FriendService()
    private let userId = UserDefaults.standard.integer(forKey: "currentUserPK")

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                // MARK: - 받은 요청
                Text("받은 요청")
                    .font(.headline)
                    .padding(.top)

                ForEach(received, id: \.friendsId) { r in
                    VStack(alignment: .leading, spacing: 8) {
                        Text("\(r.requesterNick ?? "")님이 친구 요청을 보냈습니다.")

                        HStack {
                            Button("수락") {
                                respond(action: "accept", friendsId: r.friendsId)
                            }
                            .buttonStyle(.bordered)

                            Button("거절") {
                                respond(action: "reject", friendsId: r.friendsId)
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                }

                // MARK: - 보낸 요청
                Text("보낸 요청")
                    .font(.headline)
                    .padding(.top)

                ForEach(sent, id: \.friendsId) { s in
                    VStack(alignment: .leading, spacing: 8) {
                        Text("\(s.receiverNick ?? "")님에게 친구 요청을 보냈습니다.")

                        Button("요청 취소") {
                            respond(action: "cancel", friendsId: s.friendsId)
                        }
                        .buttonStyle(.bordered)
                    }
                }

            }
            .padding()
        }
        .navigationTitle("친구 신청 현황")
        .onAppear {
            loadData()
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text(alertMessage))
        }
    }

    // MARK: - 서버에서 요청 현황 가져오기
    func loadData() {
        friendService.loadFriendRequests(currentUserId: userId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    received = data.received
                    sent = data.sent
                case .failure(let error):
                    alertMessage = error.localizedDescription
                    showAlert = true
                }
            }
        }
    }

    // MARK: - 요청 수락/거절/취소 공통 처리
    func respond(action: String, friendsId: Int) {
        friendService.respondFriendRequest(action: action, friendsId: friendsId) { _ in
            DispatchQueue.main.async {
                loadData()
            }
        }
    }
}
