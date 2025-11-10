//
//  Untitled.swift
//  FutureLetter
//
//  Created by Chaemin Yu on 11/10/25.
//

import Foundation

class AIService {
    func analyze(action: String, text: String, completion: @escaping ([String: Any]?) -> Void) {
        guard let url = URL(string: "https://localhost/fletter/openai.php") else { return }

        let body: [String: Any] = [
            "action": action,
            "text": text
        ]

        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data = data else { completion(nil); return }
            let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
            completion(json)
        }.resume()
    }
}
