import re

with open("Voice Translate.xcodeproj/project.pbxproj", "r") as f:
    content = f.read()

# Add INFOPLIST_FILE after GENERATE_INFOPLIST_FILE
content = re.sub(r'(GENERATE_INFOPLIST_FILE = YES;)', r'\1\n\t\t\t\tINFOPLIST_FILE = "Voice Translate/CustomInfo.plist";', content)

with open("Voice Translate.xcodeproj/project.pbxproj", "w") as f:
    f.write(content)
