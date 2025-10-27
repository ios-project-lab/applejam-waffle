//
//  ProfileSettingsView.swift
//  FutureLetter
//
//  Created by Chaemin Yu on 10/27/25.
//

import SwiftUI

struct ProfileSettingsView: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        // 차단한 친구 보기
        NavigationLink("친구 관리", destination: BlockFriendsView())
        NavigationLink("로그아웃", destination: LoginView())
    }
}

#Preview {
    ProfileSettingsView()
}
