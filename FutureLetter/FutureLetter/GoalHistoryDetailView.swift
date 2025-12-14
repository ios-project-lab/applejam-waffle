////
////  GoalHistoryDetailView.swift
////  FutureLetter
////
////  Created by Chaemin Yu on 10/27/25.
////

import SwiftUI
struct AIMessage: Decodable {
    let overall_analysis: String
    let sentiment_analysis: SentimentAnalysis
    let goal_analysis: GoalAnalysis
}

struct SentimentAnalysis: Decodable {
    let sentiment: String
    let score: Double
    let reason: String
}

struct GoalAnalysis: Decodable {
    let progress_percent: Int
    let feedback: String
    let next_step: String
}

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
                    // MARK: - AI 메시지
                    if let aiString = item.aiCheering,
                       let ai = parseAIMessage(aiString) {

                        Section("AI 분석") {

                            VStack(alignment: .leading, spacing: 12) {
                                infoBlock(
                                    title: "전체 분석",
                                    content: ai.overall_analysis
                                )

                                Divider()

                                infoBlock(
                                    title: "감정 분석",
                                    content: """
                                    감정: \(ai.sentiment_analysis.sentiment)
                                    점수: \(ai.sentiment_analysis.score)
                                    이유: \(ai.sentiment_analysis.reason)
                                    """
                                )

                                Divider()

                                infoBlock(
                                    title: "목표 분석",
                                    content: """
                                    진행률: \(ai.goal_analysis.progress_percent)%
                                    피드백: \(ai.goal_analysis.feedback)
                                    다음 단계: \(ai.goal_analysis.next_step)
                                    """
                                )
                            }
                            .padding(.vertical, 4)
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
func infoBlock(title: String, content: String) -> some View {
    VStack(alignment: .leading, spacing: 6) {
        Text(title)
            .font(.subheadline)
            .fontWeight(.semibold)
            .foregroundColor(.secondary)

        Text(content)
            .font(.body)
            .foregroundColor(.primary)
            .fixedSize(horizontal: false, vertical: true)
    }
}

func parseAIMessage(_ jsonString: String) -> AIMessage? {
    guard let data = jsonString.data(using: .utf8) else { return nil }
    
    do {
        return try JSONDecoder().decode(AIMessage.self, from: data)
    } catch {
        print("AI 메시지 파싱 실패:", error)
        return nil
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
