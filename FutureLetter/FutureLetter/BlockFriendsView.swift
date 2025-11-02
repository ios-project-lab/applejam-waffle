//
//  BlockFriendsView.swift
//  FutureLetter
//
//  Created by Chaemin Yu on 10/27/25.
//

import SwiftUI

struct BlockFriendsView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        List {
            ForEach(appState.friends.filter { $0.blocked }) { f in
                HStack {
                    Text(f.displayName)
                    Spacer()
                    Button("해제") {
                        if let idx = appState.friends.firstIndex(where: { $0.id == f.id }) {
                            appState.friends[idx].blocked = false
                        }
                    }
                }
            }
        }
        .navigationTitle("차단한 친구")
    }
}
