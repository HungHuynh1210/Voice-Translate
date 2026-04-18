import re

file_path = "Voice Translate/VoiceTranslatorView.swift"
with open(file_path, "r") as f:
    content = f.read()

# 1. Add FocusedField enum
content = content.replace("enum TranslatorState {", "enum FocusedField {\n    case source\n    case target\n}\n\nenum TranslatorState {")

# 2. Replace States
old_states = """    // New States
    @State private var currentState: TranslatorState = .default
    @State private var recordingTime: Int = 0
    @State private var isTimerPaused = false
    @State private var showEditModal = false
    @State private var editingText = ""
    @FocusState private var isEditingTextFocused: Bool"""

new_states = """    // New States
    @State private var currentState: TranslatorState = .default
    @State private var recordingTime: Int = 0
    @State private var isTimerPaused = false
    @State private var previousFocusedField: FocusedField? = nil
    @FocusState private var focusedField: FocusedField?"""
content = content.replace(old_states, new_states)

# 3. Add onTapGesture to background and handles focus changes
old_bg = "            Color(hex: \"#F0F4FF\").ignoresSafeArea() // Light blue-grey"
new_bg = """            Color(hex: "#F0F4FF").ignoresSafeArea() // Light blue-grey
                .onTapGesture {
                    focusedField = nil
                }"""
content = content.replace(old_bg, new_bg)

# 4. Handle focus change logic 
old_on_appear = """        .onAppear {
            speechManager.requestPermission()
        }"""
new_on_appear = """        .onChange(of: focusedField) { newValue in
            if newValue != nil {
                previousFocusedField = newValue
            } else if let field = previousFocusedField {
                previousFocusedField = nil
                
                if field == .source && !sourceText.isEmpty {
                    targetText = "Translating..."
                    OpenAIService.shared.translate(text: sourceText, from: sourceLanguage, to: targetLanguage, industry: selectedIndustry) { result in
                        DispatchQueue.main.async {
                            self.targetText = result ?? "Translation failed."
                        }
                    }
                } else if field == .target && !targetText.isEmpty {
                    sourceText = "Translating..."
                    OpenAIService.shared.translate(text: targetText, from: targetLanguage, to: sourceLanguage, industry: selectedIndustry) { result in
                        DispatchQueue.main.async {
                            self.sourceText = result ?? "Translation failed."
                        }
                    }
                }
            }
        }
        .onAppear {
            speechManager.requestPermission()
        }"""
content = content.replace(old_on_appear, new_on_appear)

# 5. Hide controls when focused
old_controls = """            // Bottom Controls Area
            VStack(spacing: 0) {
                Spacer()
                
                if currentState == .default {
                    defaultCategoryButton
                        .padding(.bottom, 24)
                }
                
                microphonePanelView
                    .padding(.bottom, 95)
            }"""
new_controls = """            // Bottom Controls Area
            VStack(spacing: 0) {
                Spacer()
                
                if focusedField == nil {
                    if currentState == .default {
                        defaultCategoryButton
                            .padding(.bottom, 24)
                    }
                    
                    microphonePanelView
                        .padding(.bottom, 95)
                }
            }"""
content = content.replace(old_controls, new_controls)

# 6. Replace sourceCardView body
old_source_card = """    private var sourceCardView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                categoryBadgeView
                Spacer()
                if currentState == .result || currentState == .recording {
                    Button(action: {
                        editingText = sourceText
                        withAnimation { showEditModal = true }
                    }) {
                        Image(systemName: "arrow.up.left.and.arrow.down.right")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.themeSecondaryText)
                    }
                }
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
    }"""
new_source_card = """    private var sourceCardView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                categoryBadgeView
                Spacer()
            }
            
            TextField(currentState == .recording ? "Listening..." : "Nhập văn bản...", text: $sourceText, axis: .vertical)
                .font(.system(size: 18))
                .foregroundColor(.themeMainText)
                .focused($focusedField, equals: .source)
                .disabled(currentState == .recording)
            
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
                focusedField = .source
            }
        }
    }"""
content = content.replace(old_source_card, new_source_card)

# 7. Replace targetCardView body
old_target_card = """    private var targetCardView: some View {
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
    }"""
new_target_card = """    private var targetCardView: some View {
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
            
            TextField(currentState == .recording ? "..." : (targetText == "Translating..." ? "Translating..." : "Nhập văn bản..."), text: $targetText, axis: .vertical)
                .font(.system(size: 18))
                .foregroundColor(.themeMainText)
                .focused($focusedField, equals: .target)
                .disabled(currentState == .recording || targetText == "Translating...")
            
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
                focusedField = .target
            }
        }
    }"""
content = content.replace(old_target_card, new_target_card)

# 8. Remove editModalOverlay and action icon pencil
old_btn = """            Button(action: {
                if isSource {
                    editingText = text
                    withAnimation { showEditModal = true }
                }
            }) {
                Image(systemName: "square.and.pencil")
            }"""
content = content.replace(old_btn, "")

# 9. Remove overlay code from VoiceTranslatorView body
old_overlay = """            // Edit Modal Overlay
            if showEditModal {
                editModalOverlay
            }"""
content = content.replace(old_overlay, "")

with open(file_path, "w") as f:
    f.write(content)

