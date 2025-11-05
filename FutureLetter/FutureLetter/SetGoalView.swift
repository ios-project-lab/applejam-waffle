import SwiftUI

struct GoalCategory: Codable, Identifiable {
    let categoriesId: String // PHP 응답에 맞춰 String으로 받기
    let name: String
    
    // id를 Int로 사용하기 위해 변환
    var id: Int { Int(categoriesId) ?? 0 }
    
    enum CodingKeys: String, CodingKey {
        case categoriesId
        case name
    }
}
struct SetGoalView: View {
    
    /** 반환을 위한 데이터들 */
    @EnvironmentObject var appState: AppState
    @Environment(\.presentationMode) var presentationMode

    @State private var title = ""
    @State private var description = ""
    @State private var deadLine = Date()
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    // 카테고리 구조체
    @State private var categories: [GoalCategory] = [] // 서버에서 불러온 카테고리 목록
    @State private var selectedCategoryId: Int? // 현재 선택된 카테고리 ID

    var body: some View {
        VStack(spacing: 12) {
            
            Text("목표 작성")
                .font(.title2)
                .foregroundColor(.white)

            TextField("제목", text: $title)
                .textFieldStyle(.roundedBorder)

            TextField("설명", text: $description)
                .textFieldStyle(.roundedBorder)

            DatePicker("완료 기한", selection: $deadLine, displayedComponents: .date)
                .datePickerStyle(.compact)
            Divider()
                        ScrollView(.horizontal, showsIndicators: false) {
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
                        .frame(height: 40) // 스크롤 뷰 높이 제한

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
        .background(Color("NavyBackground").edgesIgnoringSafeArea(.all))
        .alert(isPresented: $showAlert) {
            Alert(title: Text("알림"), message: Text(alertMessage), dismissButton: .default(Text("확인")))
        }
        .onAppear { // 뷰가 로드될 때 카테고리 표시
                    fetchCategories()
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
                        self.selectedCategoryId = decodedCategories.first?.id
                    }
                } catch {
                    if let responseString = String(data: data, encoding: .utf8) {
                        print("서버 응답 원문:", responseString)
                    }
                    print("JSON 디코딩 실패:", error)
                }

            }.resume()
        }
    
    // POST

    func postGoalToServer() {
        guard !title.isEmpty, !description.isEmpty else {
            alertMessage = "모든 항목을 입력해주세요."
            showAlert = true
            return
        }

        let url = URL(string: "http://localhost/fletter/setgoal.php")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        // 날짜를 문자열로 변환
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: deadLine)
        let currentUserId = UserDefaults.standard.integer(forKey: "currentUserPK")
        print ("usersId: \(currentUserId)")
        // optional 해제
        guard let categoryId = selectedCategoryId else {
            alertMessage = "카테고리를 선택해주세요."
            showAlert = true
            return
        }

        // POST 데이터 구성
        let postString = "usersId=\(currentUserId)&title=\(title)&description=\(description)&dueDate=\(dateString)&categoryId=\(categoryId)"
        // Log
        print ("서버로 전송: \(postString)")

        request.httpBody = postString.data(using: .utf8)

        isLoading = true

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
            }

            if let error = error {
                // Log
                print("요청 실패:", error)
                DispatchQueue.main.async {
                    alertMessage = "서버 요청 실패: \(error.localizedDescription)"
                    showAlert = true
                }
                return
            }

            guard let data = data,
                  let responseString = String(data: data, encoding: .utf8) else {
                DispatchQueue.main.async {
                    alertMessage = "서버 응답이 올바르지 않습니다."
                    showAlert = true
                }
                return
            }

            print("서버 응답:", responseString)

            DispatchQueue.main.async {
                if responseString.contains("success") {
                    alertMessage = "목표가 성공적으로 저장되었습니다!"
                    showAlert = true
                    // 서버 저장 후 로컬에도 추가
                    let g = Goal(title: title, description: description, deadLine: deadLine)
                    // appState.goals.insert(g, at: 0)
                    presentationMode.wrappedValue.dismiss()
                    
                } else {
                    alertMessage = "목표 저장에 실패했습니다. 다시 시도해주세요."
                    showAlert = true
                }
            }
        }.resume()
    }
}

