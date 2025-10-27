//
//  FriendItemView.swift
//  FutureLetter
//
//  Created by Chaemin Yu on 10/27/25.
//

import SwiftUI

struct FriendItemView: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        // 친구에게 편지보내는 뷰 연결
        NavigationLink("친구에게 편지보내기", destination: LetterComposeView())
        NavigationLink("친구 차단", destination: BlockFriendsView())
    }
}

#Preview {
    FriendItemView()
}
