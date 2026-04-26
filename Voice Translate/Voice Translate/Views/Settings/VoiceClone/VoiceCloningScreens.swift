import SwiftUI

// MARK: - Intro View (74:638)
struct IntroView: View {
    let onNext: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VoiceCloningIllustration(imageName: "Frame 48")
                .padding(.top, 0)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Before You Continue")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color(hex: "#0F172A"))
                
                Text("Please review and confirm the following requirements for secure voice cloning.")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(Color(hex: "#64748B"))
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 24)
            .padding(.top, 0)
            
            VStack(spacing: 12) {
                ChecklistItemView(
                    icon: "checkmark.circle",
                    title: "Verbal consent required",
                    subtitle: "A script will be provided for you to read."
                )
                
                ChecklistItemView(
                    icon: "checkmark.circle",
                    title: "Secure profile linkage",
                    subtitle: "Biometric verification is active."
                )
                
                ChecklistItemView(
                    icon: "checkmark.circle",
                    title: "Permanent deletion option",
                    subtitle: "Remove your data at any time."
                )
                
                ChecklistItemView(
                    icon: "checkmark.circle",
                    title: "1-minute recording time",
                    subtitle: "High-quality audio is required."
                )
            }
            .padding(.horizontal, 24)
            
            Spacer()
            
            VCPrimaryButton(title: "Click to Start", action: {
                onNext()
            })
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
        }
    }
}

// MARK: - Recording View (75:2106 / 75:2669)
struct RecordingView: View {
    @EnvironmentObject var audioManager: VoiceCloningAudio
    @State private var showToast = false
    @State private var showLanguagePicker = false
    @State private var isTranslating = false
    @State private var translationCache: [String: String] = [:]
    
    private let defaultPromptText = "I am (say your name). I understand that my voice will be recorded and used by AI to create a synthetic (cloned) version of my voice. I give permission for my voice recordings to be used for this purpose."
    
    let isActive: Bool
    var onRecord: (() -> Void)? = nil
    var onNext: (() -> Void)? = nil
    var onReset: (() -> Void)? = nil
    
    private func handleAttemptStop() {
        if audioManager.recordingDuration < 10.0 {
            withAnimation { showToast = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation { showToast = false }
            }
        } else {
            onNext?()
        }
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    Text("Read Out the Entire Sentence Correctly")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color(hex: "#0F172A"))
                        .multilineTextAlignment(.center)
                        .padding(.top, 16)
                        .padding(.horizontal, 24)
                        .offset(y: -16) // visually pushes just this title up without affecting sibling layout
                    
