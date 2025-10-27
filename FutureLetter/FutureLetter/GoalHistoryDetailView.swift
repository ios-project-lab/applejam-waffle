//
//  GoalHistoryDetailView.swift
//  FutureLetter
//
//  Created by Chaemin Yu on 10/27/25.
//

import SwiftUI

struct GoalHistoryDetailView: View {
    var body: some View {
        NavigationLink(destination: LetterDetailView()){
            Text("관련 편지 보기")
        }
    }
}

#Preview {
    GoalHistoryDetailView()
}
