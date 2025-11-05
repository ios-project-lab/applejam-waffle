import SwiftUI

struct GoalListView: View {
    // Todo: 서버 데이터 삽입
    @State private var goals: [GoalItem] = [
        // 초기 목표 데이터를 넣어 테스트
        GoalItem(title: "와플 먹기", category: "습관", description: "맛있는 와플 먹기", creationDate: Date(), deadLine: Calendar.current.date(byAdding: .day, value: 7, to: Date())!, progress: 10),
        GoalItem(title: "두 번째 목표", category: "공부", description: "SwiftUI 마스터하기", creationDate: Date(), deadLine: Calendar.current.date(byAdding: .day, value: 14, to: Date())!, progress: 50),
        GoalItem(title: "세 번째 목표", category: "운동", description: "매일 달리기", creationDate: Date(), deadLine: Calendar.current.date(byAdding: .day, value: 21, to: Date())!, progress: 80)
    ]

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 15) {
                    ForEach(goals) { goal in
                        // NavigationLink로 GoalItemView 전체를 감싸 카드 전체 탭 가능하게 함
                        NavigationLink(destination: Text("\(goal.title) 상세 뷰")) {
                            // GoalItemView를 카드처럼 표시
                            GoalItemView(goal: goal)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
            }
            // 푸터바 색상 유지. bottom->푸터바 색상 노란색 / top-> 기본 설정
            .background(Color.yellow.edgesIgnoringSafeArea(.top))
            
            .navigationTitle("나의 목표")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: Text("SetGoalView Placeholder")) {
                        Image(systemName: "plus.circle.fill")
                            .imageScale(.large)
                    }
                }
            }
        }
    }

    private func deleteGoal(at offsets: IndexSet) {
        goals.remove(atOffsets: offsets)
    }
}
