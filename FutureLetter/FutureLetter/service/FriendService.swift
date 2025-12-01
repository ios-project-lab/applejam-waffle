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
    func postToServer(url: String,
                      friendsId: Int,
                      completion: @escaping (Result<Data, Error>) -> Void) {

        guard let url = URL(string: url) else {
            completion(.failure(URLError(.badURL)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/x-www-form-urlencoded",
                         forHTTPHeaderField: "Content-Type")

        // friendsId 하나만 보냄
        let bodyString = "friendsId=\(friendsId)"
        request.httpBody = bodyString.data(using: .utf8)

        URLSession.shared.dataTask(with: request) { data, _, error in

            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(URLError(.badServerResponse)))
                return
            }

            completion(.success(data))

        }.resume()
    }

    func loadFriendRequests(currentUserId: Int, completion: @escaping (Result<FriendRequestResponse, Error>) -> Void) {

        // 1) URL → URLComponents로 변환
        guard var urlComponents = URLComponents(string: "http://124.56.5.77/fletter/loadFriendRequests.php") else {
            completion(.failure(URLError(.badURL)))
            return
        }

        // 2) GET 파라미터 추가
        urlComponents.queryItems = [
            URLQueryItem(name: "currentUserId", value: String(currentUserId))
        ]

        // 3) 최종 URL 생성
        guard let finalURL = urlComponents.url else {
            completion(.failure(URLError(.badURL)))
            return
        }

        // 4) GET Request 생성
        var request = URLRequest(url: finalURL)
        request.httpMethod = "GET"

        // 5) 서버 호출
        URLSession.shared.dataTask(with: request) { data, _, error in

            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(URLError(.badServerResponse)))
                return
            }

            // 🔥 Raw Response 출력 (JSON 깨짐 디버그용)
            print("RAW RESPONSE:", String(data: data, encoding: .utf8) ?? "nil")

            do {
                let decoded = try JSONDecoder().decode(FriendRequestResponse.self, from: data)
                completion(.success(decoded))
            } catch {
                completion(.failure(error))
            }

        }.resume()
    }



    /// 친구 요청 API
    func sendFriendRequest(
        friendNickName: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {

        let baseURLString = "http://124.56.5.77/fletter/sendFriendRequest.php"
        _ = currentUserId

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
