//
//  Untitled.swift
//  FutureLetter
//
//  Created by Chaemin Yu on 11/10/25.
//

import Foundation

class AIService {

    func analyze(
        title: String,
        content: String,
        expectedArrivalTime: String,
        receiverType: Int,
        senderId: Int,
        receiverId: Int,
        arrivedType: Int,
        emotionsId: Int,
        parentLettersId: Int,
        text: String,
        emotion: String,
        goal: String,
        completion: @escaping ([String: Any]?) -> Void
    ) {

        guard let url = URL(string: "http://124.56.5.77/fletter/openai.php") else {
            print("잘못된 URL")
            completion(nil)
            return
        }

        let body: [String: Any] = [
            "title": title,
            "content": content,
            "expectedArrivalTime": expectedArrivalTime,
            "receiverType": receiverType,
            "senderId": senderId,
            "receiverId": receiverId,
            "arrivedType": arrivedType,
            "emotionsId": emotionsId,
            "parentLettersId": parentLettersId,
            "text": text,
            "emotion": emotion,
            "goal": goal
        ]

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: req) { data, res, err in

            if let err = err {
                print("❌ 서버 요청 실패:", err.localizedDescription)
                completion(nil)
                return
            }

            guard let data = data else {
                print("❌ 데이터 없음")
                completion(nil)
                return
            }

            let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
            print("📩 서버 응답:", json ?? [:])
            completion(json)

        }.resume()
    }
}
