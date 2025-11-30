//
//  FriendService.swift
//  FutureLetter
//
//  Created by 강채원 on 11/30/25.
//

import Foundation
class FriendService {
    var currentUserId: Int {
        return UserDefaults.standard.integer(forKey: "currentUserPK")
    }

    /// 친구 요청 API
    func sendFriendRequest(
        friendNickName: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {

        let baseURLString = "http://localhost/fletter/sendFriendRequest.php"
        let usersId = currentUserId

        // URLComponents 사용 필요 없음 → 그냥 URL 만들면 됨
        guard let url = URL(string: baseURLString) else {
            completion(.failure(URLError(.badURL)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        // POST Body
        let body = "usersId=\(currentUserId)&friendNickName=\(friendNickName)"
        request.httpBody = body.data(using: .utf8)

        URLSession.shared.dataTask(with: request) { data, response, error in

            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data,
                  let responseString = String(data: data, encoding: .utf8) else {
                completion(.failure(URLError(.badServerResponse)))
                return
            }

            print("서버 응답:", responseString)

            if responseString.contains("success") {
                completion(.success("친구 요청 성공"))
            } else {
                completion(.failure(NSError(
                    domain: "",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "서버 응답: \(responseString)"]
                )))
            }

        }.resume()
    }
}
