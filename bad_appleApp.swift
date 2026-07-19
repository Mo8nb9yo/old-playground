import SwiftUI

struct BadAppleView: View {
    @State private var currentFrame = 1
    @State private var frames: [String] = []
    
    let fps = 10
    
    var body: some View {
        Group {
            if frames.isEmpty {
                Text("Loading Bad Apple...")
                    .foregroundColor(.white)
            } else {
                Text(frames[currentFrame])
                    .font(.system(size: 8, design: .monospaced))
                    .foregroundColor(.black)
                    .padding()
                    .background(Color.white)
            }
        }
        .onAppear {
            loadFrames()
        }
    }
    
    func loadFrames() {
        if let url = Bundle.main.url(forResource: "badapple", withExtension: "txt"),
           let content = try? String(contentsOf: url) {
            frames = content.components(separatedBy: "SPLIT")
            Timer.scheduledTimer(withTimeInterval: 1.0 / Double(fps), repeats: true) { _ in
                currentFrame = (currentFrame + 1) % frames.count
            }
        }
    }
}

@main
struct BadAppleApp: App {
    var body: some Scene {
        WindowGroup {
            BadAppleView()
        }
    }
}

