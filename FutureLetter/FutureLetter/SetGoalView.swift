import SwiftUI

struct GoalCategory: Codable, Identifiable {
    let categoriesId: String
    let name: String
    
    var id: Int { Int(categoriesId) ?? 0 }
    
    enum CodingKeys: String, CodingKey {
        case categoriesId
        case name
    }
}

struct SetGoalView: View {
    
    @EnvironmentObject var appState: AppState
    @Environment(\.presentationMode) var presentationMode
    
    private let goalService = GoalCategoryService()
    
    @State private var title = ""
    @State private var deadLine = Date()
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    // 카테고리
    @State private var categories: [GoalCategory] = []
    @State private var selectedCategoryId: Int?
    
    var body: some View {
        VStack(spacing: 12) {
            
            Text("목표 작성")
                .font(.title2)
                .foregroundColor(.black) // 배경색에 따라 가독성 조정 (필요시 .white)
            
            TextField("제목", text: $title)
                .textFieldStyle(.roundedBorder)
            
            DatePicker("완료 기한", selection: $deadLine, displayedComponents: .date)
                .datePickerStyle(.compact)
            //.environment(\.colorScheme, .dark) // 필요시 활성화
            
            Divider()
            
            ScrollView(.horizontal, showsIndicators: false) {
                categoriesView
            }
            .frame(height: 40)
            
            Divider()
            
            Button {
                postGoalToServer()
            } label: {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray)
                        .cornerRadius(8)
                } else {
                    Text("저장")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.yellow)
                        .cornerRadius(8)
                        .foregroundColor(.white)
                }
            }
            .disabled(isLoading)
            
            Spacer()
        }
        .padding()
        // .background(Color("NavyBackground").edgesIgnoringSafeArea(.all)) // 필요시 활성화
        .alert(isPresented: $showAlert) {
            Alert(title: Text("알림"), message: Text(alertMessage), dismissButton: .default(Text("확인")))
        }
        .onAppear {
            loadCategories()
        }
    }
    
    // 카테고리 선택 뷰
    var categoriesView : some View {
        HStack(spacing: 8) {
            ForEach(categories) { category in
                Button(action: {
                    selectedCategoryId = category.id
                }) {
                    Text(category.name)
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(
                            category.id == selectedCategoryId ? Color.blue : Color.gray.opacity(0.3)
                        )
                        .foregroundColor(.white)
                        .cornerRadius(15)
                }
            }
        }
        .padding(.horizontal)
    }
    
    func loadCategories() {
        goalService.fetchCategories{ decodedCategories in
            DispatchQueue.main.async {
                self.categories = decodedCategories
            }
        }
    }
    
    // 서버 전송
    func postGoalToServer() {
        guard !title.isEmpty else {
            alertMessage = "제목을 입력해주세요."
            showAlert = true
            return
        }
        
        guard let categoryId = selectedCategoryId else {
            alertMessage = "카테고리를 선택해주세요."
            showAlert = true
            return
        }
        
        guard let url = URL(string: "http://124.56.5.77/fletter/setgoal.php") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        // 날짜 변환
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: deadLine)
        let todayString = dateFormatter.string(from: Date()) // 오늘 날짜
        
        // 현재 유저 ID
        let currentUserId = appState.currentUser?.usersId ?? 0
       
        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "usersId", value: "\(currentUserId)"),
            URLQueryItem(name: "title", value: title),
            URLQueryItem(name: "deadLine", value: dateString),
            URLQueryItem(name: "categoriesId", value: "\(categoryId)")
        ]

        request.httpBody = components.percentEncodedQuery?.data(using: .utf8)
        
        isLoading = true
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async { isLoading = false }
            
            if let error = error {
                DispatchQueue.main.async {
                    alertMessage = "요청 실패: \(error.localizedDescription)"
                    showAlert = true
                }
                return
            }
            
            guard let data = data, let responseString = String(data: data, encoding: .utf8) else { return }
            
            print("서버 응답:", responseString)
            
            DispatchQueue.main.async {
                if responseString.contains("success") {
                    alertMessage = "목표가 성공적으로 저장되었습니다!"
                    showAlert = true

                    let g = Goal(
                        goalsId: 0,
                        title: title,
                        deadLine: dateString,
                        categoriesId: categoryId,
                        creationDate: todayString,
                        createdAt: todayString,
                        updatedAt: nil,
                        
                        usersId: currentUserId,
                        category: nil,
                        progress: 0,
                        description: ""
                    )

                    appState.goals.insert(g, at: 0)

                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        presentationMode.wrappedValue.dismiss()
                    }
                    
                } else {
                    alertMessage = "저장 실패: \(responseString)"
                    showAlert = true
                }
            }
        }.resume()
    }
}
