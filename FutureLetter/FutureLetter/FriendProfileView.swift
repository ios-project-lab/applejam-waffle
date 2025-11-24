//
//  FriendProfileView.swift
//  FutureLetter
//
//  Created by Chaemin Yu on 10/27/25.
//

import SwiftUI

struct FriendProfileView: View {
    @EnvironmentObject var appState: AppState
    @State var friend: Friend

    var body: some View {
        VStack(spacing: 12) {
            Text(friend.displayName).font(.title2)
            Text("@\(friend.id)").foregroundColor(.secondary)
            Spacer()
            Button(action: {
                if let idx = appState.friends.firstIndex(where: { $0.id == friend.id }) {
                    appState.friends[idx].blocked.toggle()
                    friend.blocked.toggle()
                }
            }) {
                Text(friend.blocked ? "차단 해제" : "차단")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(friend.blocked ? Color.gray : Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            Spacer()
        }.padding()
    }
}
