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
    @Published var analysisResult: [String: Any]?

    private let service = AIService()

    func analyzeLetter(action: String = "sentiment") {
        service.analyze(action: action, text: text) { [weak self] result in
            DispatchQueue.main.async {
                self?.analysisResult = result
            }
        }
    }
}
