import SwiftUI
struct GoalItem: Codable, Identifiable {

    let id = UUID()
    var goalsId : Int = 0
    var currentUserId : Int = UserDefaults.standard.integer(forKey: "currentUserPK")
    var title: String
    var category: String
    var description: String
    var creationDate: Date
    var deadLine: Date
    var progress: Int = 0
    var completed: Bool = false

}
struct GoalItemView: View {
    var goal: GoalItem
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 8) {
            
            // 목표명, 카테고리 등 내용들... (HStack 내용 생략)
            HStack { Text("목표명 :").fontWeight(.semibold); Text(goal.title) }
            HStack { Text("카테고리 :").fontWeight(.semibold); Text(goal.category) }
            HStack { Text("작성일 :").fontWeight(.semibold); Text("\(goal.creationDate, style: .date)") }
            HStack { Text("마감일 :").fontWeight(.semibold); Text("\(goal.deadLine, style: .date)") }
            HStack { Text("진행률 :").fontWeight(.semibold); Text("\(goal.progress)%") }

            NavigationLink(destination: Text("\(goal.title) 히스토리 뷰")) {
                Text("히스토리 보기")
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.yellow)
                    .foregroundColor(.black)
                    .cornerRadius(5)
            }
            .buttonStyle(PlainButtonStyle())
        }
        // 카드 디자인 적용
        .padding()
        .background(Color.white)
        .foregroundColor(.black)
        .cornerRadius(15)
    }
}
