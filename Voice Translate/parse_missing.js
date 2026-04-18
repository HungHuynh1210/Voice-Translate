const fs = require('fs');
const catalog = JSON.parse(fs.readFileSync('./Voice Translate/Localizable.xcstrings', 'utf8'));

let missing = [];
for (const key of Object.keys(catalog.strings)) {
    if (!catalog.strings[key].localizations || !catalog.strings[key].localizations['vi']) {
        missing.push(key);
    }
}
console.log(JSON.stringify(missing, null, 2));
