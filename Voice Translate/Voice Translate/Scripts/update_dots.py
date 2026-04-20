import re

with open("/Users/hung/Documents/VoiceTranslate/Voice Translate/Voice Translate/VoiceTranslatorView.swift", "r") as f:
    content = f.read()

old_view = """struct AnimatedLoadingDotsView: View {
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
}"""

new_view = """struct AnimatedLoadingDotsView: View {
    @State private var isAnimating = false

    var body: some View {
        HStack(spacing: 12) {
            ForEach(0..<5) { index in
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
}"""

content = content.replace(old_view, new_view)

with open("/Users/hung/Documents/VoiceTranslate/Voice Translate/Voice Translate/VoiceTranslatorView.swift", "w") as f:
    f.write(content)

print("Updated AnimatedLoadingDotsView")
