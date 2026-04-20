import re

with open("/Users/hung/Documents/VoiceTranslate/Voice Translate/Voice Translate/CameraTranslatorView.swift", "r") as f:
    content = f.read()

old_appear = """        .onAppear {
            hideTabBar = true
            if !hasAgreed {
                showDataProcessingOverlay = true
            }
        }
        .onDisappear {
            // Restore TabBar when leaving
            hideTabBar = false
        }"""

new_appear = """        .onAppear {
            if !hasAgreed {
                showDataProcessingOverlay = true
            }
        }"""

if old_appear in content:
    content = content.replace(old_appear, new_appear)
    with open("/Users/hung/Documents/VoiceTranslate/Voice Translate/Voice Translate/CameraTranslatorView.swift", "w") as f:
        f.write(content)
    print("CameraTranslatorView updated.")
else:
    print("Could not find old appear in CameraTranslatorView.")
