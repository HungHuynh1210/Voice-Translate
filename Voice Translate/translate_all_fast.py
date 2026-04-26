import json
import urllib.request
import urllib.parse
import time
from concurrent.futures import ThreadPoolExecutor, as_completed

def translate_task(item):
    text, target_lang, lang_code, key = item
    if not text.strip(): return (key, lang_code, text)
    url = f"https://translate.googleapis.com/translate_a/single?client=gtx&sl=en&tl={target_lang}&dt=t&q={urllib.parse.quote(text)}"
    req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
    for _ in range(3):
        try:
            response = urllib.request.urlopen(req)
            data = json.loads(response.read().decode('utf-8'))
            translated = ''.join([part[0] for part in data[0]])
            return (key, lang_code, translated)
        except Exception as e:
            time.sleep(1)
    return (key, lang_code, text)

file_path = "Voice Translate/App/Localizable.xcstrings"
with open(file_path, 'r') as f:
    data = json.load(f)

langs = {
    'es': 'es', 'de': 'de', 'pt': 'pt', 'vi': 'vi',
    'zh-Hant': 'zh-TW', 'ja': 'ja', 'ko': 'ko'
}

tasks = []
for key, val in data['strings'].items():
    if 'localizations' not in val:
        val['localizations'] = {}
    
    for lang_code, google_lang in langs.items():
        if lang_code not in val['localizations'] or 'stringUnit' not in val['localizations'][lang_code]:
            if key.strip() == "":
                continue
            tasks.append((key, google_lang, lang_code, key))

print(f"Total missing translations to fetch: {len(tasks)}")

count = 0
with ThreadPoolExecutor(max_workers=20) as executor:
    futures = [executor.submit(translate_task, task) for task in tasks]
    for future in as_completed(futures):
        key, lang_code, translated = future.result()
        data['strings'][key]['localizations'][lang_code] = {
            'stringUnit': {
                'state': 'translated',
                'value': translated
            }
        }
        count += 1
        if count % 50 == 0:
            print(f"Translated {count}/{len(tasks)} strings...")

with open(file_path, 'w') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)

print(f"Finished translating {count} strings!")
