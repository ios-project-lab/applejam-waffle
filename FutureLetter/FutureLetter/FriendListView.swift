import SwiftUI
struct FriendListView: View {
    @StateObject var friendStore = FriendStore()

    var body: some View {
        List {
            // 상단 섹션은 그대로 유지
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

            // 친구 목록 표시
            Section(header: Text("내 친구 (\(friendStore.friends.count)명)")) {
                if friendStore.isLoading {
                    ProgressView("친구 목록 로드 중...")
                } else if friendStore.friends.isEmpty {
                    Text("친구 목록이 비어 있습니다.").foregroundColor(.secondary)
                } else {
                    ForEach(friendStore.friends, id: \.friendsId) { friend in
                        FriendItemView(friend: friend)
                    }
                    // TODO: 스와이프 삭제 기능 List에서 구현 (FriendStore.deleteFriend 연동)
                    // .onDelete(perform: friendStore.deleteFriend)
                }
            }
        }
        .navigationTitle("친구 리스트")
        .onAppear { // 뷰가 나타날 때 데이터 로드
            friendStore.loadFriendsFromServer()
        }
    }
}
