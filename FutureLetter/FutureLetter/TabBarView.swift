//
//  TabBarView.swift
//  FutureLetter
//
//  Created by Chaemin Yu on 10/27/25.
//

import SwiftUI

struct TabBarView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("홈", systemImage: "house.fill")
                }

            GoalListView()
                .tabItem {
                    Label("목표", systemImage: "target")
                }

            LetterInBoxView()
                .tabItem {
                    Label("편지함", systemImage: "envelope.fill")
                }

            FriendListView()
                .tabItem {
                    Label("친구", systemImage: "person.2.fill")
                }

            ProfileSettingsView()
                .tabItem {
                    Label("설정", systemImage: "gearshape.fill")
                }
        }
        .accentColor(.yellow)
    }
}




