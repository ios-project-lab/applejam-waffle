//
//  ProfileSettingsView.swift
//  FutureLetter
//
//  Created by Chaemin Yu on 10/27/25.
//

import SwiftUI

struct ProfileSettingsView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("계정")) {
                    Text("아이디: \(appState.currentUser?.username ?? "-")")
                    Text("이름: \(appState.currentUser?.displayName ?? "-")")
                    NavigationLink(destination: ProfileUpdateView()) {
                        Text("프로필 수정")
                    }
                }
                Section(header: Text("기타")) {
                    NavigationLink(destination: GoalHistoryListView()) {
                        Text("목표 히스토리 보기")
                    }
                    Button("로그아웃") {
                        appState.currentUser = nil
                    }
                }
            }
            .navigationTitle("설정")
        }
    }
}
