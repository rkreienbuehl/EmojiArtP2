import SwiftUI

struct PaletteChooser: View {
    @ObservedObject var document: EmojiArtDocument
    @Binding var chosenPalette: String
    @State private var isPaletteEditorPresented = false

    var body: some View {
        HStack {
            Stepper(onIncrement: {
                self.chosenPalette = self.document.palette(after: self.chosenPalette)
            }, onDecrement: {
                self.chosenPalette = self.document.palette(before: self.chosenPalette)
            }, label: { EmptyView() })
            Text(self.document.paletteNames[self.chosenPalette] ?? "")
            Image(systemName: "square.and.pencil").imageScale(.large)
                .onTapGesture {
                    self.isPaletteEditorPresented = true
                }
                .sheet(isPresented: $isPaletteEditorPresented) {
                    PaletteEditor(chosenPalette: self.$chosenPalette, document: self.document, isPresented: self.$isPaletteEditorPresented)
                }
        }
        .fixedSize(horizontal: true, vertical: false)
        .onAppear { self.chosenPalette = self.document.defaultPalette }
    }
}
