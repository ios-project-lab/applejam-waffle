import SwiftUI

struct GoalHomeItemView: View {
    // ✅ 수정: GoalItem -> Goal 로 변경
    let goal: Goal
    
    var body: some View {
        HStack {
            Image(systemName: "target")
                .foregroundColor(.blue)
                .font(.title2)
                .padding(.trailing, 5)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(goal.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("마감: \(goal.deadLine)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // 진행률 표시 (Optional 처리)
            if let progress = goal.progress {
                Text("\(progress)%")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
            } else {
                // 진행률 없으면 대기중 표시 등
                Text("-")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 4)
    }
}
