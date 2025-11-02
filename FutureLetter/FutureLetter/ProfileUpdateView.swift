//
//  ProfileUpdateView.swift
//  FutureLetter
//
//  Created by Chaemin Yu on 10/27/25.
//

import SwiftUI

struct ProfileUpdateView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.presentationMode) var presentationMode
    @State private var displayName = ""
    @State private var bio = ""

    var body: some View {
        VStack(spacing: 12) {
            TextField("표시 이름", text: $displayName).textFieldStyle(.roundedBorder)
            TextField("한 줄 소개", text: $bio).textFieldStyle(.roundedBorder)
            Button {
                if var u = appState.currentUser {
                    u.displayName = displayName.isEmpty ? u.displayName : displayName
                    u.bio = bio
                    appState.currentUser = u
                }
                presentationMode.wrappedValue.dismiss()
            } label: {
                Text("저장").frame(maxWidth: .infinity).padding().background(Color.yellow).cornerRadius(8)
            }
            Spacer()
        }.padding()
        .onAppear {
            displayName = appState.currentUser?.displayName ?? ""
            bio = appState.currentUser?.bio ?? ""
        }
    }
}
