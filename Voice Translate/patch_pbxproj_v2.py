import re

with open("Voice Translate.xcodeproj/project.pbxproj", "r") as f:
    content = f.read()

# Add INFOPLIST_KEY_UILaunchStoryboardName after GENERATE_INFOPLIST_FILE
content = re.sub(r'(GENERATE_INFOPLIST_FILE = YES;)', r'\1\n\t\t\t\tINFOPLIST_KEY_UILaunchStoryboardName = LaunchScreen;', content)

with open("Voice Translate.xcodeproj/project.pbxproj", "w") as f:
    f.write(content)
