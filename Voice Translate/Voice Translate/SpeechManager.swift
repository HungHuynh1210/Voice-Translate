import Foundation
import Speech
import AVFoundation
import Combine

class SpeechManager: ObservableObject {
    @Published var transcript: String = ""
    @Published var isRecording: Bool = false
    
    private let audioEngine = AVAudioEngine()
    private var speechRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    
    func startRecording(language: String) {
        let localeId = localeIdentifier(for: language)
        speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: localeId))
        
        guard let recognizer = speechRecognizer, recognizer.isAvailable else {
            print("Speech recognizer is not available for this locale")
            return
        }
        
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            
            recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
            guard let recognitionRequest = recognitionRequest else { return }
            recognitionRequest.shouldReportPartialResults = true
            
            let inputNode = audioEngine.inputNode
            let recordingFormat = inputNode.outputFormat(forBus: 0)
            
            inputNode.removeTap(onBus: 0)
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
                self.recognitionRequest?.append(buffer)
            }
            
            audioEngine.prepare()
            try audioEngine.start()
            
            transcript = ""
            DispatchQueue.main.async {
                self.isRecording = true
            }
            
            recognitionTask = recognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
                var isFinal = false
                
                if let result = result {
                    DispatchQueue.main.async {
                        self?.transcript = self?.formatToSpacedDigits(result.bestTranscription.formattedString) ?? result.bestTranscription.formattedString
                    }
                    isFinal = result.isFinal
                }
                
                if error != nil || isFinal {
                    self?.audioEngine.stop()
                    self?.audioEngine.inputNode.removeTap(onBus: 0)
                    self?.recognitionRequest = nil
                    self?.recognitionTask = nil
                    
                    DispatchQueue.main.async {
                        self?.isRecording = false
                    }
                }
            }
            
        } catch {
            print("Error setting up speech recognition: \(error)")
        }
    }
    
    func stopRecording() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        
        // Restore AVAudioSession to playback mode to release volume buttons Control
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Failed to restore audio session to playback: \(error)")
        }
        
        DispatchQueue.main.async {
            self.isRecording = false
        }
    }
    
    func requestPermission() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            DispatchQueue.main.async {
                switch authStatus {
                case .authorized:
                    print("Speech recognition authorized")
                default:
                    print("Speech recognition not authorized")
                }
            }
        }
        AVAudioSession.sharedInstance().requestRecordPermission { allowed in
            DispatchQueue.main.async {
                if allowed {
                    print("Microphone authorized")
                } else {
                    print("Microphone not authorized")
                }
            }
        }
    }
    
    private func localeIdentifier(for language: String) -> String {
        switch language {
        case "English": return "en-US"
        case "Vietnamese": return "vi-VN"
        case "Spanish": return "es-ES"
        case "French": return "fr-FR"
        case "Japanese": return "ja-JP"
        case "Korean": return "ko-KR"
        case "German": return "de-DE"
        case "Chinese": return "zh-CN"
        case "Hindi": return "hi-IN"
        case "Russian": return "ru-RU"
        case "Arabic": return "ar-SA"
        case "Portuguese": return "pt-PT"
        case "Italian": return "it-IT"
        case "Thai": return "th-TH"
        default: return "en-US"
        }
    }
    
    // Helper to prevent SFSpeechRecognizer from aggressively clumping numbers into large ints
    // E.g., "12345" -> "1 2 3 4 5" so that TTS reads individual digits.
    private func formatToSpacedDigits(_ text: String) -> String {
        let words = text.components(separatedBy: .whitespaces)
        let processed = words.map { word -> String in
            var rawWord = word
            var trailingPunctuation = ""
            if let lastChar = word.last, lastChar.isPunctuation {
                trailingPunctuation = String(lastChar)
                rawWord.removeLast()
            }
            
            let isStrictlyDigits = rawWord.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
            // If strictly numbers and length >= 4 (to avoid breaking real small numbers)
            if isStrictlyDigits && rawWord.count >= 4 {
                let spaced = rawWord.map { String($0) }.joined(separator: " ")
                return spaced + trailingPunctuation
            }
            return word
        }
        return processed.joined(separator: " ")
    }
}
