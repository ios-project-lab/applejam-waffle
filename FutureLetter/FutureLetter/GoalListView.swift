import SwiftUI

struct GoalListView: View {
    // 수정: AppState 대신 @State로 목표 목록을 직접 관리
    // Todo: 서버 데이터 삽입
    @State private var goals: [GoalItem] = [
        // 초기 목표 데이터를 넣어 테스트
        GoalItem(title: "와플 먹기", category: "습관", description: "맛있는 와플 먹기", creationDate: Date(), deadLine: Calendar.current.date(byAdding: .day, value: 7, to: Date())!, progress: 10),
        GoalItem(title: "와플 먹기", category: "습관", description: "맛있는 와플 먹기", creationDate: Date(), deadLine: Calendar.current.date(byAdding: .day, value: 7, to: Date())!, progress: 10),
        GoalItem(title: "와플 먹기", category: "습관", description: "맛있는 와플 먹기", creationDate: Date(), deadLine: Calendar.current.date(byAdding: .day, value: 7, to: Date())!, progress: 10)
    ]

    var body: some View {
            NavigationView {
                ScrollView {
                    LazyVStack(spacing: 15) {
                        ForEach(goals) { goal in
                            // NavigationLink로 감싸서 카드 전체를 탭 가능하게 함
                            NavigationLink(destination: Text("Detail View Placeholder")) {
                                GoalItemView(goal: goal)
                            }
                        
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding()
                }
                .background(Color.yellow.edgesIgnoringSafeArea(.all)) // 배경색
                .navigationTitle("나의 목표")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                
                    NavigationLink(destination: SetGoalView()) { // 임시 Placeholder
                        Image(systemName: "plus.circle.fill")
                            .imageScale(.large)
                    }
                }
            }
        }
    }

    // 목표 삭제 함수는 @State 변수를 직접 변경합니다.
    private func deleteGoal(at offsets: IndexSet) {
        goals.remove(atOffsets: offsets)
    }
}
