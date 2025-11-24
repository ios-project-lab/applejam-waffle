import SwiftUI

struct LetterItemView: View {
    var letter: Letter

    @EnvironmentObject var appState: AppState

    var body: some View {
        HStack {
            // 아이콘
            Image(systemName: letter.isActuallyLocked ? "lock.fill" : "envelope.open")
                .font(.title2)
                .foregroundColor(letter.isActuallyLocked ? .gray : .yellow)
                .padding(.trailing, 8)

            VStack(alignment: .leading, spacing: 4) {
                // 제목
                Text(letter.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(1)

                // 3. From vs To 구분 표시
                if letter.senderId == appState.currentUser?.usersId {
                    // 내가 보낸 편지 -> "To: 받는사람"
                    Text("To: \(letter.receiverNickName ?? "알 수 없음")")
                        .font(.caption)
                        .foregroundColor(.blue) // 파란색으로 구별
                } else {
                    // 내가 받은 편지 -> "From: 보낸사람"
                    Text("From: \(letter.senderNickName ?? "알 수 없음")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            // 날짜
            VStack(alignment: .trailing) {
                Text(letter.arrivalDate, format: .dateTime.year().month().day())
                    .font(.caption)
                    .foregroundColor(letter.isActuallyLocked ? .red : .gray)
            }
        }
        .padding(.vertical, 8)
    }
}
