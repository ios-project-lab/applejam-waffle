//
//  FriendListView.swift
//  FutureLetter
//
//  Created by Chaemin Yu on 10/27/25.
//

import SwiftUI

struct FriendListView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationView {
            List {
                Section {
                    ForEach(appState.friends) { f in
                        NavigationLink(destination: FriendProfileView(friend: f)) {
                            FriendItemView(friend: f)
                        }
                    }
                    .onDelete { idx in appState.friends.remove(atOffsets: idx) }
                }
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
            }
            .navigationTitle("친구 리스트")
        }
    }
}
