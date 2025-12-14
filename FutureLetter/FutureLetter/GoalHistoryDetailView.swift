////
////  GoalHistoryDetailView.swift
////  FutureLetter
////
////  Created by Chaemin Yu on 10/27/25.
////

import SwiftUI

struct GoalHistoryDetailView: View {
    @Environment(\.dismiss) var dismiss
    private let letterService = LetterService()
    
    let lettersId: Int
    let usersId: Int
    
    @State private var letterItem: LetterItem?

    var body: some View {
        Group {
            if let item = letterItem {
                List {
                    // MARK: - 편지 내용
                    Section {
                        VStack(alignment: .leading, spacing: 12) {
                            Text(item.title ?? "제목 없음")
                                .font(.headline)
                            
                            Text(item.content ?? "내용 없음")
                                .font(.body)
                                .foregroundColor(.primary)
                                .lineSpacing(6)
                        }
                        .padding(.vertical, 4)
                    }

                    // MARK: - AI 메시지
                    if let ai = item.aiCheering, !ai.isEmpty {
                        Section("AI 메시지") {
                            Text(ai)
                                .font(.body)
                                .foregroundColor(.primary)
                        }
                    }

                    // MARK: - 메타 정보
                    Section("편지 정보") {
                        infoRow("편지 ID", "\(item.lettersId ?? 0)")
                        infoRow("생성일", formatDate(item.createdAt))
                        infoRow("수정일", formatDate(item.updatedAt))
                        infoRow("도착 예정일", formatDate(item.expectedArrivalTime))
                        
                        
                    }
                }
                .listStyle(.insetGrouped)
            } else {
                ProgressView("불러오는 중…")
            }
        }
        .navigationTitle("편지 상세")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadLetter()
        }
    }
}
extension GoalHistoryDetailView {
    
    func infoRow(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .foregroundColor(.primary)
        }
    }
    
    func boolText(_ value: Int?) -> String {
        (value ?? 0) == 1 ? "예" : "아니오"
    }

    func formatDate(_ date: Date?) -> String {
        guard let date else { return "-" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
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
}
