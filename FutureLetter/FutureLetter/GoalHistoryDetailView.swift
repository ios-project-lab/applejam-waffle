////
////  GoalHistoryDetailView.swift
////  FutureLetter
////
////  Created by Chaemin Yu on 10/27/25.
////
//import SwiftUI
//
//struct GoalHistoryDetailView: View {
//    @Environment(\.presentationMode) var presentationMode
//    private let letterService = LetterService()
//    
//    let lettersId: Int
//    let usersId: Int
//    
//    @State private var letterItem: LetterItem? = nil
//    
//    // 포인트 컬러
//    private let accentYellow = Color(hex: "#FFC700")
//    
//    var body: some View {
//        ZStack {
//            Color(UIColor.systemGroupedBackground).ignoresSafeArea()
//            
//            VStack {
//                if let item = letterItem {
//                    ScrollView {
//                        VStack(spacing: 28) {
//                            
//                            // 🔶 메인 카드 (제목 + 본문)
//                            mainLetterCard(item)
//                            
//                            // 🔶 메타 데이터 섹션
//                            metaSection(item)
//                            
//                            // 🔶 AI 메시지 유무
//                            if let ai = item.aiCheering, !ai.isEmpty {
//                                aiCard(ai)
//                            }
//                        }
//                        .padding(.horizontal)
//                        .padding(.bottom, 40)
//                    }
//                } else {
//                    ProgressView("불러오는 중…")
//                        .onAppear { loadLetter() }
//                }
//            }
//        }
//        .navigationTitle("편지 상세")
//    }
//}
//
//extension GoalHistoryDetailView {
//    
//    // MARK: - 🔶 메인 카드 (제목 + 본문)
//    func mainLetterCard(_ item: LetterItem) -> some View {
//        VStack(alignment: .leading, spacing: 18) {
//            Text(item.title ?? "제목 없음")
//                .font(.title3)
//                .fontWeight(.semibold)
//                .foregroundColor(accentYellow)
//            
//            Text(item.content ?? "내용 없음")
//                .font(.body)
//                .foregroundColor(.primary)
//                .lineSpacing(6)
//        }
//        .padding()
//        .background(Color(.systemBackground))
//        .cornerRadius(14)
//        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
//    }
//    
//    // MARK: - 🔶 메타 섹션
//    func metaSection(_ item: LetterItem) -> some View {
//        VStack(alignment: .leading, spacing: 12) {
//            Text("편지 정보")
//                .font(.headline)
//                .foregroundColor(accentYellow)
//                .padding(.leading, 4)
//            
//            VStack(spacing: 14) {
//                detailRow(label: "편지 ID", value: "\(item.lettersId ?? 0)")
//                detailRow(label: "생성일", value: formatDate(item.createdAt))
//                detailRow(label: "수정일", value: formatDate(item.updatedAt))
//                detailRow(label: "도착 예정일", value: formatDate(item.expectedArrivalTime))
//                detailRow(label: "잠금 여부", value: "\(item.isLocked ?? 0)")
//                detailRow(label: "수신자 타입", value: "\(item.receiverType ?? 0)")
//                detailRow(label: "페이지 읽음 여부", value: "\(item.isRead ?? 0)")
//                detailRow(label: "보낸 사람 ID", value: "\(item.senderId ?? 0)")
//                detailRow(label: "받는 사람 ID", value: "\(item.receiverId ?? 0)")
//                detailRow(label: "도착 타입", value: "\(item.arrivedType ?? 0)")
//                detailRow(label: "감정 ID", value: "\(item.emotionsId ?? 0)")
//                detailRow(label: "부모 편지 ID", value: "\(item.parentLettersId ?? 0)")
//            }
//            .padding()
//            .background(Color(.systemBackground))
//            .cornerRadius(14)
//        }
//    }
//    
//    // MARK: - 🔶 AI 메시지 카드
//    func aiCard(_ aiCheering: String) -> some View {
//        VStack(alignment: .leading, spacing: 12) {
//            Text("📣 AI 메시지")
//                .font(.headline)
//                .foregroundColor(accentYellow)
//            
//            Text(aiCheering)
//                .font(.body)
//                .foregroundColor(.primary)
//        }
//        .padding()
//        .background(accentYellow.opacity(0.12))
//        .cornerRadius(14)
//    }
//    
//    // MARK: - 정보 Row
//    func detailRow(label: String, value: String) -> some View {
//        HStack(alignment: .top, spacing: 8) {
//            Text(label)
//                .font(.subheadline)
//                .foregroundColor(.secondary)
//                .frame(width: 120, alignment: .leading)
//            
//            Text(value)
//                .font(.body)
//                .foregroundColor(.primary)
//                .multilineTextAlignment(.leading)
//        }
//    }
//    
//    // MARK: - 날짜 포맷
//    func formatDate(_ date: Date?) -> String {
//        guard let date = date else { return "-" }
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy-MM-dd"
//        return formatter.string(from: date)
//    }
//    
//    // MARK: - API 요청
//    func loadLetter() {
//        letterService.getLetterByLettersId(
//            usersId: usersId,
//            lettersId: lettersId
//        ) { items in
//            DispatchQueue.main.async {
//                self.letterItem = items.first
//            }
//        }
//    }
//}
//
//
//// MARK: - 🔧 HEX 컬러 지원
//extension Color {
//    init(hex: String) {
//        let scanner = Scanner(string: hex)
//        _ = scanner.scanString("#")
//        
//        var rgb: UInt64 = 0
//        scanner.scanHexInt64(&rgb)
//        
//        let r = Double((rgb >> 16) & 0xFF) / 255
//        let g = Double((rgb >> 8) & 0xFF) / 255
//        let b = Double(rgb & 0xFF) / 255
//        
//        self.init(red: r, green: g, blue: b)
//    }
//}
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
                        infoRow("잠금 여부", boolText(item.isLocked))
                        infoRow("읽음 여부", boolText(item.isRead))
                        infoRow("보낸 사람", "\(item.senderId ?? 0)")
                        infoRow("받는 사람", "\(item.receiverId ?? 0)")
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
