//
//  GoalCategoryService.swift
//  FutureLetter
//
//  Created by 강채원 on 11/5/25.
//

// GoalService.swift

import Foundation

// GoalCategory 모델은 이미 별도 파일에 있다고 가정합니다.

class GoalCategoryService {
    
    // 비동기 함수로 카테고리 로드 기능 제공
    func fetchCategories(completion: @escaping ([GoalCategory]) -> Void) {
        
        guard let url = URL(string: "http://localhost/fletter/getcategories.php") else {
            print("잘못된 URL")
            completion([]) // 실패 시 빈 배열 반환
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("카테고리 로드 요청 실패:", error)
                completion([])
                return
            }

            guard let data = data else {
                print("데이터 없음")
                completion([])
                return
            }

            do {
                let decodedCategories = try JSONDecoder().decode([GoalCategory].self, from: data)
                
                // 데이터만 클로저를 통해 호출자에게 전달
                completion(decodedCategories)
                
            } catch {
                if let responseString = String(data: data, encoding: .utf8) {
                    print("서버 응답 원문:", responseString)
                }
                print("JSON 디코딩 실패:", error)
                completion([])
            }

        }.resume()
    }
}
