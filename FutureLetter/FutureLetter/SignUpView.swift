//
//  SignUpView.swift
//  FutureLetter
//
//  Created by Chaemin Yu on 10/27/25.
//

import SwiftUI

struct SignUpView: View {
    var body: some View {
        NavigationLink(destination: HomeView()){
            Text("회원가입 완료")
        }
}

#Preview {
    SignUpView()
}
