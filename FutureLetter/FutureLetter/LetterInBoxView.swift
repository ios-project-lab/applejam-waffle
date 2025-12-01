import SwiftUI

struct LetterInBoxView: View {
    @EnvironmentObject var appState: AppState
    
    // 탭 상태 (0: 받은 편지, 1: 보낸 편지, 2: 받을 예정)
    @State private var selectedTab = 0
    
    var myId: Int { appState.currentUser?.usersId ?? 0 }
    var futureLetters: [Letter] {
        appState.allLetters.filter {
            $0.isActuallyLocked && $0.receiverId == myId && $0.parentLettersId == 0
        }
    }
    
    var receivedLetters: [Letter] {
        appState.allLetters.filter {
            !$0.isActuallyLocked && $0.receiverId == myId && $0.parentLettersId == 0
        }
    }
    
    var unreadLetters: [Letter] { receivedLetters.filter { $0.isRead == 0 } }
    var readLetters: [Letter] { receivedLetters.filter { $0.isRead == 1 } }

    var sentLetters: [Letter] {
        appState.allLetters.filter {
            $0.senderId == myId && $0.parentLettersId == 0
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                Picker("보기 모드", selection: $selectedTab) {
                    Text("받은 편지").tag(0)
                    Text("보낸 편지").tag(1)
                    Text("받을 예정").tag(2)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
               
                List {
                    // 받은 편지함
                    if selectedTab == 0 {
                        if unreadLetters.isEmpty && readLetters.isEmpty {
                            Text("도착한 편지가 없습니다.").foregroundColor(.gray)
                        } else {
                            if !unreadLetters.isEmpty {
                                Section(header: Text("안 읽은 편지").foregroundColor(.red)) {
                                    ForEach(unreadLetters) { letter in
                                        NavigationLink(destination: LetterDetailView(letter: letter)) {
                                            LetterItemView(letter: letter)
                                        }
                                    }
                                }
                            }
                            if !readLetters.isEmpty {
                                Section(header: Text("읽은 편지")) {
                                    ForEach(readLetters) { letter in
                                        NavigationLink(destination: LetterDetailView(letter: letter)) {
                                            LetterItemView(letter: letter)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    // 보낸 편지함
                    else if selectedTab == 1 {
                        if sentLetters.isEmpty {
                            Text("보낸 편지가 없습니다.").foregroundColor(.gray)
                        } else {
                            ForEach(sentLetters) { letter in
                                NavigationLink(destination: LetterDetailView(letter: letter)) {
                                    LetterItemView(letter: letter)
                                }
                            }
                        }
                    }
                    // 받을 예정
                    else {
                        if futureLetters.isEmpty {
                            Text("도착 예정인 편지가 없습니다.").foregroundColor(.gray)
                        } else {
                            ForEach(futureLetters) { letter in
                                NavigationLink(destination: LetterDetailView(letter: letter)) {
                                    LetterItemView(letter: letter)
                                }
                            }
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
                .refreshable {
                    appState.fetchAllLetters()
                }
            }
            .navigationTitle("편지 보관함")
            .onAppear {
                appState.fetchAllLetters()
            }
        }
    }
}
