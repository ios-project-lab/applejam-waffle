//
//  FriendItemView.swift
//  FutureLetter
//
//  Created by Chaemin Yu on 10/27/25.
//

import SwiftUI

struct FriendItemView: View {
    var friend: Friend
    var body: some View {
        HStack {
            Circle().frame(width: 44, height: 44).overlay(Text(String(friend.displayName.prefix(1))))
            VStack(alignment: .leading) {
                Text(friend.displayName).bold()
                Text("@\(friend.username)").font(.caption).foregroundColor(.secondary)
            }
            Spacer()
            if friend.blocked { Text("차단됨").font(.caption).foregroundColor(.red) }
        }.padding(.vertical, 6)
    }
}
