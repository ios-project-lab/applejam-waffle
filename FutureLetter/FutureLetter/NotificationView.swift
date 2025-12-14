//
//  NotificationView.swift
//  FutureLetter
//
//  Created by Chaemin Yu on 12/1/25.
//

import SwiftUI

struct NotificationView: View {
    @EnvironmentObject var notif: NotificationStore
    @EnvironmentObject var appState: AppState
    
    var currentUserId: Int {
        return UserDefaults.standard.integer(forKey: "currentUserPK")
    }

    var body: some View {
        List {
            ForEach(notif.notifications) { n in
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(n.name ?? "알림")
                            .font(.headline)
                        Spacer()
                        if n.isRead == 0 {
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 10, height: 10)
                        }
                    }

//                    Text(n.title).bold()
                    Text(n.content)
                        .foregroundColor(.gray)

                    Text(n.createdAt)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 6)
                .onTapGesture {
                    notif.markAsRead(id: n.notificationsId)
                }
            }
        }
        .navigationTitle("알림")
        .onAppear {
            print("🔍 현재 userId =", currentUserId)
            notif.fetchNotifications(userId: currentUserId)
        }
    }
}
