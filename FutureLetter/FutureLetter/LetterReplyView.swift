import SwiftUI

struct LetterReplyView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.presentationMode) var presentationMode

    // original 변수는 변경이 불가능하지만, 식별자(id)를 통해 appState.inbox에서 찾아 업데이트할 수 있습니다.
    var original: Letter
    @State private var bodyText = ""

    var body: some View {
        VStack(spacing: 12) {
            Text("답장하기").font(.title2)
            Text("제목: \(original.subject)").font(.caption)

            TextEditor(text: $bodyText)
                .frame(height: 200)
                .overlay(RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray.opacity(0.3)))

            Button {
                // 1. 새 답장 편지 생성
                let reply = Letter(
                    from: appState.currentUser?.displayName ?? "나",
                    to: original.from,
                    subject: "RE: \(original.subject)",
                    body: bodyText,
                    date: Date(),
                    replied: false
                )

                // 2. 새 답장 편지를 inbox에 추가
                appState.inbox.insert(reply, at: 0)
                
                // 3. 원본 편지의 replied 상태 업데이트
                if let index = appState.inbox.firstIndex(where: { $0.id == original.id }) {
                    appState.inbox[index].replied = true
                }
                
                // 4. 뷰 닫기
                presentationMode.wrappedValue.dismiss()
            } label: {
                Text("보내기")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.yellow)
                    .cornerRadius(8)
                    .foregroundColor(.white)
            }

            Spacer()
        }
        .padding()
    }
}
