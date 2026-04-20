import Foundation
import Combine
import SwiftUI
import AVFoundation

@MainActor
class VoiceCloningManager: NSObject, ObservableObject, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    static let shared = VoiceCloningManager()
    
    // Core states
    @AppStorage("isVoiceCloned") var isVoiceCloned: Bool = false
    @Published var clonedAudioPath: URL? = nil
    
    @Published var isRecording: Bool = false
    @Published var isPlaying: Bool = false
    @Published var recordDuration: TimeInterval = 0
    @Published var recordProgress: CGFloat = 0 // 0 to 1 based on requiredDuration
    
    // Config
    let requiredDuration: TimeInterval = 60.0 // 1 phút
    
    // AV
    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?
    private var timer: Timer?
    
    override init() {
        super.init()
        setupAudioSession()
        loadPersistedState()
    }
    
    private func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth])
            try session.setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    private func loadPersistedState() {
        let path = FileManager.default.temporaryDirectory.appendingPathComponent("cloned_voice.m4a")
        if FileManager.default.fileExists(atPath: path.path) {
            clonedAudioPath = path
        }
    }
    
    func startRecording() {
        let path = FileManager.default.temporaryDirectory.appendingPathComponent("cloned_voice.m4a")
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: path, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.record()
            
            isRecording = true
            recordDuration = 0
            
            // Timer for duration visualization
            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
                guard let self = self, let recorder = self.audioRecorder else { return }
                DispatchQueue.main.async {
                    self.recordDuration = recorder.currentTime
                    self.recordProgress = min(CGFloat(self.recordDuration / self.requiredDuration), 1.0)
                    
                    if self.recordDuration >= self.requiredDuration {
                        self.stopRecording()
                    }
                }
            }
        } catch {
            print("Could not start recording")
        }
    }
    
    func stopRecording() {
        audioRecorder?.stop()
        isRecording = false
        timer?.invalidate()
        timer = nil
        clonedAudioPath = audioRecorder?.url
    }
    
    func playRecording() {
        guard let url = clonedAudioPath else { return }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            audioPlayer?.play()
            isPlaying = true
        } catch {
            print("Could not play snippet")
        }
    }
    
    func stopPlaying() {
        audioPlayer?.stop()
        isPlaying = false
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.async {
            self.isPlaying = false
        }
    }
    
    func resetClone() {
        isVoiceCloned = false
        clonedAudioPath = nil
        try? FileManager.default.removeItem(at: FileManager.default.temporaryDirectory.appendingPathComponent("cloned_voice.m4a"))
        stopPlaying()
        stopRecording()
    }
    
    func completeCloning() {
        isVoiceCloned = true
    }
}
