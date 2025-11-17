//
//  LetterViewModel.swift
//  FutureLetter
//
//  Created by Chaemin Yu on 11/10/25.
//

import Foundation
import Combine

class LetterViewModel: ObservableObject {
    // MARK: - Letter Fields
    @Published var title: String = ""
    @Published var content: String = ""
    @Published var expectedArrivalTime: String = ""  // "2025-01-01 10:00:00" 같은 형식
    @Published var receiverType: Int = 0
    @Published var senderId: Int = 0
    @Published var receiverId: Int = 0
    @Published var arrivedType: Int = 0
    @Published var emotionsId: Int = 0
    @Published var goalHistoriesId: Int = 0
    @Published var parentLettersId: Int = 0

    // MARK: - AI 분석용 입력값
    @Published var text: String = ""
    @Published var userEmotion: String = ""
    @Published var userGoal: String = ""

    // MARK: - 응답
    @Published var analysisResult: [String: Any]?

    private let service = AIService()

    // MARK: - 요청 실행
    func analyzeLetter() {

        print("🚀 analyzeLetter() 실행됨")

        service.analyze(
            title: title,
            content: content,
            expectedArrivalTime: expectedArrivalTime,
            receiverType: receiverType,
            senderId: senderId,
            receiverId: receiverId,
            arrivedType: arrivedType,
            emotionsId: emotionsId,
            parentLettersId: parentLettersId,
            text: text,
            emotion: userEmotion,
            goal: userGoal
        ) { [weak self] result in

            DispatchQueue.main.async {
                self?.analysisResult = result

                print("📩 AI 분석 결과 도착:")
                print(result ?? [:])
            }
        }
    }

    // MARK: - 테스트용 함수
    func testAnalyze() {
        // 필수 필드 임시 값
        self.title = "테스트 제목"
        self.content = "테스트 본문 내용입니다."
        self.expectedArrivalTime = "2025-01-01 10:00:00"
        self.receiverType = 1
        self.senderId = 6
        self.receiverId = 6
        self.arrivedType = 1
        self.emotionsId = 1
        self.parentLettersId = 15

        // AI 분석용 데이터
        self.text = "이건 테스트용 편지입니다."
        self.userEmotion = "조금 불안하지만 기대됨"
        self.userGoal = "꾸준히 하루 1시간 공부하기"

        analyzeLetter()
    }
}
