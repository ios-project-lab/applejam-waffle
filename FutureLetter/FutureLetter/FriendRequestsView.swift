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
            VStack(alignment: .leading, spacing: 28) {

                // MARK: - 받은 요청
                sectionHeader(title: "받은 요청", systemImage: "person.2.fill")

                if received.isEmpty {
                    emptySection(text: "받은 친구 요청이 없습니다.")
                } else {
                    ForEach(received, id: \.friendsId) { r in
                        requestCard(
                            title: "\(r.requesterNick ?? "알 수 없음") 님이 보낸 요청",
                            buttons: [
                                ("수락", .blue, { respond(action: "accept", friendsId: r.friendsId) }),
                                ("거절", .red, { respond(action: "reject", friendsId: r.friendsId) })
                            ]
                        )
                    }
                }

                // MARK: - 보낸 요청
                sectionHeader(title: "보낸 요청", systemImage: "paperplane.fill")

                if sent.isEmpty {
                    emptySection(text: "보낸 친구 요청이 없습니다.")
                } else {
                    ForEach(sent, id: \.friendsId) { s in
                        requestCard(
                            title: "\(s.receiverNick ?? "알 수 없음") 님에게 보낸 요청",
                            buttons: [
                                ("요청 취소", .gray, { respond(action: "cancel", friendsId: s.friendsId) })
                            ]
                        )
                    }
                }

            }
            .padding(.horizontal)
            .padding(.top, 8)
        }
        .navigationTitle("친구 신청 현황")
        .onAppear { loadData() }
        .alert(isPresented: $showAlert) {
            Alert(title: Text(alertMessage))
        }
    }

    // MARK: - 카드 UI 컴포넌트
    @ViewBuilder
    func requestCard(title: String, buttons: [(String, Color, () -> Void)]) -> some View {
        VStack(alignment: .leading, spacing: 12) {

            Text(title)
                .font(.subheadline)
                .foregroundColor(.primary)

            HStack {
                ForEach(buttons.indices, id: \.self) { index in
                    let btn = buttons[index]

                    Button(action: btn.2) {
                        Text(btn.0)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .tint(btn.1)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
    }

    // MARK: - 섹션 타이틀
    func sectionHeader(title: String, systemImage: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: systemImage)
                .foregroundColor(.blue)
            Text(title)
                .font(.title3)
                .bold()
        }
        .padding(.leading, 4)
    }

    // MARK: - 비어 있는 섹션
    func emptySection(text: String) -> some View {
        Text(text)
            .font(.subheadline)
            .foregroundColor(.secondary)
            .padding(.leading, 4)
    }

    // MARK: - 서버 통신
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

    func respond(action: String, friendsId: Int) {
        friendService.respondFriendRequest(action: action, friendsId: friendsId) { _ in
            DispatchQueue.main.async { loadData() }
        }
    }
}
