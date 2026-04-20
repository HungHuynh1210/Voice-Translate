with open("/Users/hung/Documents/VoiceTranslate/Voice Translate/Voice Translate/SettingsView.swift", "r") as f:
    content = f.read()
if "hideTabBar = " in content or "hideTabBar()" in content:
    print("Found hideTabBar modification in SettingsView")
else:
    print("No hideTabBar modification in SettingsView")
