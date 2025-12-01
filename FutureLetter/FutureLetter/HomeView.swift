//
//  HomeView.swift
//  FutureLetter
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var goalStore: GoalStore
    @EnvironmentObject var statsStore: EmotionStatsStore
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {

                VStack(spacing: 16) {
                    HStack {
                        VStack(alignment: .leading) {
                            EmotionGraphView()
                                .environmentObject(statsStore)
                        }
                        Spacer()
                    }
                   
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
                statsStore.loadEmotionStats(userId: appState.currentUser?.usersId ?? 0)
                statsStore.loadTopicStats(userId: appState.currentUser?.usersId ?? 0)
                statsStore.loadLatestAICheer(userId: appState.currentUser?.usersId ?? 0)
                
                print("===== 📈 감정 그래프 디버깅 =====")

                if statsStore.emotionPoints.isEmpty {
                    print("⚠️ 그래프 데이터 없음")
                } else {
                    for (i, point) in statsStore.emotionPoints.enumerated() {
                        print("[\(i)] 날짜: \(point.date), 점수: \(point.score)")
                    }
                }

                let maxScore = statsStore.emotionPoints.map { $0.score }.max() ?? 0
                print("📈 최대 점수 =", maxScore)

                print("===============================")

                
                // 로드 호출
                if goalStore.goals.isEmpty {
                    // Todo: 예외처리
                }
                
                if appState.allLetters.isEmpty {
                    appState.fetchAllLetters()
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
