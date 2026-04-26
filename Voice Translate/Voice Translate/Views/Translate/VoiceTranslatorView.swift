import SwiftUI
import UIKit
import AVFoundation
import Combine

enum FocusedField {
    case source
    case target
}

enum TranslatorState {
    case `default`
    case recording
    case result
    case hideOriginal
    case editing
}

struct VoiceTranslatorView: View {
    @AppStorage("selectedIndustry") private var selectedIndustry: String = "Education"
    @State private var sourceLanguage = "English"
    @State private var targetLanguage = "Vietnamese"
    @State private var sourceText = ""
    @State private var targetText = ""
    @State private var showHistory = false
    @State private var showIndustryPopup = false
    @State private var showLanguagePicker = false
    @State private var isSelectingSource = true
    @State private var showAINotes = false
    @State private var showCamera = false
    @State private var showFeedbackForm = false
    @State private var popupDragOffset: CGFloat = 0
    @State private var isTransitioningPopups: Bool = false
    @AppStorage("hideTabBar") private var hideTabBar = false
    
    // Services
    @StateObject private var speechManager = SpeechManager()
    
    // New States
    @State private var currentState: TranslatorState = .default
    @State private var recordingTime: Int = 0
    @State private var isTimerPaused = false
    @State private var showEditModal = false
    @State private var editingText = ""
    @FocusState private var isEditingTextFocused: Bool
    @State private var editingField: FocusedField = .source
    @State private var speechTimeoutTask: Task<Void, Never>? = nil
    
    // Timer Publisher
    let timerPublisher = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    // Speech Synthesizer
    private let synthesizer = AVSpeechSynthesizer()
    
    var body: some View {
        ZStack {
            // MAIN UI (FROZEN)
            ZStack {
                Color(hex: "#F0F4FF").ignoresSafeArea() // Light blue-grey
            
            VStack(spacing: 0) {
                headerView
                languageBarView
                    .padding(.bottom, 16)
                
                // Content Area
                if currentState == .default {
                    VStack(alignment: .center, spacing: 16) {
                        emptyStateView
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    Spacer()
                } else {
                    ScrollView {
                        VStack(alignment: .center, spacing: 16) {
                            cardsArea
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                    }
                    .safeAreaInset(edge: .bottom) {
                        Spacer().frame(height: UIScreen.main.bounds.height < 800 ? 140 : 180)
                    }
                }
            }
            
            // Bottom Controls Area
            VStack(spacing: 0) {
                Spacer()
                
                microphonePanelView
                    .padding(.bottom, UIScreen.main.bounds.height < 800 ? 40 : 95)
            }
            

            }
            .ignoresSafeArea(.keyboard)
            
            // OVERLAYS (SHRINKABLE)
            ZStack {
                // Custom Industry Sheet Overlay
                if showIndustryPopup {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.spring()) { showIndustryPopup = false }
                        }
                        .zIndex(100)
                    
                    VStack(spacing: 0) {
                        Spacer()
                        MyIndustryView(
                            onShowFeedback: {
                                isTransitioningPopups = true
                                withAnimation(.spring()) { showIndustryPopup = false }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    withAnimation(.spring()) { showFeedbackForm = true }
                                    isTransitioningPopups = false
                                }
                            },
                            onClose: {
                                withAnimation(.spring()) { showIndustryPopup = false }
                            },
                            isPresentedAsSheet: true
                        )
                        .frame(maxHeight: UIScreen.main.bounds.height * 0.83)
                        .clipShape(RoundedCorner(radius: 24, corners: [.topLeft, .topRight]))
                        .background(
                            RoundedCorner(radius: 24, corners: [.topLeft, .topRight])
                                .fill(Color(hex: "#F8FAFC"))
                                .ignoresSafeArea(.all, edges: .bottom)
                        )
                        .offset(y: popupDragOffset)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    if value.translation.height > 0 {
                                        popupDragOffset = value.translation.height
                                    }
                                }
                                .onEnded { value in
                                    if value.translation.height > 100 {
                                        withAnimation(.spring()) {
                                            showIndustryPopup = false
                                            popupDragOffset = 0
                                        }
                                    } else {
                                        withAnimation(.spring()) {
                                            popupDragOffset = 0
                                        }
                                    }
                                }
                        )
                    }
                    .zIndex(101)
                    .transition(.move(edge: .bottom))
                }
                
