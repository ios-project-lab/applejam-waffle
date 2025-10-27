//
//  GoalListView.swift
//  FutureLetter
//
<<<<<<< HEAD
//  Created by mac08 on 10/27/25.
=======
//  Created by Chaemin Yu on 10/27/25.
>>>>>>> 0f9b67856fd066d517725d7517b03dc716b070dd
//

import SwiftUI

struct GoalListView: View {
    var body: some View {
<<<<<<< HEAD
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
=======
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
>>>>>>> 0f9b67856fd066d517725d7517b03dc716b070dd
    }
}

#Preview {
    GoalListView()
}
