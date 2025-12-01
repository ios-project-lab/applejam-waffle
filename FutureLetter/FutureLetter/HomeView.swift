//
//  HomeView.swift
//  FutureLetter
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var goalStore: GoalStore
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {

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
                        .overlay(Text("그래프 삽입 예정").foregroundColor(.gray))
                    
                    HStack {
                        NavigationLink(destination: SetGoalView()) {
                            Text("목표 작성")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.yellow)
                                .cornerRadius(8)
                                .foregroundColor(.white)
                        }
                        NavigationLink(destination: LetterComposeView()) {
                            Text("편지쓰기")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.yellow)
                                .cornerRadius(8)
                                .foregroundColor(.white)
                        }
                        NavigationLink(destination: FriendSearchView()) {
                            Text("친구찾기")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.yellow)
                                .cornerRadius(8)
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding()
                .background(Color("NavyBackground"))
         
                List {
                    RecentLettersSection()
                    GoalsSection()
                }
                .listStyle(.insetGrouped)
            }
            .navigationTitle("홈")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                // 데이터 로드
                if goalStore.goals.isEmpty {
                    goalStore.loadGoalsFromServer()
                }
                if appState.inbox.isEmpty {
                    appState.fetchInbox()
                }
            }
        }
    }
}

struct RecentLettersSection: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        Section(header: Text("최근 편지")) {
            if appState.inbox.isEmpty {
                Text("도착한 편지가 없습니다.")
                    .foregroundColor(.gray)
            } else {
                ForEach(Array(appState.inbox.prefix(3))) { letter in
                    NavigationLink(destination: LetterDetailView(letter: letter)) {
                        LetterItemView(letter: letter)
                    }
                }
            }
        }
    }
}

struct GoalsSection: View {
    @EnvironmentObject var goalStore: GoalStore

    var body: some View {
        Section(header: Text("내 목표")) {
            if goalStore.goals.isEmpty {
                Text("등록된 목표가 없습니다.")
                    .foregroundColor(.gray)
            } else {
                ForEach(topSummaries) { goal in
                    NavigationLink {
                        Text("\(goal.title) 상세 뷰")
                    } label: {
                        GoalHomeItemView(goal: goal)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
    
    private var topSummaries: [Goal] {
        let sorted = goalStore.goals.sorted {
            ($0.creationDate ?? "") > ($1.creationDate ?? "")
        }
        return Array(sorted.prefix(3))
    }
}
