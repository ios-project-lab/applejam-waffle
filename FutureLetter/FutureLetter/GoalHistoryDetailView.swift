//
//  GoalHistoryDetailView.swift
//  FutureLetter
//
//  Created by Chaemin Yu on 10/27/25.
//

import SwiftUI

struct GoalHistoryDetailView: View {
    var goal: Goal
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(goal.title).font(.title2)
            Text("설명: \(goal.description)")
            Text("완료기한: \(goal.dueDate, style: .date)")
            Spacer()
        }
        .padding()
        .navigationTitle("히스토리 상세")
    }
}
