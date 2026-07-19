import AppKit
import Cocoa
import SwiftUI
import AVFoundation

struct Sound: Identifiable {
    let id = UUID()
    var name: String
    var url: URL
    var key: String
}

class AudioEngineManager: ObservableObject {
    let engine = AVAudioEngine()
    let player = AVAudioPlayerNode()
    
    init() {
        engine.attach(player)
        engine.connect(player, to: engine.mainMixerNode, format: nil)
        
        let outputNode = engine.outputNode
        let outputFormat = outputNode.inputFormat(forBus: 0)
    
        do {
            try engine.start()
        } catch {
            print("Ошибка запуска AVAudioEngine:", error)
        }
    }
    
    func play(url: URL) {
        do {
            let file = try AVAudioFile(forReading: url)
            player.stop()
            player.scheduleFile(file, at: nil)
            player.play()
        } catch {
            print("Ошибка воспроизведения файла:", error)
        }
    }
}
struct ContentView: View {
    @State private var sounds: [Sound] = []
    @StateObject private var audio = AudioEngineManager()
    
    var body: some View {
        VStack {
            HStack {
                Text("Soundpad")
                    .font(.largeTitle)
                Spacer()
                Button("➕ Add sound") { addSound() }
            }
            .padding()
            
            List {
                ForEach(sounds) { sound in
                    HStack {
                        Button(sound.name) { audio.play(url: sound.url) }
                            .frame(width: 200, alignment: .leading)
                        
                        Text("Key:")
                        TextField("A", text: binding(for: sound).key)
                            .frame(width: 40)
                    }
                }
                .onDelete(perform: delete)
            }
        }
        .frame(width: 500, height: 400)
        .onAppear { setupKeyListener() }
    }
    
    // MARK: - Sound control
    func addSound() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.allowedFileTypes = ["wav", "mp3", "aiff", "m4a"]
        
        if panel.runModal() == .OK, let url = panel.url {
            sounds.append(Sound(name: url.lastPathComponent, url: url, key: ""))
        }
    }
    
    func delete(at offsets: IndexSet) {
        sounds.remove(atOffsets: offsets)
    }
    
    func play(_ sound: Sound) {
        audio.play(url: sound.url)
    }
    
    // MARK: - Keyboard
    func setupKeyListener() {
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            if let key = event.charactersIgnoringModifiers?.lowercased() {
                if let sound = sounds.first(where: { $0.key.lowercased() == key }) {
                    play(sound)
                    return nil
                }
            }
            return event
        }
    }
    
    func binding(for sound: Sound) -> Binding<Sound> {
        guard let index = sounds.firstIndex(where: { $0.id == sound.id }) else {
            fatalError()
        }
        return $sounds[index]
    }
}
    func checkAccessibilityAccess() -> Bool {
        return AXIsProcessTrusted()
        if !checkAccessibilityAccess() {
            let alert = NSAlert()
            alert.messageText = "Soundpad требует доступ к Accessibility"
            alert.informativeText = """
    Слушай сюда блять, клавиши не воркают, открой:
    System Settings → Privacy & Security → Accessibility
    и добавьте это приложение.
    """
            alert.addButton(withTitle: "иди назуй")
            alert.runModal()
        }
    }

