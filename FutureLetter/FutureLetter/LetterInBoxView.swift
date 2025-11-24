import SwiftUI

struct LetterInBoxView: View {
    @EnvironmentObject var appState: AppState
    @State private var letters: [Letter] = []
    @State private var replies: [Letter] = []
    @State private var isLoading = false
    
    // 탭 상태 (0: 받은 편지, 1: 보낸 편지, 2: 받을 예정)
    @State private var selectedTab = 0
    
    // 내 유저 ID
    var myId: Int { appState.currentUser?.usersId ?? 0 }

    // 받은 편지 (도착함 & 내가 받음)
    var receivedLetters: [Letter] {
        letters.filter {
            !$0.isActuallyLocked &&  // 도착함
            $0.receiverId == myId && // 내가 받음
            $0.parentLettersId == 0  // 원본만
        }
    }
    
    // 안 읽은 편지
    var unreadLetters: [Letter] {
        receivedLetters.filter { $0.isRead == 0 }
    }
    
    // 읽은 편지
    var readLetters: [Letter] {
        receivedLetters.filter { $0.isRead == 1 }
    }

    // 보낸 편지 (내가 보냄)
    var sentLetters: [Letter] {
        letters.filter {
            $0.senderId == myId &&   // 내가 보냄
            $0.parentLettersId == 0  // 원본만
        }
    }

    // 받을 예정 (잠김 & 내가 받음)
    var futureLetters: [Letter] {
        letters.filter {
            $0.isActuallyLocked &&   // 잠김
            $0.receiverId == myId && // 내가 받음
            $0.parentLettersId == 0  // 원본만
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                // 3단 탭바
                Picker("보기 모드", selection: $selectedTab) {
                    Text("받은 편지").tag(0)
                    Text("보낸 편지").tag(1)
                    Text("받을 예정").tag(2)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                if isLoading {
                    Spacer(); ProgressView(); Spacer()
                } else {
                    List {
                        // 탭 1: 받은 편지 (읽음/안읽음 구분)
                        if selectedTab == 0 {
                            if unreadLetters.isEmpty && readLetters.isEmpty {
                                Text("받은 편지가 없습니다.").foregroundColor(.gray)
                            } else {
                                // 1-1. 안 읽은 편지 섹션
                                if !unreadLetters.isEmpty {
                                    Section(header: Text("안 읽은 편지").foregroundColor(.red)) {
                                        ForEach(unreadLetters) { letter in
                                            NavigationLink(destination: LetterDetailView(letter: letter)) {
                                                LetterItemView(letter: letter)
                                            }
                                        }
                                    }
                                }
                                
                                // 1-2. 읽은 편지 섹션
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
                        
                        // 탭 2: 보낸 편지
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
                        
                        // 탭 3: 받을 예정 (잠김)
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
                    .refreshable { fetchInbox() }
                }
            }
            .navigationTitle("편지 보관함")
            .onAppear(perform: fetchInbox)
        }
    }
    
    func fetchInbox() {
        guard let userId = appState.currentUser?.usersId else { return }

        let urlString = "http://localhost/fletter/getInbox.php?userId=\(userId)"
        guard let url = URL(string: urlString) else { return }
        
        isLoading = true
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async { isLoading = false }
            if let data = data {
                do {
                    let decodedLetters = try JSONDecoder().decode([Letter].self, from: data)
                    DispatchQueue.main.async { self.letters = decodedLetters }
                } catch {
                    print("디코딩 에러: \(error)")
                }
            }
        }.resume()
    }
}
