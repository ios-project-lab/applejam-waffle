//
//  LetterService.swift
//  FutureLetter
//
//  Created by 강채원 on 11/17/25.
//

/** 요청 예시
 request: usersId(pk), lettersId(pk)
 response: lettersId로 조회한 편지 상세 내역 1개
 ex)
 func loadLetter() {
     letterService.getLetterByLettersId(
         usersId: usersId,
         lettersId: lettersId
     ) { items in
         DispatchQueue.main.async {
             self.letterItem = items.first
         }
     }
 }
 
 */

import Foundation


class LetterService {
    
    // 비동기 함수로 카테고리 로드 기능 제공
    func getLetterByLettersId(
                usersId: Int,
                lettersId: Int,
                completion: @escaping ([LetterItem]
        ) -> Void) {
        
        let urlString = "http://localhost/fletter/getLetterByLettersId.php?userId=\(usersId)&letterId=\(lettersId)"
            
        guard let url = URL(string: urlString) else {
            print("잘못된 URL")
            completion([])
            return
        }
        
        // Request 설정
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("편지 상세 로드 요청 실패:", error)
                completion([])
                return
            }

            guard let data = data else {
                print("데이터 없음")
                completion([])
                return
            }

            do {
                let decoder = JSONDecoder()
                
                // 서버 날짜 포맷에 맞게 설정 (yyyy-MM-dd)
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                decoder.dateDecodingStrategy = .formatted(dateFormatter)
                
                let decodedData = try decoder.decode([LetterItem].self, from: data)
                
                // 데이터만 클로저를 통해 호출자에게 전달
                completion(decodedData)
                
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
