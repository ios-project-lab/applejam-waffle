//
//  GoalItemView.swift
//  FutureLetter
//
//  Created by Chaemin Yu on 10/27/25.
//

import SwiftUI

struct GoalItemView: View {
    @EnvironmentObject var appState: AppState
    var goal: Goal

    var body: some View {
        VStack(spacing: 12) {
            Text(goal.title).font(.title2)
            Text(goal.description).font(.body)
            Text("기한: \(goal.dueDate, style: .date)")
            Spacer()
        }
        .padding()
        .navigationTitle("목표 상세")
        .background(Color("NavyBackground").edgesIgnoringSafeArea(.all))
    }
}

