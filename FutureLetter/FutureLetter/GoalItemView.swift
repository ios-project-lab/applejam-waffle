//
//  GoalItemView.swift
//  FutureLetter
//
//  Created by Chaemin Yu on 10/27/25.
//

import SwiftUI

struct GoalItemView: View {
    var body: some View {
        NavigationLink(destination: GoalHistoryListView()){
            Text("목표 히스토리 보기")
        }
    }
}

#Preview {
    GoalItemView()
}
