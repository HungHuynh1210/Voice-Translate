import re

with open("/Users/hung/Documents/VoiceTranslate/Voice Translate/Voice Translate/AINoteDetailView.swift", "r") as f:
    content = f.read()

# 1. State changes
content = content.replace(
    "@State private var translatedDescription: String = \"\"",
    "@State private var translatedTitle: String = \"\"\n    @State private var translatedDescription: String = \"\""
)

# 2. onAppear changes
content = content.replace(
    """        .onAppear {
            translatedDescription = note.description
            translatedSummary = note.summaryContent
        }""",
    """        .onAppear {
            translatedTitle = note.title
            translatedDescription = note.description
            translatedSummary = note.summaryContent
        }"""
)

# 3. translateContent and localizedString
old_translate_content = """    private func translateContent(to language: String) {
        let originalDesc = note.description
        let originalSummary = note.summaryContent
        
        isTranslating = true
        
        OpenAIService.shared.translate(text: originalDesc, from: "Auto-detect", to: language, industry: "General") { translatedText in
            if let result = translatedText, !result.isEmpty {
                self.translatedDescription = result
            } else {
                self.translatedDescription = originalDesc
            }
            
            if !originalSummary.isEmpty && originalSummary != "Đang tạo tóm tắt..." {
                OpenAIService.shared.translate(text: originalSummary, from: "Auto-detect", to: language, industry: "General") { translatedSum in
                    if let res = translatedSum, !res.isEmpty {
                        self.translatedSummary = res
                    } else {
                        self.translatedSummary = originalSummary
                    }
                    self.isTranslating = false
                }
            } else {
                self.isTranslating = false
            }
        }
    }"""

new_translate_content = """    private func translateContent(to language: String) {
        let originalTitle = note.title
        let originalDesc = note.description
        let originalSummary = note.summaryContent
        
        isTranslating = true
        
        let dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        OpenAIService.shared.translate(text: originalDesc, from: "Auto-detect", to: language, industry: "General") { translatedText in
            if let result = translatedText, !result.isEmpty {
                self.translatedDescription = result
            } else {
                self.translatedDescription = originalDesc
            }
            dispatchGroup.leave()
        }
        
        if !originalSummary.isEmpty && originalSummary != "Đang tạo tóm tắt..." && originalSummary != "No AI Summary available for this note." {
            dispatchGroup.enter()
            OpenAIService.shared.translate(text: originalSummary, from: "Auto-detect", to: language, industry: "General") { translatedSum in
                if let res = translatedSum, !res.isEmpty {
                    self.translatedSummary = res
                } else {
                    self.translatedSummary = originalSummary
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.enter()
        OpenAIService.shared.translate(text: originalTitle, from: "Auto-detect", to: language, industry: "General") { translatedTitleResult in
            if let res = translatedTitleResult, !res.isEmpty {
                self.translatedTitle = res
            } else {
                self.translatedTitle = originalTitle
            }
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) {
            self.isTranslating = false
        }
    }
    
    private func localizedString(_ text: String) -> String {
        guard selectedLanguage == "Vietnamese" else { return text }
        switch text {
        case "Translation": return "Bản dịch"
        case "AI Summary": return "Tóm tắt AI"
        case "Text": return "Văn bản"
        case "Voice": return "Giọng nói"
        case "Image": return "Hình ảnh"
        case "Overview of": return "Tổng quan về"
        case "Translating...": return "Đang dịch..."
        case "Đang dịch...": return "Đang dịch..."
        case "No AI Summary available for this note.": return "Không có Tóm tắt AI nào cho bản ghi này."
        case "Display in": return "Hiển thị bằng"
        case "Please choose the main language for translation transcripts and summary": return "Vui lòng chọn ngôn ngữ chính cho bản dịch và tóm tắt"
        default: return text
        }
    }"""
content = content.replace(old_translate_content, new_translate_content)

# 4. note.title to translatedTitle
content = content.replace(
    'Text(note.title)',
    'Text(translatedTitle.isEmpty ? note.title : translatedTitle)'
)

# 5. dateString
content = content.replace(
    'Text(note.dateString)',
    'Text(note.displayDateString)'
)

# 6. Tab texts
content = content.replace(
    'Text("Translation")',
    'Text(localizedString("Translation"))'
)
content = content.replace(
    'Text("AI Summary")',
    'Text(localizedString("AI Summary"))'
)

# 7. translationContent inner texts
content = content.replace(
    'Text("Văn bản")',
    'Text(localizedString("Text"))'
)
content = content.replace(
    'Text("Tổng quan về \\(note.title)")',
    'Text("\\(localizedString("Overview of")) \\(translatedTitle.isEmpty ? note.title : translatedTitle)")'
)

content = content.replace(
    'Text(note.type.rawValue)',
    'Text(localizedString(note.type.rawValue))'
)

# 8. Translating...
content = content.replace(
    'Text("Đang dịch...")',
    'Text(localizedString("Translating..."))'
)

# 9. No AI Summary string in BulletTextFormatter
content = content.replace(
    'translatedSummary.isEmpty ? "No AI Summary available for this note." : translatedSummary',
    'translatedSummary.isEmpty ? localizedString("No AI Summary available for this note.") : translatedSummary'
)

# Replace "Đang tạo tóm tắt..." string in BulletTextFormatter if applicable
content = content.replace(
    'translatedSummary.isEmpty ? "Đang tạo tóm tắt..." : translatedSummary',
    'translatedSummary.isEmpty ? localizedString("No AI Summary available for this note.") : translatedSummary'
)

with open("/Users/hung/Documents/VoiceTranslate/Voice Translate/Voice Translate/AINoteDetailView.swift", "w") as f:
    f.write(content)
print("Done")
