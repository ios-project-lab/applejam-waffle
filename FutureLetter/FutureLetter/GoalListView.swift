import SwiftUI

struct GoalListView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationView {
            List {
                ForEach(appState.goals) { goal in
                    GoalRowView(goal: goal)
                }
                .onDelete(perform: deleteGoal)
            }
            .listStyle(.insetGrouped)
            .navigationTitle("나의 목표")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: SetGoalView()
                            .environmentObject(appState) ) {
                        Image(systemName: "plus.circle.fill")
                            .imageScale(.large)
                    }
                }
            }
        }
    }

    private func deleteGoal(at offsets: IndexSet) {
        appState.goals.remove(atOffsets: offsets)
    }
}

// 각 Row를 별도 View로 분리 (타입 추론 간소화)
struct GoalRowView: View {
    let goal: Goal

    var body: some View {
        NavigationLink(destination: GoalItemView(goal: goal)) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(goal.title)
                        .font(.headline)
                    Text(goal.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                // dueDate가 Date 타입일 때만 이렇게 사용
                Text(goal.deadLine, style: .date)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.vertical, 8)
        }
    }
}
