//
//  GoalHistoryItemView.swift
//  FutureLetter
//
//  Created by Chaemin Yu on 10/27/25.
//

import SwiftUI

struct GoalHistoryItemView: View {
    var goal: Goal
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(goal.title).bold()
                Text(goal.description).font(.caption)
            }
            Spacer()
            Text(goal.deadLine, style: .date)
        }.padding(.vertical, 6)
    }
}
