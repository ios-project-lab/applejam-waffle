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
            
            // 목표명, 카테고리 등 내용들...
            HStack {
                Text("목표명 :").fontWeight(.semibold)
                Text(goal.title)
            }
            HStack {
                Text("카테고리 :").fontWeight(.semibold)
                Text(goal.category)
            }
            HStack {
                Text("작성일 :").fontWeight(.semibold)
                Text("\(goal.creationDate, style: .date)")
            }
            HStack {
                Text("마감일 :").fontWeight(.semibold)
                Text("\(goal.deadLine, style: .date)")
            }
            HStack {
                Text("진행률 :").fontWeight(.semibold)
                Text("\(goal.progress)%")
            }
            
            Button("히스토리 보기") {
                // TODO: 히스토리 보기 액션 구현
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5) // 버튼에 수직 패딩 추가
            .background(Color.yellow)
            .foregroundColor(.black)
            .cornerRadius(5)
            
        }
        
        .padding() // 내용물과 카드 테두리 사이의 간격
        .background(Color.white) // 배경색 흰색
        .foregroundColor(.black) // 텍스트 색상 검은색 (NavigationLink의 파란색 방지)
        .cornerRadius(15) // 둥근 모서리
        
    }
}
