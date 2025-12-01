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

    var id: Int { lettersId }

    enum CodingKeys: String, CodingKey {
        case lettersId, title, content
        case senderId, senderNickName, senderUserId
        case receiverId, receiverNickName
        case expectedArrivalTime, isRead, isLocked, parentLettersId, replyCount
        case goalId
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
    @Published var inbox: [Letter] = []
    @Published var sentbox: [Letter] = []
    
    @Published var friends: [Friend] = []
    @Published var friendRequests: [Friend] = []
    
    func fetchInbox() {
        guard let user = currentUser else { return }
        let urlString = "http://124.56.5.77/fletter/getMessages.php?userId=\(user.usersId)"
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else { return }
            do {
                let decodedLetters = try JSONDecoder().decode([Letter].self, from: data)
                DispatchQueue.main.async {
                    self.inbox = decodedLetters
                }
            } catch {
                print(error)
            }
        }.resume()
    }
}
