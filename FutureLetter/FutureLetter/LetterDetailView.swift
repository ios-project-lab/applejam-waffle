//
//  LetterDetailView.swift
//  FutureLetter
//
//  Created by Chaemin Yu on 10/27/25.
//

import SwiftUI

struct LetterDetailView: View {
    @EnvironmentObject var appState: AppState
    var letter: Letter

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("From: \(letter.from)").bold()
                Spacer()
                Text(letter.date, style: .date).font(.caption)
            }
            Text(letter.subject).font(.headline)
            Divider()
            ScrollView {
                Text(letter.body)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            Spacer()
            NavigationLink(destination: LetterReplyView(original: letter)) {
                Text("답장 보내기").frame(maxWidth: .infinity).padding().background(Color.yellow).cornerRadius(8).foregroundColor(.white)
            }
        }
        .padding()
        .navigationTitle("편지 내용")
    }
}