                // Custom Feedback Form Overlay
                if showFeedbackForm {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture {
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                            withAnimation(.spring()) { showFeedbackForm = false }
                        }
                        .zIndex(102)
                    
                    VStack(spacing: 0) {
                        Spacer()
                        FeedbackFormContainer(showFeedbackForm: $showFeedbackForm)
                            .frame(height: 480) 
                            .clipShape(RoundedCorner(radius: 24, corners: [.topLeft, .topRight]))
                            .background(
                                RoundedCorner(radius: 24, corners: [.topLeft, .topRight])
                                    .fill(Color.white)
                                    .ignoresSafeArea(.all, edges: .bottom)
                            )
                            .offset(y: popupDragOffset)
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        if value.translation.height > 0 {
                                            popupDragOffset = value.translation.height
                                        }
                                    }
                                    .onEnded { value in
                                        if value.translation.height > 80 {
                                            withAnimation(.spring()) {
                                                showFeedbackForm = false
                                                popupDragOffset = 0
                                            }
                                        } else {
                                            withAnimation(.spring()) {
                                                popupDragOffset = 0
                                            }
                                        }
                                    }
                            )
                    }
                    .zIndex(103)
                    .transition(.move(edge: .bottom))
                }
            }
        }
        .fullScreenCover(isPresented: $showHistory) {
            HistoryView()
        }
        .fullScreenCover(isPresented: $showAINotes) {
            AINotesListView()
        }
        .fullScreenCover(isPresented: $showCamera) {
            CameraTranslatorView()
        }
        .sheet(isPresented: $showEditModal) {
            EditTranslationSheet(
                editingText: $editingText,
                showEditModal: $showEditModal,
                editingField: editingField,
                sourceText: $sourceText,
                targetText: $targetText,
                sourceLanguage: sourceLanguage,
                targetLanguage: targetLanguage,
                selectedIndustry: selectedIndustry
            )
        }
        .sheet(isPresented: $showLanguagePicker) {
            TranslationLanguagePicker(
                selectedLanguage: isSelectingSource ? $sourceLanguage : $targetLanguage,
                isSource: isSelectingSource
            )
        }
        .onChange(of: speechManager.transcript) { newValue in
            if currentState == .recording && !newValue.isEmpty {
                sourceText = newValue
                
                speechTimeoutTask?.cancel()
                speechTimeoutTask = Task {
                    try? await Task.sleep(nanoseconds: 2_000_000_000)
                    if !Task.isCancelled {
                        await MainActor.run {
                            if self.currentState == .recording {
                                self.handleMicTap()
                            }
                        }
                    }
                }
            }
        }
        .onChange(of: showIndustryPopup) { newValue in
            if newValue || showFeedbackForm || isTransitioningPopups { hideTabBar = true }
            else { hideTabBar = false }
        }
        .onChange(of: showFeedbackForm) { newValue in
            if newValue || showIndustryPopup || isTransitioningPopups { hideTabBar = true }
            else { hideTabBar = false }
        }
        .onAppear {
            speechManager.requestPermission()
        }
    }
    
    // MARK: - Components
    
    private var headerView: some View {
        HStack {
            Button(action: { showHistory = true }) {
                Image(systemName: "line.3.horizontal")
                    .font(.system(size: 24))
                    .foregroundColor(.themeMainText)
            }
            Spacer()
            Text("Voice Translator")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.themeMainText)
            Spacer()
            Button(action: { showAINotes = true }) {
                Image("nav_right_icon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 28, height: 28)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 16)
    }
    
    private var languageBarView: some View {
        HStack(spacing: 0) {
            Button(action: { isSelectingSource = true; showLanguagePicker = true }) {
                Text(sourceLanguage)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
            Button(action: {
                withAnimation(.spring()) {
                    let temp = sourceLanguage
                    sourceLanguage = targetLanguage
                    targetLanguage = temp
                    
                    let tempText = sourceText
                    sourceText = targetText
                    targetText = tempText
                }
            }) {
                Image("icon_language_swap")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 42, height: 42)
            }
            .zIndex(1)
            
            Button(action: { isSelectingSource = false; showLanguagePicker = true }) {
                Text(targetLanguage)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .frame(height: 60)
        .background(Color(hex: "#000000"))
        .cornerRadius(25)
        .overlay(
            RoundedRectangle(cornerRadius: 25)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
        .padding(.horizontal, 20)
    }
    
    // MARK: - Center Content
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer().frame(height: 60)
            Image("translation_empty_icon")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
            
            Text("Tap the microphone to start\nspeaking...")
                .font(.system(size: 20))
                .foregroundColor(.themeSecondaryText)
                .multilineTextAlignment(.center)
            
            defaultCategoryButton
                .padding(.top, 8)
        }
    }
    
    @ViewBuilder
    private var cardsArea: some View {
        VStack(alignment: .leading, spacing: 16) {
            if currentState != .hideOriginal {
                sourceCardView
            } else {
                // Free floating badge when source card is hidden
                categoryBadgeView
                    .padding(.bottom, 4)
            }
            
            if currentState == .recording || targetText == "Translating..." {
                HStack {
                    Spacer()

 AnimatedLoadingDotsView()
                    Spacer()
                }
            }
            
            targetCardView
        }
    }
    
    private var sourceCardView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                categoryBadgeView
                Spacer()
            }
            
            Text(sourceText.isEmpty ? "Listening..." : sourceText)
                .font(.system(size: 18))
                .foregroundColor(.themeMainText)
            
            Spacer(minLength: 20)
            
            HStack {
                if currentState != .recording {
                    actionIconsView(text: sourceText, isSource: true)
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
        .contentShape(Rectangle())
        .onTapGesture {
            if currentState != .recording {
                editingField = .source
                editingText = sourceText
                withAnimation { showEditModal = true }
            }
        }
    }
    
    private var targetCardView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Spacer()
                if currentState == .result || currentState == .hideOriginal {
                    Button(action: {
                        withAnimation(.spring()) {
                            currentState = (currentState == .hideOriginal) ? .result : .hideOriginal
                        }
                    }) {
                        Image("hide_original_icon")
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.themeSecondaryText)
                    }
                }
            }
            
            Text(targetText.isEmpty ? "..." : targetText)
                .font(.system(size: 18))
                .foregroundColor(.themeMainText)
            
            Spacer(minLength: 20)
            
            if currentState == .result || currentState == .hideOriginal || currentState == .editing {
                actionIconsView(text: targetText, isSource: false)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
        .contentShape(Rectangle())
        .onTapGesture {
            if currentState != .recording && targetText != "Translating..." {
                editingField = .target
                editingText = targetText
                withAnimation { showEditModal = true }
            }
        }
    }
    
    private func actionIconsView(text: String, isSource: Bool) -> some View {
        HStack(spacing: 16) {
            Spacer()
            Button(action: { UIPasteboard.general.string = text }) {
                Image(systemName: "doc.on.doc")
            }

            Button(action: {
                editingField = isSource ? .source : .target
                editingText = text
                withAnimation { showEditModal = true }
            }) {
                Image(systemName: "square.and.pencil")
            }
            Button(action: { speakText(text, isSource: isSource) }) {
                Image(systemName: "speaker.wave.2")
            }
            Button(action: { shareText(text) }) {
                Image("icon_share")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
            }
        }
        .font(.system(size: 20))
        .foregroundColor(.themeSecondaryText)
    }
    
    // MARK: - Floating / Bottom Elements
    
    private var categoryBadgeView: some View {
        Button(action: { withAnimation(.spring()) { showIndustryPopup = true } }) {
            HStack(spacing: 4) {
                Text(LocalizedStringKey(selectedIndustry))
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .truncationMode(.tail)
                Image(systemName: "chevron.down")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color(hex: "#2563EB"))
            .cornerRadius(12)
        }
    }
    
    private var defaultCategoryButton: some View {
        Button(action: { withAnimation(.spring()) { showIndustryPopup = true } }) {
            HStack(spacing: 4) {
                Text(LocalizedStringKey(selectedIndustry))
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.themeMainText)
                    .lineLimit(1)
                    .truncationMode(.tail)
                Image(systemName: "chevron.down")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.themeMainText)
            }
            .padding(.horizontal, 20)
            .frame(height: 40)
            .background(Color.white)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color(hex: "#0069F2"), lineWidth: 1.5)
            )
        }
    }
    
    private var microphonePanelView: some View {
        VStack(spacing: 12) {
            if currentState == .recording {
                Text(timeString(from: recordingTime))
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.themeSecondaryText)
                    .onReceive(timerPublisher) { _ in
                        if currentState == .recording && !isTimerPaused {
                            recordingTime += 1
                        }
                    }
            } else {
                Spacer().frame(height: 19) // Keep layout stable without timer
            }
            
            HStack(spacing: 40) {
                if currentState == .recording {
                    Button(action: {
                        withAnimation {
                            speechManager.stopRecording()
                            recordingTime = 0
                            isTimerPaused = false
                            sourceText = ""
                            targetText = ""
                            // Restart recording instead of abandoning
                            speechManager.startRecording(language: sourceLanguage)
                        }
                    }) {
                        Text("Reset")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.themeMainText)
                            .frame(width: 60, height: 60)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
                    }
                } else if currentState != .default {
                    Spacer().frame(width: 60)
                }
                
                ZStack {
                    if currentState != .default {
                        Circle()
                            .fill(Color(hex: "#0069F2").opacity(0.4))
                            .frame(width: 112, height: 112)
                            .blur(radius: 10)
                    }
                    
                    Button(action: handleMicTap) {
                        Image(systemName: (currentState == .recording && !isTimerPaused) ? "square.fill" : "mic.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.white)
                            .frame(width: 72, height: 72)
                            .background(Color(hex: "#0069F2"))
                            .clipShape(Circle())
                            .shadow(color: Color(hex: "#0069F2").opacity(0.4), radius: 24, x: 0, y: 0)
                    }
                }
                
                if currentState == .recording {
                    Button(action: {
                        isTimerPaused.toggle()
                    }) {
                        Image(systemName: isTimerPaused ? "play.fill" : "pause.fill")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.themeMainText)
                            .frame(width: 60, height: 60)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
                    }
                } else if currentState != .default {
                    Spacer().frame(width: 60)
                }
            }
        }
    }
    



    // MARK: - Helpers
    
    private func handleMicTap() {
        withAnimation(.spring()) {
            switch currentState {
            case .default, .result, .hideOriginal:
                currentState = .recording
                recordingTime = 0
                isTimerPaused = false
                sourceText = ""
                targetText = "..."
                speechManager.startRecording(language: sourceLanguage)
                
            case .recording:
                currentState = .result
                speechManager.stopRecording()
                targetText = "Translating..."
                
                OpenAIService.shared.translate(
                    text: sourceText,
                    from: sourceLanguage,
                    to: targetLanguage,
                    industry: selectedIndustry
                ) { result in
                    DispatchQueue.main.async {
                        if let translated = result {
                            self.targetText = translated
                            self.targetText = translated
                            
                            // Sinh AI Summary lưu background
                            Task {
                                if let summaryResult = try? await OpenAIService.shared.summarize(text: sourceText, targetLanguage: targetLanguage) {
                                    DispatchQueue.main.async {
                                        let cleanLines = summaryResult.content.components(separatedBy: .newlines).map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
                                        var parsedTitle = "Voice Summary"
                                        var parsedSubtitle = "Voice Analysis"
                                        
                                        if let firstLine = cleanLines.first {
                                            parsedTitle = firstLine.replacingOccurrences(of: "**", with: "")
                                        }
                                        if cleanLines.count > 1 {
                                            let overviewLine = cleanLines[1]
                                            let parts = overviewLine.split(separator: ":", maxSplits: 1)
                                            if parts.count == 2 {
                                                parsedSubtitle = String(parts[1]).trimmingCharacters(in: .whitespaces)
                                            } else {
                                                parsedSubtitle = overviewLine
                                            }
                                        }
                                        
                                        AINoteMockData.addNote(
                                            title: parsedTitle,
                                            description: parsedSubtitle,
                                            type: .voice,
                                            summary: summaryResult.content
                                        )
                                    }
                                }
                            }
                        } else {
                            self.targetText = "Translation failed."
                        }
                    }
                }
                
            case .editing:
                break
            }
        }
    }
    
    private func timeString(from seconds: Int) -> String {
        let min = seconds / 60
        let sec = seconds % 60
        return String(format: "%02d:%02d", min, sec)
    }
    
    private func speakText(_ text: String, isSource: Bool) {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: .duckOthers)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set audio session to playback: \(error)")
        }
        
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        let utterance = AVSpeechUtterance(string: text)
        let langName = isSource ? sourceLanguage : targetLanguage
        utterance.voice = AVSpeechSynthesisVoice(language: languageCode(from: langName))
        synthesizer.speak(utterance)
    }
    
    private func languageCode(from languageName: String) -> String {
        switch languageName {
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
    
    private func shareText(_ text: String) {
        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootVC = window.rootViewController {
            var topController = rootVC
            while let presented = topController.presentedViewController {
                topController = presented
            }
            topController.present(activityVC, animated: true)
        }
    }
}


struct EditTranslationSheet: View {
    @Binding var editingText: String
    @Binding var showEditModal: Bool
    var editingField: FocusedField
    @Binding var sourceText: String
    @Binding var targetText: String
    var sourceLanguage: String
    var targetLanguage: String
    var selectedIndustry: String
    
    @FocusState private var isEditingTextFocused: Bool

    var body: some View {
        VStack(spacing: 20) {
            // Custom Header
            HStack {
                Button(action: { showEditModal = false }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color(hex: "#64748B"))
                        .frame(width: 40, height: 40)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
                }
                
                Spacer()
                
                Text("Edit Text")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(hex: "#0F172A"))
                
                Spacer()
                
                Button(action: {
                    if editingField == .source {
                        sourceText = editingText
                        targetText = "Translating..."
                        OpenAIService.shared.translate(text: sourceText, from: sourceLanguage, to: targetLanguage, industry: selectedIndustry) { result in
                            DispatchQueue.main.async { self.targetText = result ?? "Translation failed." }
                        }
                    } else {
                        targetText = editingText
                        sourceText = "Translating..."
                        OpenAIService.shared.translate(text: targetText, from: targetLanguage, to: sourceLanguage, industry: selectedIndustry) { result in
                            DispatchQueue.main.async { self.sourceText = result ?? "Translation failed." }
                        }
                    }
                    showEditModal = false
                }) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color(hex: "#2563EB"))
                        .frame(width: 40, height: 40)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)
            
            // Text Editor stretches to fill remaining space
            TextEditor(text: $editingText)
                .scrollContentBackground(.hidden)
                .focused($isEditingTextFocused)
                .padding(12)
                .background(Color.white)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(hex: "#2563EB"), lineWidth: 1)
                )
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.black)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        isEditingTextFocused = true
                    }
                }
        }
        .background(Color(hex: "#F8FAFC").ignoresSafeArea())
        .presentationDetents([.fraction(0.35)])
        .presentationDragIndicator(.visible)
    }
}

