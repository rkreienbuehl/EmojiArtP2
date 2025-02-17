import SwiftUI
import Combine

struct EmojiArtDocumentView: View {
    @ObservedObject var document: EmojiArtDocument
    @State private var chosenPalette: String = ""
    @State private var isPastingExplanationPresented: Bool = false
    @State private var isConfirmationAlertPresented: Bool = false
    @State private var showColorPicker: Bool = false
    @State private var backgroundColor: Color = Color.white
    @State private var counter: Int = 0
    
    let timer = Timer.TimerPublisher(interval: 1.0, runLoop: .main, mode: .default)
    let timerCancellable: Cancellable?

    init(document: EmojiArtDocument) {
        self.timerCancellable = timer.connect()
        self.document = document
        _backgroundColor = State(initialValue: document.getColor())
        _counter = State(initialValue: document.getCounter())
        chosenPalette = document.defaultPalette
    }

    var body: some View {
        return VStack {
            HStack {
                EmojiArtCounterView(counter: self.$counter)
                    .padding(10)
                    .onReceive(timer, perform: { _ in
                        self.counter = self.document.incrementCounter()
                    })
                Spacer()
                ColorPicker("",selection: self.$backgroundColor)
                    .labelsHidden()
                    .padding(10)
                    .onChange(of: backgroundColor) { _ in
                        self.document.setColor(color: backgroundColor)
                       }
            }
            HStack {
                PaletteChooser(document: document, chosenPalette: $chosenPalette)
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(self.chosenPalette.map { String($0) }, id: \.self) { emoji in
                            Text(emoji)
                                .font(Font.system(size: self.defaultEmojiSize))
                                .onDrag { NSItemProvider(object: emoji as NSString) }
                        }
                    }
                }
            }
            GeometryReader { geometry in
                ZStack {
                    self.backgroundColor.overlay(
                        OptionalImage(uiImage: self.document.backgroundImage)
                            .scaleEffect(self.zoomScale)
                            .offset(self.panOffset)
                    )
                        .gesture(self.doubleTapToZoom(in: geometry.size))
                    if self.isLoading {
                        Image(systemName: "arrow.clockwise.circle.fill").imageScale(.large).spinning()
                    } else {
                        ForEach(self.document.emojis) { emoji in
                            Text(emoji.text)
                                .font(animatableWithSize: emoji.fontSize * self.zoomScale)
                                .position(self.position(for: emoji, in: geometry.size))
                        }
                    }
                }
                .clipped()
                .gesture(self.panGesture())
                .gesture(self.zoomGesture())
                .edgesIgnoringSafeArea([.horizontal, .bottom])
                .onDrop(of: ["public.image","public.text"], isTargeted: nil) { providers, location in
                    // SwiftUI bug (as of 13.4)? the location is supposed to be in our coordinate system
                    // however, the y coordinate appears to be in the global coordinate system
                    var location = CGPoint(x: location.x, y: geometry.convert(location, from: .global).y)
                    location = CGPoint(x: location.x - geometry.size.width/2, y: location.y - geometry.size.height/2)
                    location = CGPoint(x: location.x - self.panOffset.width, y: location.y - self.panOffset.height)
                    location = CGPoint(x: location.x / self.zoomScale, y: location.y / self.zoomScale)
                    return self.drop(providers: providers, at: location)
                }
                .navigationBarItems(trailing: Button(action: {
                    if let url = UIPasteboard.general.url {
                        if self.document.backgroundURL != nil {
                            self.isConfirmationAlertPresented = true
                        } else {
                            self.document.backgroundURL = url
                        }
                    } else {
                        self.isPastingExplanationPresented = true
                    }
                }, label: {
                    Image(systemName: "doc.on.clipboard").imageScale(.large)
                        .alert(isPresented: self.$isPastingExplanationPresented) {
                            return Alert(title: Text("Paste Background Image"), message: Text("Copy the URL of an image to set it as background image."))
                        }
                }))
                    .alert(isPresented: self.$isConfirmationAlertPresented) {
                        return Alert(
                            title: Text("Paste Background Image"),
                            message: Text("Do you really want to replace the existing background image?"),
                            primaryButton: .default(Text("OK")) { self.document.backgroundURL = UIPasteboard.general.url },
                            secondaryButton: .cancel()
                        )
                    }
                .onReceive(self.document.$backgroundImage) { backgroundImage in
                    self.zoomToFit(backgroundImage, in: geometry.size)
                }
            }
        }.onAppear(perform: {
            self.backgroundColor = self.document.getColor()
        })
    }

    private var isLoading: Bool {
        document.backgroundImage == nil && document.backgroundURL != nil
    }

    @GestureState private var gestureZoomScale: CGFloat = 1.0

    private var zoomScale: CGFloat {
        document.steadyStateZoomScale * gestureZoomScale
    }

    private func zoomGesture() -> some Gesture {
        MagnificationGesture()
            .updating($gestureZoomScale) { latestGestureScale, gestureZoomScale, transaction in
                gestureZoomScale = latestGestureScale
            }
            .onEnded { finalGestureScale in
                self.document.steadyStateZoomScale *= finalGestureScale
            }
    }

    @GestureState private var gesturePanOffset: CGSize = .zero

    private var panOffset: CGSize {
        (document.steadyStatePanOffset + gesturePanOffset) * zoomScale
    }

    private func panGesture() -> some Gesture {
        DragGesture()
            .updating($gesturePanOffset) { latestDragGestureValue, gesturePanOffset, transaction in
                gesturePanOffset = latestDragGestureValue.translation / self.zoomScale
        }
        .onEnded { finalDragGestureValue in
            self.document.steadyStatePanOffset = self.document.steadyStatePanOffset + (finalDragGestureValue.translation / self.zoomScale)
        }
    }

    private func doubleTapToZoom(in size: CGSize) -> some Gesture {
        TapGesture(count: 2)
            .onEnded {
                withAnimation {
                    self.zoomToFit(self.document.backgroundImage, in: size)
                }
            }
    }

    private func zoomToFit(_ image: UIImage?, in size: CGSize) {
        if let image = image, image.size.width > 0, image.size.height > 0, size.width > 0, size.height > 0 {
            let hZoom = size.width / image.size.width
            let vZoom = size.height / image.size.height
            self.document.steadyStatePanOffset = .zero
            self.document.steadyStateZoomScale = min(hZoom, vZoom)
        }
    }

    private func position(for emoji: EmojiArt.Emoji, in size: CGSize) -> CGPoint {
        var location = emoji.location
        location = CGPoint(x: location.x * zoomScale, y: location.y * zoomScale)
        location = CGPoint(x: location.x + size.width/2, y: location.y + size.height/2)
        location = CGPoint(x: location.x + panOffset.width, y: location.y + panOffset.height)
        return location
    }

    private func drop(providers: [NSItemProvider], at location: CGPoint) -> Bool {
        var found = providers.loadFirstObject(ofType: URL.self) { url in
            self.document.backgroundURL = url
        }
        if !found {
            found = providers.loadObjects(ofType: String.self) { string in
                self.document.addEmoji(string, at: location, size: self.defaultEmojiSize)
            }
        }
        return found
    }

    private let defaultEmojiSize: CGFloat = 40
}
