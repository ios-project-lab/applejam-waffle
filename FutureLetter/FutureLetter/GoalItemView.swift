import SwiftUI

struct GoalItemView: View {
    var goal: Goal

    private var validCreationDate: Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let dateStr = goal.creationDate ?? goal.createdAt else { return Date() }
        return formatter.date(from: String(dateStr.prefix(10))) ?? Date()
    }
    
    private var validDeadLine: Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: String(goal.deadLine.prefix(10))) ?? Date()
    }
    
    var body: some View {
        // 카드 디자인
        VStack(alignment: .leading, spacing: 8) {
            
            HStack {
                Text("목표명 :").fontWeight(.semibold)
                Text(goal.title)
            }
            
            HStack {
                Text("카테고리 :").fontWeight(.semibold)
                // 카테고리 이름이 있으면 보여주고, 없으면 ID 표시
                Text(goal.category ?? "\(goal.categoriesId)")
            }
            
            HStack {
                Text("작성일 :").fontWeight(.semibold)
                Text("\(validCreationDate, style: .date)")
            }
            
            HStack {
                Text("마감일 :").fontWeight(.semibold)
                Text("\(validDeadLine, style: .date)")
            }
            
            // 진행률 (데이터가 있으면 표시)
            if let progress = goal.progress {
                HStack {
                    Text("진행률 :").fontWeight(.semibold)
                    Text("\(progress)%")
                }
            }
            
            NavigationLink(destination: Text("히스토리 뷰 (ID: \(goal.goalsId))")) {
                Text("히스토리 보기")
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.yellow)
                    .foregroundColor(.black)
                    .cornerRadius(5)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding()
        .background(Color.white)
        .foregroundColor(.black)
        .cornerRadius(15)
        .shadow(radius: 2)
    }
}
