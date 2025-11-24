import SwiftUI

struct LetterItemView: View {
    var letter: Letter

    var body: some View {
        HStack {
            Image(systemName: letter.isActuallyLocked ? "lock.fill" : "envelope.open")
                .font(.title2)
                .foregroundColor(letter.isActuallyLocked ? .gray : .yellow)
                .padding(.trailing, 8)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(letter.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(1)

                    if let count = letter.replyCount, count > 0 {
                        Text("(\(count))")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                    }
                }

                Text("From: \(letter.senderNickName ?? "알 수 없음")")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing) {
                Text(letter.arrivalDate, format: .dateTime.year().month().day())
                    .font(.caption)
                    .foregroundColor(letter.isActuallyLocked ? .red : .gray)
            }
        }
        .padding(.vertical, 8)
    }
}
