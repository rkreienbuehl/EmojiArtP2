import SwiftUI

struct EmojiArtDocumentChooser: View {
    @ObservedObject var store: EmojiArtDocumentStore
    @State private var editMode = EditMode.inactive
    

    var body: some View {
        print(self.editMode)
        return NavigationView {
            
            if(self.editMode == .inactive){
           
                Grid(store.documents){ art in
                    
                        
                    
                    NavigationLink(destination: EmojiArtDocumentView(document: art).navigationBarTitle(self.store.name(for: art))) {
                        VStack{
                            EmojiArtGridPreview(document: art)
                           
                            ZStack{
                                Text(self.store.name(for:art)).foregroundColor(.black)
                            }.background(Color.white.opacity(0.6))
                        }
                    }
                
                }
                .navigationBarTitle(self.store.name)
                .navigationBarItems(
                    leading: Button(action: {
                        self.store.addDocument()
                    }, label: {
                        Image(systemName: "plus").imageScale(.large)
                    }),
                    trailing: EditButton()
                )
                .environment(\.editMode, $editMode)
            } else {
                List {
                    ForEach(self.store.documents) { document in
                        NavigationLink(destination: EmojiArtDocumentView(document: document).navigationBarTitle(self.store.name(for: document))) {
                            EditableText(self.store.name(for: document), isEditing: self.editMode.isEditing) { name in
                                self.store.setName(name, for: document)
                            }
                        }
                    }
                    .onDelete(perform: { indexSet in
                        indexSet
                            .map { self.store.documents[$0] }
                            .forEach { document in
                                self.store.removeDocument(document)
                            }
                    })
                }
                .navigationBarTitle(self.store.name)
                .navigationBarItems(
                    leading: Button(action: {
                        self.store.addDocument()
                    }, label: {
                        Image(systemName: "plus").imageScale(.large)
                    }),
                    trailing: EditButton()
                )
                .environment(\.editMode, $editMode)
            }
            
        }
    }
}
