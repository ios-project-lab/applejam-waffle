//
//  ProfileSettingsView.swift
//  FutureLetter
//
//  Created by Chaemin Yu on 10/27/25.
//


import SwiftUI

struct ProfileSettingsView: View {
    @EnvironmentObject var appState: AppState
    @State private var isLetterAlertOn = true
    @State private var isGoalAlertOn = true
    @State private var theme: String = "dark"
    
    var body: some View {
        NavigationView {
            Form {
                
                // MARK: - 프로필 설정
                Section(header: Text("프로필 설정")) {
                    HStack {
                        Text("ID")
                        Spacer()
                        Text(appState.currentUser?.id ?? "-")
                            .foregroundColor(.gray)
                    }
                    
                    HStack {
                        Text("닉네임")
                        Spacer()
                        Text(appState.currentUser?.nickName ?? "-")
                            .foregroundColor(.gray)
                    }
                    
                    HStack {
                        Text("비밀번호")
                        Spacer()
                        Text("••••••••")
                            .foregroundColor(.gray)
                    }
                    
                    NavigationLink("프로필 수정") {
                        ProfileUpdateView()
                    }
                }
                
                
                // MARK: - 알림 설정
                Section(header: Text("알림 설정")) {
                    Toggle("편지 도착 알림", isOn: $isLetterAlertOn)
                    Toggle("목표 리마인드 알림", isOn: $isGoalAlertOn)
                }
                
                
                // MARK: - 테마 설정
                Section(header: Text("테마 변경")) {
                    Picker("테마", selection: $theme) {
                        Text("라이트").tag("light")
                        Text("다크").tag("dark")
                    }
                }
                
                
                // MARK: - 기타
                Section(header: Text("기타")) {
                    NavigationLink("친구 관리") {
                        Text("친구 관리 화면") // 필요하면 화면 연결
                    }
                    
                    NavigationLink("백업 및 초기화") {
                        Text("백업 및 초기화 화면")
                    }
                    
                    NavigationLink("이용약관 / 개인정보 처리 방침") {
                        Text("이용약관 화면")
                    }
                    
                    Button("로그아웃", role: .destructive) {
                        appState.currentUser = nil
                    }
                }
            }
            .navigationTitle("설정")
        }
    }
}
