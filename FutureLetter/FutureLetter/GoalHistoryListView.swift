//
//  GoalHistoryListView.swift
//  FutureLetter
//
//  Created by Chaemin Yu on 10/27/25.
//

import SwiftUI

struct GoalHistoryListView: View {
    var body: some View {
        NavigationLink(destination: GoalHistoryDetailView()){
            Text("목표 히스토리 디테일 보기")
        }
        NavigationLink(destination: GoalHistoryItemView()){
            Text("목표 히스토리 아이템 보기")
        }
    }
}

#Preview {
    GoalHistoryListView()
}
