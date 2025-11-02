//
//  LetterComposeView.swift
//  FutureLetter
//
//  Created by Chaemin Yu on 10/27/25.
//

import SwiftUI

struct LetterComposeView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.presentationMode) var presentationMode

    @State private var to = ""
    @State private var subject = ""
    @State private var bodyText = ""

    var body: some View {
        VStack(spacing: 12) {
            Text("편지 작성")
                .font(.title2)
                .bold()

            TextField("받는 사람", text: $to)
                .textFieldStyle(.roundedBorder)

            TextField("제목", text: $subject)
                .textFieldStyle(.roundedBorder)

            TextEditor(text: $bodyText)
                .frame(height: 200)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3))
                )

            Button {
                let senderName = appState.currentUser?.displayName ?? "나"
                let newLetter = Letter(
                    from: senderName,
                    to: to,
                    subject: subject,
                    body: bodyText,
                    date: Date()
                )

                appState.inbox.insert(newLetter, at: 0)
                presentationMode.wrappedValue.dismiss()
            } label: {
                Text("보내기")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.yellow)
                    .foregroundColor(.black)
                    .cornerRadius(8)
            }

            Spacer()
        }
        .padding()
    }
}
