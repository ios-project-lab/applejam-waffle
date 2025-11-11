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

    var body: some Scene {
        WindowGroup {
            if appState.currentUser == nil{
                LoginView()
                    .environmentObject(appState)
            }else{
                NavigationStack{
                    TabBarView()
//                        .environmentObject(appState)
//                        .environmentObject(goalStore)
//                        .environmentObject(goalHistoryStore)
                }
                .environmentObject(appState)
                                .environmentObject(goalStore)
                                .environmentObject(goalHistoryStore)
            }
        }
//        WindowGroup{
//                ContentView().environmentObject(appState)
//        }
    }
}
