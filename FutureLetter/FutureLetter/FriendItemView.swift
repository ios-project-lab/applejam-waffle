//
//  FriendItemView.swift
//  FutureLetter
//
//  Created by mac08 on 10/27/25.
//
import SwiftUI
struct FriendItemView: View {
    var body: some View {
        NavigationView {
            
            NavigationLink(destination: FriendRequestsView()) {
                                Text("...")
                                    .foregroundColor(.blue)
                                    .padding(.top, 10)
                            }
            
        
            Spacer()

        
            
        }
    }
}
