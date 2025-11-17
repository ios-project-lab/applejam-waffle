import SwiftUI

struct LetterInBoxView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationView {
            List {
                ForEach(appState.inbox) { letter in
                    NavigationLink(destination: LetterDetailView(letter: letter)) {
                        LetterItemView(letter: letter)
                    }
                }
                .onDelete { idx in
                    appState.inbox.remove(atOffsets: idx)
                }
            }
            .navigationTitle("편지함")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: LetterComposeView()) {
                        Image(systemName: "square.and.pencil")
                    }
                }
            }
        }
    }
}
