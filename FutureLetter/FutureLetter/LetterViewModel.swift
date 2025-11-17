//
//  LetterViewModel.swift
//  FutureLetter
//
//  Created by Chaemin Yu on 11/10/25.
//

import Foundation
import Combine

class LetterViewModel: ObservableObject {
    @Published var text = ""
    @Published var userEmotion = ""
    @Published var userGoal = ""
    @Published var lettersId: Int = 0

    @Published var analysisResult: [String: Any]?

    private let service = AIService()

    /// 이제 action 필요 없음 — 한 번에 전체 분석
    func analyzeLetter() {
        service.analyze(
            lettersId: lettersId,
            text: text,
            emotion: userEmotion,
            goal: userGoal
        ) { [weak self] result in
            DispatchQueue.main.async {
                self?.analysisResult = result
            }
        }
    }
}
