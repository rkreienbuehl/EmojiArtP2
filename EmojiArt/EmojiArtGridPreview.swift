import SwiftUI

struct EmojiArtGridPreview: View {
    @ObservedObject var document: EmojiArtDocument
  
    init(document: EmojiArtDocument) {
        self.document = document
        
    }

    var body: some View {
        VStack {
            GeometryReader { geometry in
                ZStack {
                    Color.white.overlay(
                        OptionalImage(uiImage: self.document.backgroundImage)
                            .scaleEffect(self.zoomScale)
                            .aspectRatio(contentMode: .fit)
                            .offset(self.panOffset)
                    )
                        
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
                .edgesIgnoringSafeArea([.horizontal, .bottom])
            }
        }
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

    private func position(for emoji: EmojiArt.Emoji, in size: CGSize) -> CGPoint {
        var location = emoji.location
        location = CGPoint(x: location.x * zoomScale, y: location.y * zoomScale)
        location = CGPoint(x: location.x + size.width/2, y: location.y + size.height/2)
        location = CGPoint(x: location.x + panOffset.width, y: location.y + panOffset.height)
        return location
    }
}
