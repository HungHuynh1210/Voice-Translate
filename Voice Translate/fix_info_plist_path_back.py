with open("Voice Translate.xcodeproj/project.pbxproj", "r") as f:
    content = f.read()

content = content.replace('INFOPLIST_FILE = "Voice Translate/Info.plist";', 'INFOPLIST_FILE = "Voice Translate/AppConfig.plist";')

with open("Voice Translate.xcodeproj/project.pbxproj", "w") as f:
    f.write(content)
