//
//  GoalListView.swift
//  FutureLetter
//

//  Created by Chaemin Yu on 10/27/25.
//

import SwiftUI

struct GoalListView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationView {
            List {
                ForEach(appState.goals) { goal in
                    NavigationLink(destination: GoalItemView(goal: goal)) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(goal.title).font(.headline)
                                Text(goal.description).font(.caption)
                            }
                            Spacer()
                            Text(goal.dueDate, style: .date).font(.caption)
                        }.padding(.vertical, 8)
                    }
                }
                .onDelete { indexSet in
                    appState.goals.remove(atOffsets: indexSet)
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("나의 목표")
            .toolbar {
                NavigationLink(destination: SetGoalView()) {
                    Image(systemName: "plus.circle.fill")
                }
            }
        }
    }
}


