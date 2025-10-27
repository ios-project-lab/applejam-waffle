//
//  FriendListView.swift
//  FutureLetter
//
//  Created by Chaemin Yu on 10/27/25.
//

import SwiftUI

struct FriendListView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("친구 목록")
                    .font(.title)
                    .padding()
                Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
                List {
                    NavigationLink("친구 검색", destination: FriendSearchView())
                    NavigationLink("친구 현황", destination: FriendRequestsView())
                }
                .navigationTitle("친구 목록")
            }
        }
        .navigationTitle("친구")
    }
}
