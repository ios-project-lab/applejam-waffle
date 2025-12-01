
import SwiftUI

struct BlockFriendsView: View {
    @State private var sent: [FriendRequest] = []
    @State private var showAlert = false
    @State private var alertMessage = ""

    private let friendService = FriendService()
    private let userId = UserDefaults.standard.integer(forKey: "currentUserPK")

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {

                if sent.isEmpty {
                    VStack {
                        Image(systemName: "shield.lefthalf.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                            .padding(.bottom, 8)

                        Text("차단한 사용자가 없습니다.")
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 40)
                }

                ForEach(sent, id: \.friendsId) { friend in
                    VStack(alignment: .leading, spacing: 10) {

                        // 닉네임
                        Text(friend.receiverNick ?? "알 수 없음")
                            .font(.title3)
                            .fontWeight(.semibold)

                        Text("이 사용자는 차단된 상태입니다.")
                            .font(.subheadline)
                            .foregroundColor(.gray)

                        HStack {
                            Spacer()

                            Button {
                                respond(action: "unBlock", friendsId: friend.friendsId)
                            } label: {
                                Text("차단 해제")
                                    .fontWeight(.semibold)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 20)
                                    .background(Color.blue.opacity(0.15))
                                    .foregroundColor(.blue)
                                    .cornerRadius(10)
                            }
                        }

                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    .padding(.horizontal)
                }
            }
            .padding(.top)
        }
        .navigationTitle("친구 차단 현황")
        .onAppear {
            loadData()
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text(alertMessage))
        }
    }

    // MARK: - 서버에서 차단 현황 가져오기
    func loadData() {
        friendService.loadBlockedFriends(currentUserId: userId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    sent = data.sent
                case .failure(let error):
                    alertMessage = error.localizedDescription
                    showAlert = true
                }
            }
        }
    }

    // MARK: - 차단 해제 처리
    func respond(action: String, friendsId: Int) {
        friendService.respondFriendRequest(action: action, friendsId: friendsId) { _ in
            DispatchQueue.main.async {
                loadData()
            }
        }
    }
}
