import re

with open("Voice Translate.xcodeproj/project.pbxproj", "r") as f:
    content = f.read()

# Disable GENERATE_INFOPLIST_FILE
content = re.sub(r'GENERATE_INFOPLIST_FILE = YES;', r'GENERATE_INFOPLIST_FILE = NO;', content)

# Set INFOPLIST_FILE
content = re.sub(r'INFOPLIST_FILE = "Voice Translate/CustomInfo.plist";', r'INFOPLIST_FILE = "Voice Translate/Info.plist";', content)

with open("Voice Translate.xcodeproj/project.pbxproj", "w") as f:
    f.write(content)
