//
//  GoalHistoryItemView.swift
//  FutureLetter
//
//  Created by Chaemin Yu on 10/27/25.
//

import SwiftUI

struct GoalHistoryItem: Codable {

    var goalHistoriesId : Int = 0
    var title: String
    // var bookmark: Int = 0
    var goalsId: Int = 0
    var createdAt: Date?
    var updatedAt: Date?
    var lettersId: Int = 0

}

struct GoalHistoryItemView: View {
    var history: GoalHistoryItem
    
    var body: some View {
        
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(history.title).font(.headline)
                    Text("생성일 : \(history.createdAt)%").font(.caption).foregroundStyle(.secondary)
                    // Todo: 북마크 여부
                    
                }
                Spacer()
            }
            .padding(.vertical, 8)
        }
}
