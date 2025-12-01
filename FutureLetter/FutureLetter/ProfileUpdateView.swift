//
//  ProfileUpdateView.swift
//  FutureLetter
//
//  Created by Chaemin Yu on 10/27/25.
//

import SwiftUI
import PhotosUI

struct ProfileUpdateView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.presentationMode) var presentationMode
    
    @State private var nickName = ""
    @State private var password = ""
    
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var uiImage: UIImage?     // 미리보기용 이미지
    @State private var base64String: String? // 저장용 문자열
    
    var body: some View {
        Form {
            
            // ------------------------
            // 프로필 사진
            // ------------------------
            Section(header: Text("프로필 사진")) {
                HStack {
                    Spacer()
                    
                    VStack(spacing: 12) {
                        if let uiImage = uiImage {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                        } else {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                .foregroundColor(.gray)
                        }
                        
                        PhotosPicker("사진 선택", selection: $selectedPhoto, matching: .images)
                            .onChange(of: selectedPhoto) { _, newValue in
                                Task {
                                    if let data = try? await newValue?.loadTransferable(type: Data.self),
                                       let image = UIImage(data: data) {
                                        self.uiImage = image
                                        self.base64String = data.base64EncodedString()
                                    }
                                }
                            }
                    }
                    
                    Spacer()
                }
            }
            
            
            // ------------------------
            // 닉네임 수정
            // ------------------------
            Section(header: Text("닉네임")) {
                TextField("닉네임 입력", text: $nickName)
            }
            
            // ------------------------
            // 비밀번호 수정
            // ------------------------
            Section(header: Text("비밀번호")) {
                SecureField("새 비밀번호", text: $password)
            }
            
            // ------------------------
            // 저장 버튼
            // ------------------------
            Section {
                Button("저장") {
                    saveProfile()
                }
            }
        }
        .navigationTitle("프로필 수정")
        .onAppear { loadUserData() }
    }
    
    
    // MARK: - 기존 유저 데이터 로드
    func loadUserData() {
        if let user = appState.currentUser {
            nickName = user.nickName ?? ""
            password = user.password ?? ""
            
            if let base64 = user.profileImage,
               let data = Data(base64Encoded: base64),
               let image = UIImage(data: data) {
                self.uiImage = image
                self.base64String = base64
            }
        }
    }
    
    
    // MARK: - 저장 로직
    func saveProfile() {
        guard let u = appState.currentUser else { return }
        
        let updatedImageString = base64String ?? u.profileImage
        
        appState.currentUser = User(
            usersId: u.usersId,
            id: u.id,
            nickName: nickName,
            password: password,
            birthDay: u.birthDay,
            gender: u.gender,
            userStatus: u.userStatus,
            profileImage: updatedImageString,   // ⭐ Base64 문자열 저장!
            createdAt: u.createdAt
        )
        
        presentationMode.wrappedValue.dismiss()
    }
}

