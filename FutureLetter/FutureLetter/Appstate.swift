//
//  Appstate.swift
//  FutureLetter
//
//  Created by mac07 on 11/2/25.
//

import Foundation
import SwiftUI

struct User: Identifiable, Codable {
    var id: String = UUID().uuidString
    var username: String
    var displayName: String
    var bio: String?
}

struct Goal: Identifiable {
    var id: String = UUID().uuidString
    var title: String
    var description: String
    var deadLine: Date
    var completed: Bool = false
}

struct Letter: Identifiable {
    var id: String = UUID().uuidString
    var from: String
    var to: String
    var subject: String
    var body: String
    var date: Date
    var replied: Bool = false
}

struct Friend: Identifiable {
    var id: String = UUID().uuidString
    var username: String
    var displayName: String
    var blocked: Bool = false
}

final class AppState: ObservableObject {
    @Published var currentUser: User? = nil
    @Published var isLoggedIn: Bool = false

    @Published var goals: [Goal] = [
        Goal(title: "3주에 -4kg", description: "건강한 식단과 운동", deadLine: Date().addingTimeInterval(60*60*24*21)),
        Goal(title: "일기 시작", description: "매일 1줄 기록", deadLine: Date().addingTimeInterval(60*60*24*30))
    ]
    @Published var inbox: [Letter] = [
        Letter(from: "친구A", to: "나", subject: "안부", body: "잘 지내? 3주 플랜은 어때?", date: Date().addingTimeInterval(-60*60*24)),
        Letter(from: "나", to: "미래의 나", subject: "미래에게", body: "응원해!", date: Date())
    ]
    @Published var friends: [Friend] = [
        Friend(username: "love_waffles", displayName: "Love_Waffles"),
        Friend(username: "coffee_bae", displayName: "CoffeeBae")
    ]
    @Published var friendRequests: [Friend] = [
        Friend(username: "new_friend", displayName: "NewFriend")
    ]
}

