//
//  GoalHistoryListView.swift
//  FutureLetter
//
//  Created by Chaemin Yu on 10/27/25.
//
import SwiftUI
struct LetterItem: Codable {
    let lettersId: Int?
    let title: String?
    let content: String?
    let createdAt: Date?
    let updatedAt: Date?
    let expectedArrivalTime: Date?
    let isLocked: Int?
    let receiverType: Int?
    let isRead: Int?
    let aiCheering: String?
    let senderId: Int?
    let receiverId: Int?
    let arrivedType: Int?
    let emotionsId: Int?
    let parentLettersId: Int?
}

struct GoalHistoryListView: View {
    
    @EnvironmentObject var goalHistoryStore: GoalHistoryStore
    let goalsId: Int   // GoalItemView에서 전달받은 목표 ID
    

    var body: some View {
        let currentUserPK = UserDefaults.standard.integer(forKey: "currentUserPK");
        List {
            ForEach(goalHistoryStore.goalHistories, id:\.goalHistoriesId) { item in
                NavigationLink(
                    destination: GoalHistoryDetailView(lettersId: item.lettersId, usersId: currentUserPK)
                ) {
                    GoalHistoryItemView(history: item)
                }
                .buttonStyle(.plain)
                
            }
            
        }
        .navigationTitle("목표 히스토리")
        
        
        .task {
            goalHistoryStore.loadGoalsFromServer(goalsId: goalsId)
        }

    }
            

}




