//
//  GoalHistoryListView.swift
//  FutureLetter
//
//  Created by Chaemin Yu on 10/27/25.
//

import SwiftUI

struct GoalHistoryListView: View {
    // Simple mock of history (reusing goals)
    @EnvironmentObject var appState: AppState
    var body: some View {
        List {
            ForEach(appState.goals) { g in
                NavigationLink(destination: GoalHistoryDetailView(goal: g)) {
                    GoalHistoryItemView(goal: g)
                }
            }
        }
        .navigationTitle("목표 히스토리")
    }
}
