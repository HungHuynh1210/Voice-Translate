import os
import re
import json

swift_files = []
for root, dirs, files in os.walk('Voice Translate/Views'):
    for file in files:
        if file.endswith('.swift'):
            swift_files.append(os.path.join(root, file))
            
for root, dirs, files in os.walk('Voice Translate/App'):
    for file in files:
        if file.endswith('.swift'):
            swift_files.append(os.path.join(root, file))

strings = set()

# Regex to find Text("...") or LocalizedStringKey("...")
text_regex = re.compile(r'(?:Text|LocalizedStringKey)\s*\(\s*"([^"]+)"')
title_regex = re.compile(r'(?:title|subtitle)\s*:\s*"([^"]+)"')

for file_path in swift_files:
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
        for match in text_regex.findall(content):
            strings.add(match.replace('\\n', '\n'))
        for match in title_regex.findall(content):
            strings.add(match.replace('\\n', '\n'))

print(f"Found {len(strings)} unique strings in code.")

xcstrings_path = "Voice Translate/App/Localizable.xcstrings"
with open(xcstrings_path, 'r') as f:
    data = json.load(f)

added = 0
for s in strings:
    if s not in data['strings']:
        data['strings'][s] = { "localizations": {} }
        added += 1

print(f"Added {added} new strings to Localizable.xcstrings")

with open(xcstrings_path, 'w') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
