//
//  LetterReplyView.swift
//  FutureLetter
//
//  Created by Chaemin Yu on 10/27/25.
//

import SwiftUI

struct LetterReplyView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.presentationMode) var presentationMode

    var original: Letter
    @State private var bodyText = ""

    var body: some View {
        VStack(spacing: 12) {
            Text("답장하기").font(.title2)
            Text("원본: \(original.subject)").font(.caption)
            TextEditor(text: $bodyText).frame(height: 200).overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3)))
            Button {
                let reply = Letter(from: appState.currentUser?.displayName ?? "나", to: original.from, subject: "Re: \(original.subject)", body: bodyText, date: Date())
                appState.inbox.insert(reply, at: 0)
                presentationMode.wrappedValue.dismiss()
            } label: {
                Text("보내기").frame(maxWidth: .infinity).padding().background(Color.yellow).cornerRadius(8).foregroundColor(.white)
            }
            Spacer()
        }.padding()
    }
}
