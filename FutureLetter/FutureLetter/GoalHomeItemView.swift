//
//  GoalHomeItemView.swift
//  FutureLetter
//
//  Created by Chaemin Yu on 10/27/25.
//

import SwiftUI

struct GoalHomeItemView: View {
    var goal: GoalItem
    
    var body: some View {
        
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(goal.title).font(.headline)
                    Text("진행률 : \(goal.progress)%").font(.caption).foregroundStyle(.secondary)
                    Text(goal.deadLine, style: .date)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                }
                Spacer()
            }
            .padding(.vertical, 8)
        }
}
