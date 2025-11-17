//
//  Untitled.swift
//  FutureLetter
//
//  Created by Chaemin Yu on 11/10/25.
//

import Foundation

class AIService {

    func analyze(
        lettersId: Int,
        text: String,
        emotion: String,
        goal: String,
        completion: @escaping ([String: Any]?) -> Void
    ) {

        guard let url = URL(string: "https://localhost/fletter/openai.php") else {
            completion(nil)
            return
        }

        // PHP가 받을 body 형태
        let body: [String: Any] = [
            "lettersId": lettersId,
            "text": text,
            "emotion": emotion,
            "goal": goal
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data else {
                completion(nil)
                return
            }

            let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
            completion(json)
        }.resume()
    }
}
