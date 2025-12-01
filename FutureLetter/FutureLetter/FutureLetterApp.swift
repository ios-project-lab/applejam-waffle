//
//  FutureLetterApp.swift
//  FutureLetter
//
//  Created by mac08 on 10/27/25.
//

// 진입점
import SwiftUI

@main
struct FutureLetterApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var goalStore = GoalStore()
    @StateObject private var goalHistoryStore = GoalHistoryStore()
    @StateObject private var friendStore = FriendStore()
    @StateObject private var emotionStatsStore = EmotionStatsStore()

    var body: some Scene {
        WindowGroup {
            if appState.currentUser == nil{
                LoginView()
                    .environmentObject(appState)
            }else{
                NavigationStack{
                    TabBarView()

                }
                .environmentObject(appState)
                .environmentObject(goalStore)
                .environmentObject(goalHistoryStore)
                .environmentObject(friendStore)
                .environmentObject(emotionStatsStore)
                .onAppear{
                    appState.emotionStatsStore = emotionStatsStore
                }
            }
        }
    }
}