                    // Language selector
                    HStack {
                        Text("Display in:")
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "#64748B"))
                        Spacer()
                        Button(action: { showLanguagePicker = true }) {
                            HStack {
                                Text(audioManager.selectedLanguage)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(Color(hex: "#0F172A"))
                                Image(systemName: "chevron.down")
                                    .foregroundColor(Color(hex: "#64748B"))
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.white)
                            .cornerRadius(20)
                            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color(hex: "#E2E8F0"), lineWidth: 1))
                        }
                    }
                    .padding(.horizontal, 24)
                    .sheet(isPresented: $showLanguagePicker) {
                        TranslationLanguagePicker(selectedLanguage: $audioManager.selectedLanguage, isSource: false)
                    }
                    .onChange(of: audioManager.selectedLanguage) { newValue in
                        if newValue == "English" {
                            audioManager.translatedPrompt = nil
                            isTranslating = false
                        } else if let cached = translationCache[newValue] {
                            audioManager.translatedPrompt = cached
                            isTranslating = false
                        } else {
                            isTranslating = true
                            OpenAIService.shared.translate(text: defaultPromptText, from: "English", to: newValue, industry: "General") { result in
                                DispatchQueue.main.async {
                                    self.audioManager.translatedPrompt = result
                                    if let result = result {
                                        self.translationCache[newValue] = result
                                    }
                                    self.isTranslating = false
                                }
                            }
                        }
                    }
                    
                    // Recording Card
                    VStack(spacing: 0) {
                        let baseFont = Font.system(size: 18, weight: .medium)
                        
                        if audioManager.selectedLanguage == "English" {
                            VStack(alignment: .center, spacing: 8) {
                                HStack(spacing: 6) {
                                    Text("\"I am")
                                        .font(baseFont)
                                        .foregroundColor(Color(hex: "#0F172A"))
                                        .fixedSize(horizontal: true, vertical: false)
                                    Text("say your name.")
                                        .font(baseFont)
                                        .foregroundColor(.white)
                                        .lineLimit(1)
                                        .fixedSize(horizontal: true, vertical: false)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 4)
                                        .background(Color(hex: "#0069F2"))
                                        .cornerRadius(12)
                                    Text("I understand")
                                        .font(baseFont)
                                        .foregroundColor(Color(hex: "#0F172A"))
                                        .fixedSize(horizontal: true, vertical: false)
                                }
                                .minimumScaleFactor(0.8)
                                
                                Text("that my voice will be recorded and used by Voice Translator AI Translate to create a synthetic (cloned) version of my voice. I give permission for my voice recordings to be used for this purpose.\"")
                                    .font(baseFont)
                                    .foregroundColor(Color(hex: "#0F172A"))
                                    .lineSpacing(8)
                                    .multilineTextAlignment(.center)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .padding(24)
                            
                        } else if isTranslating {
                            Text("Translating...")
                                .font(baseFont)
                                .foregroundColor(Color(hex: "#64748B"))
                                .lineSpacing(8)
                                .padding(24)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        } else if let translated = audioManager.translatedPrompt {
                            Text("“" + translated + "”")
                                .font(baseFont)
                                .foregroundColor(Color(hex: "#0F172A"))
                                .lineSpacing(8)
                                .padding(24)
                        } else {
                            Text("Translation failed.")
                                .font(baseFont)
                                .foregroundColor(Color.red)
                                .lineSpacing(8)
                                .padding(24)
                        }
                        
                        if isActive {
                            // Live waveform rendering placeholder
                            HStack(spacing: 4) {
                                ForEach(0..<40) { i in
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(Color(hex: "#0069F2"))
                                        .frame(width: 4, height: CGFloat.random(in: 10...30))
                                }
                            }
                            .frame(height: 40)
                            .padding(.bottom, 24)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .background(Color(red: 59/255, green: 130/255, blue: 246/255).opacity(0.1))
                    .cornerRadius(24)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .strokeBorder(style: StrokeStyle(lineWidth: 1.5, dash: [6]))
                            .foregroundColor(Color(hex: "#0069F2").opacity(0.4))
                    )
                    .padding(.horizontal, 24)
                    
                    Spacer(minLength: UIScreen.main.bounds.height > 900 ? 100 : (UIScreen.main.bounds.height > 840 ? 40 : 16))
                    
                    // Recording Controls
                    if isActive {
                        VStack(spacing: 16) {
                            Text(audioManager.timeString)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Color(hex: "#64748B"))
                            
                            HStack(spacing: 40) {
                                Button(action: {
                                    audioManager.stopRecording()
                                    onReset?()
                                }) {
                                    VStack(spacing: 8) {
                                        Image(systemName: "gobackward")
                                            .font(.system(size: 24))
                                        Text("Reset")
                                            .font(.system(size: 14))
                                    }
                                    .foregroundColor(Color(hex: "#64748B"))
                                }
                                
                                Button(action: handleAttemptStop) {
                                    Circle()
                                        .fill(Color(hex: "#EF4444"))
                                        .frame(width: 80, height: 80)
                                        .shadow(color: Color(hex: "#EF4444").opacity(0.3), radius: 10, y: 4)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 6)
                                                .fill(Color.white)
                                                .frame(width: 24, height: 24)
                                        )
                                }
                                
                                Button(action: handleAttemptStop) {
                                    VStack(spacing: 8) {
                                        Image(systemName: "chevron.right.circle")
                                            .font(.system(size: 26))
                                        Text("Next")
                                            .font(.system(size: 14))
                                    }
                                    .foregroundColor(Color(hex: "#0069F2"))
                                }
                            }
                        }
                        .padding(.bottom, 90)
                    } else {
                        VStack(spacing: 16) {
                            Text("Click to start")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(Color(hex: "#64748B"))
                            
                            Button(action: { onRecord?() }) {
                                ZStack {
                                    Circle()
                                        .fill(Color(hex: "#0069F2").opacity(0.1))
                                        .frame(width: 100, height: 100)
                                    Circle()
                                        .fill(Color(hex: "#0069F2"))
                                        .frame(width: 76, height: 76)
                                        .shadow(color: Color(hex: "#0069F2").opacity(0.3), radius: 10, y: 4)
                                    Image(systemName: "mic.fill")
                                        .font(.system(size: 32))
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        .padding(.bottom, 90)
                    }
                } // End Main VStack
            } // End ScrollView
            if showToast {
                Text("Please record longer than 10 seconds and try again.")
                    .font(.system(size: 14))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color.black.opacity(0.8))
                    .cornerRadius(8)
                    .padding(.bottom, 120)
                    .transition(.opacity)
                    .zIndex(1)
            }
        } // End ZStack
    } // End body
} // End RecordingView
    
    // MARK: - Confirm View (75:2840)
    struct ConfirmView: View {
        @EnvironmentObject var audioManager: VoiceCloningAudio
        let onConvert: () -> Void
        
        var body: some View {
            VStack(spacing: 24) {
                Text("Confirm to Proceed with Voice Cloning")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color(hex: "#0F172A"))
                    .multilineTextAlignment(.center)
                    .padding(.top, 24)
                    .padding(.horizontal, 24)
                
                // Big Waveform Card
                VStack(spacing: 20) {
                    Text(audioManager.playbackTimeString)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color(hex: "#0069F2"))
                        .padding(.top, 24)
                    
                    // Audio Waveform Visualizer
                    HStack(spacing: 4) {
                        ForEach(0..<40) { i in
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color(hex: "#0069F2").opacity(i % 3 == 0 ? 0.4 : 1.0))
                                .frame(width: 4, height: CGFloat.random(in: 15...60))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .padding(.horizontal, 24)
                    
                    // Pause button circle below waveform
                    Button(action: {
                        if audioManager.isPlaying {
                            audioManager.pauseRecording()
                        } else {
                            audioManager.playRecording()
                        }
                    }) {
                        Image(systemName: audioManager.isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 20))
                            .foregroundColor(Color(hex: "#0069F2"))
                            .frame(width: 48, height: 48)
                            .background(Color(hex: "#EFF6FF"))
                            .clipShape(Circle())
                    }
                    .padding(.bottom, 24)
                }
                .background(Color.white)
                .cornerRadius(24)
                .shadow(color: Color.black.opacity(0.04), radius: 10, y: 4)
                .padding(.horizontal, 24)
                
                Spacer()
                
                VCPrimaryButton(title: "Convert", action: onConvert, systemImage: "arrow.right")
                    .padding(.horizontal, 24)
                    .padding(.bottom, 16)
            }
        }
    }
    
    // MARK: - Generating View (77:3601)
    struct GeneratingView: View {
        let onComplete: () -> Void
        @State private var progress: CGFloat = 0.0
        
        var body: some View {
            VStack(alignment: .leading, spacing: 24) {
                VoiceCloningIllustration(imageName: "Frame 47")
                    .padding(.top, 0)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Generating Your Voice")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color(hex: "#0F172A"))
                    
                    Text("This might take about 1 minute")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(Color(hex: "#64748B"))
                }
                .padding(.horizontal, 24)
                .padding(.top, 8)
                
                // Progress Bar simulation
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(hex: "#E2E8F0"))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color(hex: "#0069F2"), Color(hex: "#E2E8F0")]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(0, progress), height: 8)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                
                VStack(spacing: 12) {
                    ChecklistItemView(
                        icon: "checkmark.circle",
                        title: "Delete Anytime",
                        subtitle: "You can permanently delete your voice clone at any time in Settings."
                    )
                    
                    ChecklistItemView(
                        icon: "checkmark.circle",
                        title: "Automatic Deletion",
                        subtitle: "To protect your privacy, your voice clone will be automatically deleted after 30 days of inactivity."
                    )
                    
                    ChecklistItemView(
                        icon: "checkmark.circle",
                        title: "Create in Background",
                        subtitle: "You can leave this page while your voice clone is being created. We'll notify you once it's ready."
                    )
                }
                .padding(.horizontal, 24)
                
                Spacer()
            }
            .onAppear {
                withAnimation(.linear(duration: 4.0)) {
                    progress = 300 // Simulate progress filling up
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 4.5) {
                    onComplete()
                }
            }
        }
    }
    
    // MARK: - Success View (77:3457)
    struct SuccessView: View {
        let onFinish: () -> Void
        @EnvironmentObject var audioManager: VoiceCloningAudio
        @AppStorage("isAutoPlaybackEnabled") private var isAutoPlaybackEnabled = true
        @State private var hasPlayedOnce = false
        
        var body: some View {
            VStack(spacing: 24) {
                VoiceCloningIllustration(imageName: "Frame 47")
                    .padding(.top, 40)
                
                VStack(alignment: .trailing, spacing: 16) {
                    let defaultEngText = "I am say your name. I understand that my voice will be recorded and used by Voice Translator AI Translate to create a synthetic (cloned) version of my voice. I give permission for my voice recordings to be used for this purpose."
                    let textToRead = audioManager.selectedLanguage == "English" ? defaultEngText : (audioManager.translatedPrompt ?? "Translation failed.")
                    
                    Text(textToRead)
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(Color(hex: "#0F172A"))
                        .lineSpacing(6)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Button(action: {
                        if audioManager.isPlaying || audioManager.isAiReading {
                            audioManager.stopAIReading()
                            audioManager.pauseRecording()
                        } else {
                            audioManager.readTextWithAI(text: textToRead)
                        }
                    }) {
                        Image(systemName: (audioManager.isPlaying || audioManager.isAiReading) ? "speaker.wave.2.fill" : "speaker.wave.2")
                            .font(.system(size: 20))
                            .foregroundColor((audioManager.isPlaying || audioManager.isAiReading) ? Color(hex: "#0069F2") : Color(hex: "#0F172A"))
                    }
                }
                .padding(24)
                .background(Color.white)
                .cornerRadius(16)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(hex: "#E2E8F0"), lineWidth: 1))
                .shadow(color: Color.black.opacity(0.04), radius: 10, y: 4)
                .padding(.horizontal, 24)
                .padding(.top, 40) // pushes ONLY this text box down further below the static illustration
                
                Spacer(minLength: 60)
                
                VCPrimaryButton(title: "Start Translation", action: onFinish)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 16)
            }
            .frame(minHeight: UIScreen.main.bounds.height < 800 ? 600 : UIScreen.main.bounds.height - 120)
            .onAppear {
                let defaultEngText = "I am say your name. I understand that my voice will be recorded and used by Voice Translator AI Translate to create a synthetic (cloned) version of my voice. I give permission for my voice recordings to be used for this purpose."
                let textToRead = audioManager.selectedLanguage == "English" ? defaultEngText : (audioManager.translatedPrompt ?? "Translation failed.")
                
                if isAutoPlaybackEnabled && !hasPlayedOnce {
                    // Auto play the AI voice once when the screen appears
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        if !hasPlayedOnce { // Double check inside async
                            audioManager.readTextWithAI(text: textToRead)
                            hasPlayedOnce = true
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Existing Profile View (80:4385)
    struct ExistingProfileView: View {
        let onReset: () -> Void
        let onDelete: () -> Void
        
        var body: some View {
            VStack(alignment: .leading, spacing: 24) {
                Text("Reset Voice Clone")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color(hex: "#0F172A"))
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                
                VStack(spacing: 12) {
                    ChecklistItemView(
                        icon: "checkmark.seal.fill",
                        title: "One-Minute Recording",
                        subtitle: "Record your voice for about 1 minute in a quiet environment and follow the on-screen reading prompts."
                    )
                    
                    ChecklistItemView(
                        icon: "checkmark.seal.fill",
                        title: "Privacy Protection",
                        subtitle: "Your cloned voice will automatically expire after 30 days if it isn't used."
                    )
                    
                    ChecklistItemView(
                        icon: "checkmark.seal.fill",
                        title: "Automatic Retry",
                        subtitle: "If cloning fails, we may automatically retry using your saved audio."
                    )
                }
                .padding(.horizontal, 24)
                
                Button(action: onDelete) {
                    Text("Delete your old voice")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.red)
                        .underline()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.top, 8)
                
                Spacer()
                
                VCPrimaryButton(title: "Click to Start", action: onReset)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 16)
            }
            .frame(minHeight: UIScreen.main.bounds.height < 800 ? 600 : UIScreen.main.bounds.height - 120)
        }
    }
    
    struct VoiceCloningIllustration_Previews: PreviewProvider {
        static var previews: some View {
            VoiceCloningIllustration(imageName: "Frame 48")
        }
    }

