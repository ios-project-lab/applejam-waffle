import Foundation
import SwiftUI
import Combine

struct User: Identifiable, Codable {
    let usersId: Int
    let id: String
    let nickName: String
    let password: String?
    let birthDay: String?
    let gender: Int?
    let userStatus: Int?
    let profileImage: String?
    let createdAt: String?
    
    var identifiableId: Int { usersId }
}

struct UpdateProfileResponse: Codable {
    let success: Bool
    let message: String?
    let profileImageUrl: String?
}

struct Goal: Identifiable, Codable {
    let goalsId: Int
    let title: String
    let deadLine: String
    let categoriesId: Int
    
    let creationDate: String?
    let createdAt: String?
    let updatedAt: String?
    let usersId: Int?
    let category: String?
    let progress: Int?
    let description: String?
    
    var id: Int { goalsId }
    
    enum CodingKeys: String, CodingKey {
        case goalsId, title, deadLine, categoriesId
        case creationDate, createdAt, updatedAt
        case usersId, category, progress, description
    }
}

struct Letter: Identifiable, Codable {
    let lettersId: Int
    let title: String
    let content: String
    let senderId: Int
    let senderNickName: String?
    let senderUserId: String?
    let receiverId: Int?
    let receiverNickName: String?
    
    let expectedArrivalTime: String
    let isRead: Int
    let isLocked: Int
    let parentLettersId: Int
    let replyCount: Int?
    
    let goalId: Int?
    
    let aiCheering: String?

    var id: Int { lettersId }

    enum CodingKeys: String, CodingKey {
        case lettersId, title, content
        case senderId, senderNickName, senderUserId
        case receiverId, receiverNickName
        case expectedArrivalTime, isRead, isLocked, parentLettersId, replyCount
        case goalId
        case aiCheering
    }

    var arrivalDate: Date {
        let dateString = String(expectedArrivalTime.prefix(10))
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: dateString) ?? Date.distantFuture
    }
    
    var isActuallyLocked: Bool {
        let today = Calendar.current.startOfDay(for: Date())
        let arrival = Calendar.current.startOfDay(for: arrivalDate)
        return today < arrival
    }
    
    var aiCheeringParsed: AICheering? {
        guard let aiCheering = aiCheering,
              let data = aiCheering.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(AICheering.self, from: data)
    }

}

struct AICheering: Codable {
    let overall_analysis: String
    let sentiment_analysis: SentimentAnalysis
    let goal_analysis: GoalAnalysis

    struct SentimentAnalysis: Codable {
        let sentiment: String
        let score: Double
        let reason: String
    }

    struct GoalAnalysis: Codable {
        let progress_percent: Int
        let feedback: String
        let next_step: String
    }
}

struct EmotionPoint: Identifiable, Codable {
    var id = UUID()
    let date: String
    let score: Double
}

struct TopicStats: Identifiable, Codable {
    var id = UUID()
    let sentiment: String
    let count: Int
}

struct AICheeringOverview: Codable {
    let aiCheering: String?
}

struct AppNotification: Identifiable, Codable {
    let notificationsId: Int
    let title: String
    let content: String
    let isRead: Int
    let createdAt: String
    let notificationTypesId: Int
    let code: String?
    let name: String?
    
    var id: Int { notificationsId }
}


struct Friend: Identifiable, Codable {
    let id: String
    let displayName: String
    let usersId: Int?
    var blocked: Bool = false
}

final class AppState: ObservableObject {
    @Published var currentUser: User? = nil
    @Published var isLoggedIn: Bool = false
    @Published var goals: [Goal] = []
    @Published var allLetters: [Letter] = []
    
    weak var emotionStatsStore: EmotionStatsStore?
    
    var inbox: [Letter] {
        allLetters.filter { $0.receiverId == currentUserId }
    }
    var sentbox: [Letter] {
        allLetters.filter { $0.senderId == currentUserId }
    }
    
    @Published var friends: [Friend] = []
    @Published var friendRequests: [Friend] = []

    private var currentUserId: Int {
        if let user = currentUser { return user.usersId }
        return UserDefaults.standard.integer(forKey: "currentUserPK")
    }
    
    func fetchAllLetters() {
        let userId = currentUserId
        if userId == 0 { return }

        let urlString = "http://124.56.5.77/fletter/getInBox.php?userId=\(userId)"
        print("전체 편지(받은/보낸) 요청: \(urlString)")
        
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else { return }
            do {
                let decoder = JSONDecoder()
                let decodedLetters = try decoder.decode([Letter].self, from: data)
                
                DispatchQueue.main.async {
                    self.allLetters = decodedLetters
                    print("편지 로드 완료: 총 \(decodedLetters.count)개")
                    
                    self.emotionStatsStore?.updateEmotionPoints(from: decodedLetters)
                    print("📈 감정 점수 업데이트 실행됨!")
//                    
//                    print("📩 로드된 편지 raw JSON:")
//                    if let raw = String(data: data, encoding: .utf8) {
//                        print(raw)
//                    }

                }
            } catch {
                print("편지 디코딩 에러: \(error)")
                if let str = String(data: data, encoding: .utf8) {
                    print("응답 원본: \(str)")
                }
            }
        }.resume()
    }
}
