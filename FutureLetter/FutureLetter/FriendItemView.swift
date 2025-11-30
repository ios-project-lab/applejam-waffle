//
//  FriendItemView.swift
//  FutureLetter
//
//  Created by Chaemin Yu on 10/27/25.
//

import SwiftUI

struct FriendItem: Codable {

    var friendsId : Int = 0
    var receiverId : Int = 0
    var nickName: String
    var friendStatusName: String
    var createdAt: Date?
    var updatedAt: Date?
    var isBlocked: Bool = false

}

struct FriendItemView: View {
    var friend: FriendItem
    var body: some View {
        HStack {

            VStack(alignment: .leading) {
                Text(friend.nickName).bold()
                Text(friend.friendStatusName)
            }
            Spacer()
            if friend.isBlocked { Text("차단됨").font(.caption).foregroundColor(.red) }
        }.padding(.vertical, 6)
    }
}
