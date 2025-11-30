//
//  FriendRequestsView.swift
//  FutureLetter
//
//  Created by Chaemin Yu on 10/27/25.
//
//
import SwiftUI

struct FriendRequestsView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        List {
            ForEach(appState.friendRequests) { fr in
                HStack {
                    Text(fr.displayName)
                    Spacer()
                    Button("수락") {
                        appState.friends.append(fr)
                        appState.friendRequests.removeAll { $0.id == fr.id }
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .navigationTitle("친구 요청")
    }
}
