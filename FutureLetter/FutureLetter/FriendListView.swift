import SwiftUI

struct FriendListView: View {
    @StateObject var friendStore = FriendStore()
    private let friendService = FriendService()

    var body: some View {
        List {

            // 상단 메뉴
            Section {
                NavigationLink(destination: FriendRequestsView()) {
                    Text("친구 요청 보기")
                }
                NavigationLink(destination: FriendSearchView()) {
                    Text("친구 추가")
                }
                NavigationLink(destination: BlockFriendsView()) {
                    Text("차단한 친구")
                }
            }

            // 친구 목록
            Section(header: Text("내 친구 (\(friendStore.friends.count)명)")) {

                if friendStore.isLoading {
                    ProgressView("친구 목록 로드 중...")
                }
                else if friendStore.friends.isEmpty {
                    Text("친구 목록이 비어 있습니다.")
                        .foregroundColor(.secondary)
                }
                else {
                    ForEach(friendStore.friends, id: \.friendsId) { friend in
                        friendRow(friend: friend)
                    }
                }
            }
        }
        .navigationTitle("친구 리스트")
        .onAppear {
            friendStore.loadFriendsFromServer()
        }
    }

    // MARK: - 개별 친구 Row
    @ViewBuilder
    func friendRow(friend: FriendItem) -> some View {
        HStack {
            // Friend 정보 표시
            FriendItemView(friend: friend)

            Spacer()

            // --- 편지 보내기 ---
            NavigationLink(destination: LetterComposeView()) {
                Text("편지")
                    .foregroundColor(.blue)
                    .padding(6)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
            }
            .buttonStyle(.plain)

            // --- 차단 버튼 ---
            Button {
                friendService.respondFriendRequest(action: "block",
                                                   friendsId: friend.friendsId) { _ in
                    friendStore.loadFriendsFromServer()
                }
            } label: {
                Text("차단")
                    .foregroundColor(.red)
                    .padding(6)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(8)
            }
            .buttonStyle(.borderless)
        }
        .padding(.vertical, 4)
    }
    
}
