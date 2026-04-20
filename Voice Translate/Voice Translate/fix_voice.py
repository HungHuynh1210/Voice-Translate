with open("/Users/hung/Documents/VoiceTranslate/Voice Translate/Voice Translate/VoiceTranslatorView.swift", "r") as f:
    content = f.read()

content = content.replace(".padding(.bottom, 180) // Spacing for bottom controls", ".padding(.bottom, 240) // Spacing for bottom controls")
content = content.replace("microphonePanelView\n                    .padding(.bottom, 32)", "microphonePanelView\n                    .padding(.bottom, 95)")

with open("/Users/hung/Documents/VoiceTranslate/Voice Translate/Voice Translate/VoiceTranslatorView.swift", "w") as f:
    f.write(content)
print("VoiceTranslatorView padding updated.")
