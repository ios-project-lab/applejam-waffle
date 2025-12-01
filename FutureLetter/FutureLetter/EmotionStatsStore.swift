//
//  EmotionStatsStore.swift
//  FutureLetter
//
//  Created by Chaemin Yu on 12/1/25.
//

import Foundation

class EmotionStatsStore: ObservableObject {
    @Published var emotionPoints: [EmotionPoint] = []
    @Published var topicStats: [TopicStats] = []
    @Published var latestAICheer: AICheering? = nil

    func loadEmotionStats(userId: Int) {
        guard let url = URL(string: "http://124.56.5.77/fletter/getUserEmotionStats.php?userId=\(userId)") else { return }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data,
               let decoded = try? JSONDecoder().decode([EmotionPoint].self, from: data) {
                DispatchQueue.main.async {
                    self.emotionPoints = decoded
                }
            }
        }.resume()
    }

    func loadTopicStats(userId: Int) {
        guard let url = URL(string: "http://124.56.5.77/fletter/getUserTopicStats.php?userId=\(userId)") else { return }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data,
               let decoded = try? JSONDecoder().decode([TopicStats].self, from: data) {
                DispatchQueue.main.async {
                    self.topicStats = decoded
                }
            }
        }.resume()
    }

    func loadLatestAICheer(userId: Int) {
        guard let url = URL(string: "http://124.56.5.77/fletter/getUserAIOverview.php?userId=\(userId)") else { return }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data,
               let decoded = try? JSONDecoder().decode(AICheeringOverview.self, from: data),
               let cheerString = decoded.aiCheering,
               let cheerData = cheerString.data(using: .utf8),
               let cheer = try? JSONDecoder().decode(AICheering.self, from: cheerData) {
                
                DispatchQueue.main.async {
                    self.latestAICheer = cheer
                }
            }
        }.resume()
    }
    
    private func extractDate(from letter: Letter) -> String {
        // createdAt 이 있으면 그거 써도 되고, 없으면 expectedArrivalTime 기준
        let raw = letter.expectedArrivalTime
        return String(raw.prefix(10))   // "2025-12-01 10:00:00" -> "2025-12-01"
    }

    
    func updateEmotionPoints(from letters: [Letter]) {
        emotionPoints.removeAll()

        for letter in letters {
            if let json = letter.aiCheering,
               let data = json.data(using: .utf8),
               let decoded = try? JSONDecoder().decode(AICheering.self, from: data) {

                let score = decoded.sentiment_analysis.score
                let date = extractDate(from: letter)
                
                emotionPoints.append(EmotionPoint(date: date, score: score))
            }
        }
    }

}
