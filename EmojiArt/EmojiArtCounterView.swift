import SwiftUI

struct EmojiArtCounterView: View {
    @Binding var counter: Int
    
    var body: some View {
        Text("Time worked: \(self.counter) sec")
    }
}
