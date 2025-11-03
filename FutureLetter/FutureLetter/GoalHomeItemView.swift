//
//  GoalHomeItemView.swift
//  FutureLetter
//
//  Created by Chaemin Yu on 10/27/25.
//

import SwiftUI

struct GoalHomeItemView: View {
    var goal: Goal
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(goal.title).font(.subheadline).bold()
                Text(goal.description).font(.caption)
            }
            Spacer()
            Text(goal.deadLine, style: .date).font(.caption2)
        }
        .padding(8)
        .background(Color.white)
        .cornerRadius(8)
    }
}
