import SwiftUI

struct LetterItemView: View {
    var letter: Letter
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(letter.from).bold()
                Spacer()
                Text(letter.date, style: .date).font(.caption)
            }
            Text(letter.subject).font(.subheadline)
                .foregroundColor(.secondary)
        }.padding(.vertical, 6)
    }
}
