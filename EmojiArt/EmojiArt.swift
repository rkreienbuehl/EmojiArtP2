import Foundation

struct EmojiArt: Codable {
    var backgroundURL: URL?
    var emojis = [Emoji]()

    init() { }
    
    private var uniqueEmojiId = 0
    var counter: Int = 0
    
    mutating func addEmoji(_ text: String, x: Int, y: Int, size: Int) {
        uniqueEmojiId += 1
        emojis.append(Emoji(text: text, x: x, y: y, size: size, id: uniqueEmojiId))
    }
    
    var json: Data? {
        return try? JSONEncoder().encode(self)
    }
    
    init?(json:Data?) {
        guard let json = json, let newEmojiArt = try? JSONDecoder().decode(EmojiArt.self, from: json) else {
            return nil
        }
         self = newEmojiArt
    }
    
    struct Emoji: Identifiable, Codable {
        let text: String
        var x: Int //offset from center
        var y: Int //offset from center
        var size: Int
        let id: Int
        
        fileprivate init(text: String, x: Int, y: Int, size: Int, id: Int) {
            self.text = text
            self.x = x
            self.y = y
            self.size = size
            self.id = id
        }
    }
}
