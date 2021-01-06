import SwiftUI

struct PaletteEditor: View {
    @Binding var chosenPalette: String
    @ObservedObject var document: EmojiArtDocument
    @State private var paletteName = ""
    @State private var emojisToAdd = ""
    @Binding var isPresented: Bool

    var body: some View {
        VStack {
            ZStack {
                Text("Edit Palette")
                    .font(.headline)
                    .padding()
                HStack {
                    Spacer()
                    Button(action: {
                        self.isPresented = false
                    }, label: { Text("Done").padding() })
                }
            }
            Form {
                Section {
                    TextField("Palette Name", text: self.$paletteName, onEditingChanged: { isEditing in
                        if !isEditing {
                            self.document.renamePalette(self.chosenPalette, to: self.paletteName)
                        }
                    })
                    TextField("Add Emojis", text: self.$emojisToAdd, onEditingChanged: { isEditing in
                        if !isEditing {
                            self.chosenPalette = self.document.addEmoji(self.emojisToAdd, toPalette: self.chosenPalette)
                            self.emojisToAdd = ""
                        }
                    })
                }
                Section(header: Text("Remove Emojis")) {
                    Grid(chosenPalette.map { String($0) }, id: \.self) { emoji in
                        Text(emoji)
                            .font(Font.system(size: 40))
                            .onTapGesture {
                                self.chosenPalette = self.document.removeEmojis(emoji, fromPalette: self.chosenPalette)
                            }
                    }
                    .frame(height: self.heightOfRemoveEmojisGrid)
                }
            }
        }
        .onAppear { self.paletteName = self.document.paletteNames[self.chosenPalette] ?? "" }
    }

    private var heightOfRemoveEmojisGrid: CGFloat {
        CGFloat((chosenPalette.count - 1) / 6 * 70 + 70)
    }
}
