//
//  HomeView.swift
//  FutureLetter
//
//  Created by Chaemin Yu on 10/27/25.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        NavigationStack {
            VStack {
                Text("홈")
                    .font(.title)
                    .padding()
                Text("홈 페이지")
                List {
                    NavigationLink("정보 수정", destination: ProfileUpdateView())
                    NavigationLink("편지 쓰기", destination: LetterComposeView())
                    NavigationLink("편지 열기", destination: LetterDetailView()) // 최근 도착한 편지
                    NavigationLink("목표 작성하기", destination: SetGoalView())
                    NavigationLink("목표 관리하기", destination: GoalListView())
                    
                }
                .navigationTitle("친구 목록")
            }
        }
        .navigationTitle("친구")
    }
}

#Preview {
    HomeView()
}
