//
//  HomeView.swift
//  FutureLetter
//
//  Created by Chaemin Yu on 10/27/25.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appState: AppState
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("나의 변화 그래프")
                            .font(.headline)
                            .foregroundColor(.white)
                        Text("목표 진행 상황을 확인하세요.")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    Spacer()
                }

                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .frame(height: 120)
                    .overlay(Text("그래프 삽입").foregroundColor(.black).font(.subheadline))

                HStack {
                    NavigationLink(destination: SetGoalView()) {
                        Text("목표 작성").padding().background(Color.white).cornerRadius(8)
                    }
                    NavigationLink(destination: LetterComposeView()) {
                        Text("편지쓰기").padding().background(Color.white).cornerRadius(8)
                    }
                    NavigationLink(destination: FriendSearchView()) {
                        Text("친구찾기").padding().background(Color.white).cornerRadius(8)
                    }
                }

                List {
                    Section(header: Text("최근 편지")) {
                        ForEach(appState.inbox.prefix(3)) { letter in
                            NavigationLink(destination: LetterDetailView(letter: letter)) {
                                LetterItemView(letter: letter)
                            }
                        }
                    }
                    Section(header: Text("내 목표")) {
//                        ForEach(appState.goals) { goal in
//                            NavigationLink(destination: GoalItemView(goal: goal)) {
//                                GoalHomeItemView(goal: goal)
//                            }
//                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
            .padding()
            .navigationTitle("홈")
            .background(Color("NavyBackground").edgesIgnoringSafeArea(.all))
        }
    }
}
