//
//  AuthView.swift
//  FutureLetter
//
//  Created by mac07 on 11/2/25.
//

import SwiftUI

struct AuthView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Spacer()
                Text("미래의 나에게")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.white)
                Text("로그인 또는 회원가입")
                    .foregroundColor(.white.opacity(0.9))
                Spacer()
                NavigationLink(destination: LoginView()) {
                    Text("로그인")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.yellow)
                        .cornerRadius(8)
                }
                NavigationLink(destination: SignUpView()) {
                    Text("회원가입")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.white))
                        .foregroundColor(.white)
                }
                Spacer()
            }
            .padding()
            .background(Color("NavyBackground").edgesIgnoringSafeArea(.all))
        }
    }
}


