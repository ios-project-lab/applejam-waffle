//
//  AppState.swift
//  FutureLetter
//
//  Created by mac07 on 11/2/25.
//

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
    let createdAt: String?
    let updatedAt: String?
    let categoriesId: Int
    let usersId: Int

    var id: Int { goalsId }
}

struct Letter: Identifiable, Codable {
    let receiverNickName: String?
    let receiverId: Int?
    
    let lettersId: Int
    let senderId: Int
    let senderNickName: String?
    let senderUserId: String?
    let title: String
    let content: String
    let expectedArrivalTime: String
    let isRead: Int
    let parentLettersId: Int
    let isLocked: Int
    
    enum CodingKeys: String, CodingKey {
        case lettersId
        case senderId
        case senderNickName
        case senderUserId
        case title
        case content
        case expectedArrivalTime
        case isRead
        case parentLettersId
        case isLocked
        case receiverId
        case receiverNickName = "receiverNickName"
    }

    var id: Int { lettersId }

    var arrivalDate: Date {
        let dateString = String(expectedArrivalTime.prefix(10))
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
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
    @Published var friends: [Friend] = []
    @Published var friendRequests: [Friend] = []
}
