import SwiftUI

struct GoalListView: View {
    @StateObject var goalStore = GoalStore()
    @State private var categories: [GoalCategory] = [] // 서버에서 불러온 카테고리 목록
    @State private var selectedCategoryId: Int? // 현재 선택된 카테고리 ID

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) { // <--- categoriesView와 contentView를 수직으로 배치하기 위해 VStack 추가
                categoriesView
                contentView
            }
            .onAppear {
                goalStore.loadGoalsFromServer()
                fetchCategories()
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
    var categoriesView : some View {
        HStack(spacing: 8) {
            // categories 배열을 사용하여 버튼을 동적으로 생성합니다.
            ForEach(categories) { category in
                Button(action: {
                    // 버튼 클릭 시 선택 상태 업데이트
                    selectedCategoryId = category.id
                }) {
                    Text(category.name)
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(
                            // 선택된 카테고리에 따라 배경색 변경
                            category.id == selectedCategoryId ? Color.blue : Color.gray.opacity(0.3)
                        )
                        .foregroundColor(.white)
                        .cornerRadius(15)
                }
            }
        }
        .padding(.horizontal)
    }

    var contentView: some View {
        ScrollView {
            LazyVStack(spacing: 15) {
                ForEach(goalStore.goals.filter { goal in
                    // 1. selectedCategoryId가 nil이면 (아무것도 선택 안 됨), 모든 목표를 표시 (true 반환)
                    // 2. selectedCategoryId가 값이 있으면, 해당 ID와 goal.categoryId가 일치하는 목표만 표시
                    selectedCategoryId == nil || goal.categoriesId == selectedCategoryId
                }) { goal in // 필터링된 목표(goal)를 사용하여 GoalItemView 생성
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
    // GET
    // 뷰 내부에서 카테고리 데이터를 불러오는 함수
        func fetchCategories() {
            
            guard let url = URL(string: "http://localhost/fletter/getcategories.php") else {
                print("잘못된 URL")
                return
            }

            URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    print("카테고리 로드 요청 실패:", error)
                    return
                }

                guard let data = data else {
                    print("데이터 없음")
                    return
                }

                do {
                    let decodedCategories = try JSONDecoder().decode([GoalCategory].self, from: data)
                    DispatchQueue.main.async {
                        self.categories = decodedCategories
                    }
                } catch {
                    if let responseString = String(data: data, encoding: .utf8) {
                        print("서버 응답 원문:", responseString)
                    }
                    print("JSON 디코딩 실패:", error)
                }

            }.resume()
        }
    
}
