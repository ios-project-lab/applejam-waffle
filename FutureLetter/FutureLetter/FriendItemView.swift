//
//  FriendItemView.swift
//  FutureLetter
//
//  Created by Chaemin Yu on 10/27/25.
//  Updated by kcw9609
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
    private let friendService = FriendService()
    var body: some View {
        HStack {
            
            VStack(alignment: .leading) {
                Text(friend.nickName)
                    .font(.title3)
                    .fontWeight(.bold)
                
                Text(friend.friendStatusName)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
            }
            .padding()
        }
    }
    }

