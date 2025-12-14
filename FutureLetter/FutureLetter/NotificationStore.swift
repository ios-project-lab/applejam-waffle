//
//  NotificationStore.swift
//  FutureLetter
//
//  Created by Chaemin Yu on 12/1/25.
//

import Foundation
import Combine

class NotificationStore: ObservableObject {
    @Published var notifications: [AppNotification] = []

    func fetchNotifications(userId: Int) {
        guard let url = URL(string: "http://124.56.5.77/fletter/getNotifications.php?usersId=\(userId)") else { return }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data else { return }
            
            if let raw = String(data: data, encoding: .utf8) {
                print("🔍 알림 원본 응답:", raw)
            }

            if let decoded = try? JSONDecoder().decode([AppNotification].self, from: data) {
                DispatchQueue.main.async {
                    self.notifications = decoded
                }
            } else {
                print("❌ 알림 디코딩 실패")
                print(String(data: data, encoding: .utf8) ?? "No raw string")
            }
        }.resume()
    }

    func markAsRead(id: Int) {
        guard let url = URL(string: "http://124.56.5.77/fletter/readNotification.php") else { return }

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.httpBody = "notificationsId=\(id)".data(using: .utf8)

        URLSession.shared.dataTask(with: req).resume()
    }
}
