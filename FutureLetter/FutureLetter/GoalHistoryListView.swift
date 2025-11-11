//
//  GoalHistoryListView.swift
//  FutureLetter
//
//  Created by Chaemin Yu on 10/27/25.
//
import SwiftUI

struct GoalHistoryListView: View {
    
    @EnvironmentObject var goalHistoryStore: GoalHistoryStore
        let goalsId: Int   // GoalItemView에서 전달받은 목표 ID

    var body: some View {
        List {
            ForEach(goalHistoryStore.goalHistories, id:\.goalHistoriesId) { item in
                GoalHistoryItemView(history: item)
                
            }
        }
        .navigationTitle("목표 히스토리")
        .task {
            goalHistoryStore.loadGoalsFromServer(goalsId: goalsId)
        }

    }
            

}


