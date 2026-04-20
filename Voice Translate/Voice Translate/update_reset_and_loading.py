import re

with open("/Users/hung/Documents/VoiceTranslate/Voice Translate/Voice Translate/VoiceTranslatorView.swift", "r") as f:
    content = f.read()

# 1. Update the Reset button action
old_reset = """                if currentState == .recording {
                    Button(action: {
                        withAnimation {
                            speechManager.stopRecording()
                            recordingTime = 0
                            sourceText = ""
                            targetText = ""
                            currentState = .default
                        }
                    }) {"""

new_reset = """                if currentState == .recording {
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
                    }) {"""

content = content.replace(old_reset, new_reset)

# 2. Remove the loading effect inside the source frame
old_loading_in_source = """                if currentState == .recording {
                    // Pagination Dots
                    HStack(spacing: 6) {
                        ForEach(0..<5) { index in
                            Circle()
                                .fill(index == 0 ? Color(hex: "#2563EB") : Color(hex: "#94A3B8").opacity(0.3))
                                .frame(width: 6, height: 6)
                        }
                    }
                    Spacer()
                } else {
                    actionIconsView(text: sourceText, isSource: true)
                }"""

new_loading_in_source = """                if currentState != .recording {
                    actionIconsView(text: sourceText, isSource: true)
                }"""

content = content.replace(old_loading_in_source, new_loading_in_source)

# 3. Add the loading effect between the two text frames
old_cards_area = """    @ViewBuilder
    private var cardsArea: some View {
        VStack(alignment: .leading, spacing: 16) {
            if currentState != .hideOriginal {
                sourceCardView
            } else {
                // Free floating badge when source card is hidden
                categoryBadgeView
                    .padding(.bottom, 4)
            }
            
            targetCardView
        }
    }"""

new_cards_area = """    @ViewBuilder
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
    }"""

content = content.replace(old_cards_area, new_cards_area)

# 4. Add AnimatedLoadingDotsView at the end of the file
animated_dots_code = """
struct AnimatedLoadingDotsView: View {
    @State private var phase: CGFloat = 0

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<5) { index in
                Circle()
                    .fill(Color(hex: "#1F2937")) // Dark circle
                    .frame(width: 8, height: 8)
                    .opacity(dotOpacity(for: index))
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 1.2).repeatForever(autoreverses: true)) {
                phase = 1.0
            }
        }
    }

    private func dotOpacity(for index: Int) -> Double {
        // Calculate a trailing wave effect
        let baseOpacity = 0.2
        let maxOpacity = 1.0
        
        let normalizedIndex = Double(index) / 4.0
        
        // A simple smooth step to create the wave
        let distance = abs(normalizedIndex - Double(phase))
        
        if distance < 0.3 {
            return maxOpacity - (distance * 2)
        } else {
            return baseOpacity
        }
    }
}
"""

if "AnimatedLoadingDotsView" not in content:
    content = content + animated_dots_code

with open("/Users/hung/Documents/VoiceTranslate/Voice Translate/Voice Translate/VoiceTranslatorView.swift", "w") as f:
    f.write(content)

print("Updated Reset button logic and Loading dots animation.")
