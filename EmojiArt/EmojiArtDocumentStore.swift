import Foundation
import Combine

class EmojiArtDocumentStore: ObservableObject {
    private static let persistenceKeyPrefix = "EmojiArtDocumentStore"

    let name: String

    func name(for document: EmojiArtDocument) -> String {
        if documentNames[document] == nil {
            documentNames[document] = "Untitled"
        }
        return documentNames[document]!
    }

    func setName(_ name: String, for document: EmojiArtDocument) {
        guard !documentNames.values.contains(name) else {
            print("Rejected attempt to rename to existing document name.")
            return
        }

        removeDocument(document)
        let url = directory.appendingPathComponent(name)
        document.url = url
        documentNames[document] = name

    }

    @Published private var documentNames = [EmojiArtDocument: String]()

    var documents: [EmojiArtDocument] {
        documentNames.keys.sorted { documentNames[$0]! < documentNames[$1]! }
    }

    func addDocument(named name: String = "Untitled") {
        let uniqueName = name.uniqued(withRespectTo: documentNames.values)
        let fileUrl = directory.appendingPathComponent(uniqueName)
        let document = EmojiArtDocument(url: fileUrl)
        documentNames[document] = uniqueName
    }

    func removeDocument(_ document: EmojiArtDocument) {
        guard let name = documentNames[document] else { return }
        let fileUrl = directory.appendingPathComponent(name)
        try? FileManager.default.removeItem(at: fileUrl)
        documentNames[document] = nil
    }

    private var autosave: AnyCancellable?

    private var directory: URL

    init(directory: URL) {
        name = directory.lastPathComponent
        self.directory = directory
        do {
            let documents = try FileManager.default.contentsOfDirectory(atPath: directory.path)
            for document in documents {
                let emojiArtDocument = EmojiArtDocument(url: directory.appendingPathComponent(document))
                self.documentNames[emojiArtDocument] = document
            }
        } catch {
            print("EmojiArtDocumentStore: couldn't create store from directory \(directory): \(error.localizedDescription)")
        }
    }
}