struct TranslationLanguagePicker: View {
    @Binding var selectedLanguage: String
    var isSource: Bool
    @Environment(\.presentationMode) var presentationMode
    
    @State private var searchText = ""
    
    let allLanguages = [
        "English", "Vietnamese", "Spanish", "French", "Japanese", "Korean", "German", 
        "Chinese", "Hindi", "Russian", "Arabic", "Portuguese", "Italian", "Thai"
    ]
    
    var suggestions: [String] {
        return ["English", "Vietnamese"]
    }
    
    var filteredSuggestions: [String] {
        if searchText.isEmpty { return suggestions }
        return suggestions.filter { $0.localizedCaseInsensitiveContains(searchText) }
    }
    
    var filteredAll: [String] {
        if searchText.isEmpty { return allLanguages }
        return allLanguages.filter { $0.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header Area (White Background)
            VStack(spacing: 16) {
                // Title & Close Button
                HStack {
                    Text(isSource ? "Translate From" : "Translate To")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(Color(hex: "#0F172A"))
                    Spacer()
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Color(hex: "#0F172A"))
                    }
                }
                .padding(.top, 24)
                .padding(.horizontal, 20)
                
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(Color(hex: "#94A3B8"))
                        .font(.system(size: 16))
                    TextField("Search language", text: $searchText)
                        .font(.system(size: 16))
                        .foregroundColor(Color(hex: "#0F172A"))
                }
                .padding(.horizontal, 12)
                .frame(height: 44)
                .background(Color(hex: "#F1F5F9"))
                .cornerRadius(12)
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
            }
            .background(Color.white)
            
            // List Area
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    
                    if !filteredSuggestions.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Suggestion")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color(hex: "#64748B"))
                                .padding(.horizontal, 24)
                            
                            languageGroup(languages: filteredSuggestions)
                        }
                    }
                    
                    if !filteredAll.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("All Language")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color(hex: "#64748B"))
                                .padding(.horizontal, 24)
                            
                            languageGroup(languages: filteredAll)
                        }
                    }
                }
                .padding(.top, 20)
                .padding(.bottom, 40)
            }
            .background(Color(hex: "#F8FAFC"))
        }
        .background(Color.white.ignoresSafeArea())
        .preferredColorScheme(.light)
    }
    
    @ViewBuilder
    private func languageGroup(languages: [String]) -> some View {
        VStack(spacing: 0) {
            ForEach(Array(languages.enumerated()), id: \.element) { index, lang in
                Button(action: {
                    selectedLanguage = lang
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Text(lang)
                            .font(.system(size: 16, weight: selectedLanguage == lang ? .medium : .regular))
                            .foregroundColor(selectedLanguage == lang ? Color(hex: "#2563EB") : Color(hex: "#0F172A"))
                        Spacer()
                        if selectedLanguage == lang {
                            Image(systemName: "checkmark")
                                .foregroundColor(Color(hex: "#2563EB"))
                                .font(.system(size: 16, weight: .bold))
                        }
                    }
                    .padding(.vertical, 16)
                    .padding(.horizontal, 16)
                    .contentShape(Rectangle())
                }
                
                if index < languages.count - 1 {
                    Divider()
                        .padding(.leading, 16)
                }
            }
        }
        .background(Color.white)
        .cornerRadius(16)
        .padding(.horizontal, 20)
    }
}
struct AnimatedLoadingDotsView: View {
    @State private var isAnimating = false

    var body: some View {
        HStack(spacing: 12) {
            ForEach(0..<5, id: \.self) { index in
                Circle()
                    .fill(Color(hex: "#0F172A"))
                    .frame(width: 8, height: 8)
                    .opacity(isAnimating ? 0.2 : 1.0)
                    .animation(
                        Animation.easeInOut(duration: 0.8)
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.15),
                        value: isAnimating
                    )
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}

struct VoiceTranslatorView_Previews: PreviewProvider {
    static var previews: some View {
        VoiceTranslatorView()
    }
}
