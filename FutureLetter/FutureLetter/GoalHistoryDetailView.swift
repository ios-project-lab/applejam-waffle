//
//  GoalHistoryDetailView.swift
//  FutureLetter
//
//  Created by Chaemin Yu on 10/27/25.
//

import SwiftUI

struct GoalHistoryDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    private let letterService = LetterService()
    
    let lettersId: Int
    let usersId: Int
    
    @State private var letterItem: LetterItem? = nil
    
    var body: some View {
        VStack {
            if let item = letterItem {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        
                        // 제목
                        Text(item.title ?? "제목 없음")
                            .font(.title)
                            .bold()
                        
                        // 내용
                        Text(item.content ?? "내용 없음")
                            .font(.body)
                        
                        Divider().padding(.vertical, 8)
                        
                        // 상세 항목들
                        Group {
                            detailRow(label: "편지 ID", value: "\(item.lettersId ?? 0)")
                            detailRow(label: "생성일", value: formatDate(item.createdAt))
                            detailRow(label: "수정일", value: formatDate(item.updatedAt))
                            detailRow(label: "도착 예정일", value: formatDate(item.expectedArrivalTime))
                            detailRow(label: "잠금 여부", value: "\(item.isLocked ?? 0)")
                            detailRow(label: "수신자 타입", value: "\(item.receiverType ?? 0)")
                            detailRow(label: "읽음 여부", value: "\(item.isRead ?? 0)")
                            detailRow(label: "AI 메시지", value: item.aiCheering ?? "-")
                            detailRow(label: "보낸 사람 ID", value: "\(item.senderId ?? 0)")
                            detailRow(label: "받는 사람 ID", value: "\(item.receiverId ?? 0)")
                            detailRow(label: "도착 타입", value: "\(item.arrivedType ?? 0)")
                            detailRow(label: "감정 ID", value: "\(item.emotionsId ?? 0)")
                            detailRow(label: "부모 편지 ID", value: "\(item.parentLettersId ?? 0)")
                        }

                    }
                    .padding()
                }
            } else {
                ProgressView("불러오는 중…")
                    .onAppear { loadLetter() }
            }
        }
        .navigationTitle("편지 상세")
    }
    
    // MARK: - 데이터 요청
    func loadLetter() {
        letterService.getLetterByLettersId(
            usersId: usersId,
            lettersId: lettersId
        ) { items in
            DispatchQueue.main.async {
                self.letterItem = items.first
            }
        }
    }
    
    // MARK: - UI Helper
    func detailRow(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
            Text(value)
                .font(.body)
        }
    }
    
    // MARK: - Date Formatter
    func formatDate(_ date: Date?) -> String {
        guard let date = date else { return "-" }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

