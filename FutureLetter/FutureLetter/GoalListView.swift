import SwiftUI
struct GoalListView: View {
    @StateObject var goalStore = GoalStore()

    var body: some View {
        NavigationView {
            // 전체 콘텐츠를 불러오는 로직을 별도의 컴퓨터 프로퍼티로 분리
            contentView
            .onAppear {
                goalStore.loadGoalsFromServer()
            }
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

    var contentView: some View {
            ScrollView {
                LazyVStack(spacing: 15) {
                    ForEach(goalStore.goals) { goal in
                        
                        NavigationLink(destination: Text("\(goal.title) 상세 뷰")) {
                            GoalItemView(goal: goal)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
            }
        }
    
}
