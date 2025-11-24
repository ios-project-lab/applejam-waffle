//
//  FriendSearchView.swift
//  FutureLetter
//
//  Created by Chaemin Yu on 10/27/25.
//

import SwiftUI

struct FriendSearchView: View {
    @EnvironmentObject var appState: AppState
    @State private var query = ""

    var body: some View {
        VStack {
            TextField("검색할 사용자명", text: $query).textFieldStyle(.roundedBorder).padding()
            Button {
                // Mock: add a friend with query
                guard !query.isEmpty else { return }
                let f = Friend(id: query, displayName: query, usersId: nil)
                appState.friends.append(f)
                query = ""
            } label: {
                Text("친구 추가").frame(maxWidth: .infinity).padding().background(Color.yellow).cornerRadius(8)
            }.padding(.horizontal)
            Spacer()
        }.navigationTitle("친구 검색")
    }
}
