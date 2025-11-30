//
//  FriendRequestsView.swift
//  FutureLetter
//
//  Created by Chaemin Yu on 10/27/25.
//
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

                Text("받은 요청").font(.headline).padding(.top)

                ForEach(received, id: \.friendsId) { r in
                    VStack(alignment: .leading, spacing: 8) {
                        Text("\(r.requesterNick ?? "")님이 친구 요청을 보냈습니다.")

                        HStack {
                            Button("수락") {
                                respondRequest(friendsId: r.friendsId, action: "accept")
                            }
                            .buttonStyle(.bordered)

                            Button("거절") {
                                respondRequest(friendsId: r.friendsId, action: "reject")
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                }

                Text("보낸 요청").font(.headline).padding(.top)

                ForEach(sent, id: \.friendsId) { s in
                    VStack(alignment: .leading, spacing: 8) {
                        Text("\(s.receiverNick ?? "")님에게 친구 요청을 보냈습니다.")

                        Button("요청 취소") {
                            respondRequest(friendsId: s.friendsId, action: "cancel")
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

    // 서버에서 요청 현황 가져오기
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

    // 수락 / 거절 / 취소 기능
    func respondRequest(friendsId: Int, action: String) {
        let url = "http://localhost/fletter/\(action)Friend.php"
        friendService.postToServer(url: url, friendsId: friendsId) { result in
            // 성공 처리
            loadData()
        }
    }

}

//struct FriendRequestsView: View {
//    @EnvironmentObject var appState: AppState
//
//    var body: some View {
//        List {
//            ForEach(appState.friendRequests) { fr in
//                HStack {
//                    Text(fr.displayName)
//                    Spacer()
//                    Button("수락") {
//                        appState.friends.append(fr)
//                        appState.friendRequests.removeAll { $0.id == fr.id }
//                    }
//                    .buttonStyle(.borderedProminent)
//                }
//            }
//        }
//        .navigationTitle("친구 요청")
//    }
//}
