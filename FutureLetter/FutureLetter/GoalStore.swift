import Foundation
import Combine

class GoalStore: ObservableObject {
    @Published var goals: [GoalItem] = []
    @Published var isLoading: Bool = false
    
        private let baseURLString = "http://localhost/fletter/getGoals.php"
        private var currentUserId: Int {
            return UserDefaults.standard.integer(forKey: "currentUserPK")
        }

        func loadGoalsFromServer() {
            let userId = currentUserId
                    
            // 사용자 ID가 0이거나 유효하지 않으면 로드하지 않습니다.
            // (UserDefaults.standard.integer(forKey:)는 키가 없으면 0을 반환합니다.)
            if userId == 0 {
                print("오류: 유효한 currentUserId를 찾을 수 없습니다. (ID: 0)")
                DispatchQueue.main.async { self.isLoading = false }
                return
            }
            
            // 사용자 ID를 포함한 URL 구성
            guard var urlComponents = URLComponents(string: baseURLString) else {
                print("잘못된 baseURLString")
                return
            }
            
            // 쿼리 파라미터 추가: ?userId=123 (예시)
            urlComponents.queryItems = [
                URLQueryItem(name: "userId", value: String(userId))
            ]
            
            guard let url = urlComponents.url else {
                print("userId가 포함된 URL 구성 실패")
                return
            }
            
            // 로딩 상태 시작
            DispatchQueue.main.async {
                self.isLoading = true
            }

            URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                
                // 응답은 백그라운드 스레드에서 처리
                defer { // 통신이 끝나면 로딩 상태 해제
                    DispatchQueue.main.async { self?.isLoading = false }
                }
                
                if let error = error {
                    print("목표 로드 요청 실패:", error.localizedDescription)
                    return
                }
                
                guard let data = data else {
                    print("서버 응답 데이터 없음")
                    return
                }

                // 3. JSON 디코딩 시도
                do {
                    let decoder = JSONDecoder()
                    
                    // 서버 날짜 포맷에 맞게 설정 (yyyy-MM-dd)
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    decoder.dateDecodingStrategy = .formatted(dateFormatter)
                    
                    let decodedGoals = try decoder.decode([GoalItem].self, from: data)
                    
                    // 4. 메인 스레드에서 @Published 변수 업데이트 (뷰 자동 갱신)
                    DispatchQueue.main.async {
                        self?.goals = decodedGoals
                        print("목표 데이터 로드 및 업데이트 완료: \(decodedGoals.count)개")
                    }
                    
                } catch {
                    if let responseString = String(data: data, encoding: .utf8) {
                        print("JSON 디코딩 실패 - 서버 응답 원문:", responseString)
                    }
                    print("JSON 디코딩 실패 오류:", error)
                }

            }.resume()
        }
    
    func deleteGoal(at offsets: IndexSet) {
        goals.remove(atOffsets: offsets)
        // Todo: 서버에 DELETE 요청을 보내는 실제 로직 추가
    }
}
