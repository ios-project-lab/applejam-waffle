//
//  LoginView.swift
//  FutureLetter
//
//  Created by Chaemin Yu on 10/27/25.
//

import SwiftUI

struct LoginView: View {
    var body: some View {
        NavigationView{
            VStack{
                NavigationLink(destination: HomeView()){
                    Text("로그인")
                }
                NavigationLink(destination: SignUpView()){
                    Text("회원가입")
                }
            }
        }
    }
}

#Preview {
    LoginView()
}
