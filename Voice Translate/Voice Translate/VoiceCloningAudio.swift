import Foundation
import AVFoundation
import Combine

class VoiceCloningAudio: NSObject, ObservableObject, AVAudioPlayerDelegate, AVAudioRecorderDelegate {
    @Published var isRecording = false
    @Published var isPlaying = false
    @Published var recordingDuration: TimeInterval = 0
    @Published var displayTime: TimeInterval = 0
    
    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?
    private var timer: Timer?
    private var playbackTimer: Timer?
    var audioURL: URL?
    
    @Published var selectedLanguage: String = "English"
    @Published var translatedPrompt: String? = nil
    @Published var isAiReading = false
    
    private let synthesizer = AVSpeechSynthesizer()
    
    override init() {
        super.init()
        setupAudioSession()
        synthesizer.delegate = self
    }
    
    private func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, mode: .default, options: .defaultToSpeaker)
            try session.setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    func requirePermission(completion: @escaping (Bool) -> Void) {
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
    
    func startRecording() {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let audioFilename = paths[0].appendingPathComponent("voice_clone_temp.m4a")
        audioURL = audioFilename
        
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.record()
            
            isRecording = true
            recordingDuration = 0
            
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
                guard let self = self, let recorder = self.audioRecorder else { return }
                self.recordingDuration = recorder.currentTime
            }
        } catch {
            print("Could not start recording")
        }
    }
    
    func stopRecording() {
        audioRecorder?.stop()
        audioRecorder = nil
        timer?.invalidate()
        timer = nil
        isRecording = false
        displayTime = recordingDuration
    }
    
    func playRecording() {
        guard let url = audioURL else { return }
        do {
            if audioPlayer == nil {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.delegate = self
            }
            audioPlayer?.play()
            isPlaying = true
            
            playbackTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
                guard let self = self, let player = self.audioPlayer else { return }
                self.displayTime = player.duration - player.currentTime
            }
        } catch {
            print("Playback failed")
        }
    }
    
    func pauseRecording() {
        audioPlayer?.pause()
        isPlaying = false
        playbackTimer?.invalidate()
        playbackTimer = nil
    }
    
    func stopPlaying() {
        audioPlayer?.stop()
        audioPlayer?.currentTime = 0
        isPlaying = false
        playbackTimer?.invalidate()
        playbackTimer = nil
        
        if let duration = audioPlayer?.duration {
            displayTime = duration
        } else {
            displayTime = recordingDuration
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.async {
            self.stopPlaying()
        }
    }
    
    var timeString: String {
        let minutes = Int(recordingDuration) / 60
        let seconds = Int(recordingDuration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var playbackTimeString: String {
        let minutes = Int(displayTime) / 60
        let seconds = Int(displayTime) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    // MARK: - Text to Speech
    func readTextWithAI(text: String) {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: languageCode(from: selectedLanguage))
        synthesizer.speak(utterance)
        isAiReading = true
        isPlaying = true
    }
    
    func stopAIReading() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        isAiReading = false
        isPlaying = false
    }
    
    private func languageCode(from languageName: String) -> String {
        switch languageName {
        case "Vietnamese": return "vi-VN"
        case "Japanese": return "ja-JP"
        case "Korean": return "ko-KR"
        case "Chinese": return "zh-CN"
        case "Spanish": return "es-ES"
        case "French": return "fr-FR"
        case "German": return "de-DE"
        case "Italian": return "it-IT"
        case "Russian": return "ru-RU"
        case "Portuguese": return "pt-PT"
        default: return "en-US"
        }
    }
}

extension VoiceCloningAudio: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.isAiReading = false
            self.isPlaying = false
        }
    }
}
