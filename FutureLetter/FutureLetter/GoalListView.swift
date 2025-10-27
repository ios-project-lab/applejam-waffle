//
//  GoalListView.swift
//  FutureLetter
//
//  Created by Chaemin Yu on 10/27/25.
//

import SwiftUI

struct GoalListView: View {
    var body: some View {
        NavigationView{
            VStack{
                NavigationLink(destination: GoalHistoryListView()){
                    Text("목표 히스토리 보기")
                }
                NavigationLink(destination: GoalHistoryDetailView()){
                    Text("목표 히스토리 detail 보기")
                }
                NavigationLink(destination: GoalItemView()){
                    Text("목표 보기")
                }
            }
        }
    }
}

#Preview {
    GoalListView()
}
