import re

with open("Voice Translate/VoiceTranslatorView.swift", "r") as f:
    text = f.read()

# 1. Restore states
new_states = """    // New States
    @State private var currentState: TranslatorState = .default
    @State private var recordingTime: Int = 0
    @State private var isTimerPaused = false
    @State private var showEditModal = false
    @State private var editingText = ""
    @FocusState private var isEditingTextFocused: Bool
    @State private var editingField: FocusedField = .source"""

text = re.sub(r"    // New States.*?@FocusState private var focusedField: FocusedField\?", new_states, text, flags=re.DOTALL)

# 2. Add Edit Modal call overlay
overlay_str = """            // Bottom Controls Area
            VStack(spacing: 0) {
"""
new_overlay = """            // Edit Modal Overlay
            if showEditModal {
                editModalOverlay
            }

            // Bottom Controls Area
            VStack(spacing: 0) {"""
text = text.replace(overlay_str, new_overlay)

# 3. Add editModalOverlay definition before Helpers
modals_def = """    // MARK: - Modals
    
    private var editModalOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation { showEditModal = false }
                }
            
            VStack {
                Spacer()
                
                VStack(spacing: 20) {
                    HStack {
                        Button(action: { withAnimation { showEditModal = false } }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.themeSecondaryText)
                        }
                        Spacer()
                        Text("Edit Text")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.themeMainText)
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
                            withAnimation { showEditModal = false }
                        }) {
                            Image(systemName: "checkmark")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(Color(hex: "#2563EB"))
                        }
                    }
                    
                    TextEditor(text: $editingText)
                        .scrollContentBackground(.hidden)
                        .focused($isEditingTextFocused)
                        .frame(height: 150)
                        .padding(12)
                        .background(Color.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(hex: "#2563EB"), lineWidth: 1)
                        )
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(Color.black)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                isEditingTextFocused = true
                            }
                        }
                    
                    Spacer()
                }
                .padding(20)
                .frame(height: UIScreen.main.bounds.height * 0.5)
                .background(Color.white)
                .cornerRadius(24)
                .padding(.bottom, -30)
            }
            .edgesIgnoringSafeArea(.bottom)
        }
        .zIndex(2)
    }

"""
text = text.replace("    // MARK: - Helpers", modals_def + "    // MARK: - Helpers")

# 4. Remove .onChange(of: focusedField)
text = re.sub(r"        \.onChange\(of: focusedField\) \{.*?        \}\n        \.onAppear", "        .onAppear", text, flags=re.DOTALL)

# 5. Fix sourceCardView
source_old = """            TextField(currentState == .recording ? "Listening..." : "Nhập văn bản...", text: $sourceText, axis: .vertical)
                .font(.system(size: 18))
                .foregroundColor(.themeMainText)
                .focused($focusedField, equals: .source)
                .disabled(currentState == .recording)"""
source_new = """            Text(sourceText.isEmpty ? "Listening..." : sourceText)
                .font(.system(size: 18))
                .foregroundColor(.themeMainText)"""
text = text.replace(source_old, source_new)

source_on_tap_old = """        .onTapGesture {
            if currentState != .recording {
                focusedField = .source
            }
        }"""
source_on_tap_new = """        .onTapGesture {
            if currentState != .recording {
                editingField = .source
                editingText = sourceText
                withAnimation { showEditModal = true }
            }
        }"""
text = text.replace(source_on_tap_old, source_on_tap_new)

# 6. Fix targetCardView
target_old = """            TextField(currentState == .recording ? "..." : (targetText == "Translating..." ? "Translating..." : "Nhập văn bản..."), text: $targetText, axis: .vertical)
                .font(.system(size: 18))
                .foregroundColor(.themeMainText)
                .focused($focusedField, equals: .target)
                .disabled(currentState == .recording || targetText == "Translating...")"""
target_new = """            Text(targetText.isEmpty ? "..." : targetText)
                .font(.system(size: 18))
                .foregroundColor(.themeMainText)"""
text = text.replace(target_old, target_new)


target_on_tap_old = """        .onTapGesture {
            if currentState != .recording && targetText != "Translating..." {
                focusedField = .target
            }
        }"""
target_on_tap_new = """        .onTapGesture {
            if currentState != .recording && targetText != "Translating..." {
                editingField = .target
                editingText = targetText
                withAnimation { showEditModal = true }
            }
        }"""
text = text.replace(target_on_tap_old, target_on_tap_new)

# 7. Add square.and.pencil button back to actionIconsView
action_old = """            Button(action: { speakText(text) }) {"""
action_new = """            Button(action: {
                editingField = isSource ? .source : .target
                editingText = text
                withAnimation { showEditModal = true }
            }) {
                Image(systemName: "square.and.pencil")
            }
            Button(action: { speakText(text) }) {"""
text = text.replace(action_old, action_new)

# 8. Restore microphone panel non-hidden
mic_old = """                if focusedField == nil {
                    if currentState == .default {
                        defaultCategoryButton
                            .padding(.bottom, 24)
                    }
                    
                    microphonePanelView
                        .padding(.bottom, 95)
                }"""
mic_new = """                if currentState == .default {
                    defaultCategoryButton
                        .padding(.bottom, 24)
                }
                
                microphonePanelView
                    .padding(.bottom, 95)"""
text = text.replace(mic_old, mic_new)

# 9. Restore onTapGesture background
bg_old = """            Color(hex: "#F0F4FF").ignoresSafeArea() // Light blue-grey
                .onTapGesture {
                    focusedField = nil
                }"""
bg_new = """            Color(hex: "#F0F4FF").ignoresSafeArea() // Light blue-grey"""
text = text.replace(bg_old, bg_new)


with open("Voice Translate/VoiceTranslatorView.swift", "w") as f:
    f.write(text)

