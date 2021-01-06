import Foundation

extension EmojiArtDocument {
    private static let palettesPersistenceKey = "EmojiArtDocument.PalettesKey"
    private static let defaultPalettes = [
        "🤯🤓😁🥳🤩😍😅😖🤣🤡🤔🤗😪🤢🤧🤮😇😂🤪🧐": "Faces",
        "🐶🐱🐹🐰🦊🐼🐨🐯🐸🐵🐧🐦🐤🦆🦅🦇🐺": "Animals",
        "🍎🍇🍌🧄🌶🥦🍆🥥🥝🍍🥭🍉🍓": "Food",
        "🏹🪁⚽️🛹🎱🥅🏓🤹‍♀️🩰🎨🎯🎮🎲♟🎸": "Activities"
    ]

    private(set) var paletteNames: [String: String] {
        get {
            UserDefaults.standard.object(forKey: EmojiArtDocument.palettesPersistenceKey) as? [String: String]
                ?? EmojiArtDocument.defaultPalettes
        }
        set {
            UserDefaults.standard.set(newValue, forKey: EmojiArtDocument.palettesPersistenceKey)
            objectWillChange.send()
        }
    }

    var sortedPalettesByName: [String] {
        paletteNames.keys.sorted { paletteNames[$0]! < paletteNames[$1]! }
    }

    var defaultPalette: String {
        sortedPalettesByName.first ?? "⚠️"
    }

    func renamePalette(_ palette: String, to name: String) {
        paletteNames[palette] = name
    }

    @discardableResult
    func addEmoji(_ emoji: String, toPalette palette: String) -> String {
        let newPalette = (emoji + palette).uniqued()
        return changePalette(palette, to: newPalette)
    }

    @discardableResult
    func removeEmojis(_ emojisToRemove: String, fromPalette palette: String) -> String {
        let newPalette = palette.filter { !emojisToRemove.contains($0) }
        return changePalette(palette, to: newPalette)
    }

    private func changePalette(_ palette: String, to newPalette: String) -> String {
        let name = paletteNames[palette] ?? ""
        paletteNames[palette] = nil
        paletteNames[newPalette] = name
        return newPalette
    }

    func palette(after referencePalette: String) -> String {
        palette(offsetBy: +1, from: referencePalette)
    }

    func palette(before referencePalette: String) -> String {
        palette(offsetBy: -1, from: referencePalette)
    }

    private func palette(offsetBy offset: Int, from referencePalette: String) -> String {
        if let currentIndex = sortedPalettesByName.firstIndex(of: referencePalette) {
            let newIndex = (currentIndex + (offset >= 0 ? offset : paletteNames.keys.count - abs(offset) % paletteNames.keys.count)) % paletteNames.keys.count
            return sortedPalettesByName[newIndex]
        } else {
            return defaultPalette
        }
    }
}

extension String {
    // Removes duplicate characters from a String
    func uniqued() -> String {
        var uniqued = ""
        for ch in self {
            if !uniqued.contains(ch) {
                uniqued.append(ch)
            }
        }
        return uniqued
    }
}
