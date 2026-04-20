import re

file_path = "/Users/hung/Documents/VoiceTranslate/Voice Translate/Voice Translate/ImageTranslationResultView.swift"
with open(file_path, "r") as f:
    content = f.read()

# 1. Update Layout (remove tabs, add unified view)
old_body = """            VStack(spacing: 0) {
                header

                languagePill
                    .padding(.top, 16)
                    .padding(.bottom, 16)

                // Tab Switcher
                tabSwitcher
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)

                ScrollView(showsIndicators: false) {
                    if selectedTab == .translation {
                        translationContent
                    } else {
                        aiSummaryContent
                    }
                }
            }"""

new_body = """            VStack(spacing: 0) {
                header

                languageBarView
                    .padding(.top, 16)
                    .padding(.bottom, 16)

                ScrollView(showsIndicators: false) {
                    unifiedContent
                }
            }"""
content = content.replace(old_body, new_body)

# 2. Add unifiedContent
unified_content_code = """
    // MARK: - Unified Content
    private var unifiedContent: some View {
        VStack(spacing: 20) {
            if isShowingOriginal {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(24)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 120)
            } else {
                sourceCard
                unifiedTargetCard
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 120)
    }

    private var unifiedTargetCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Translation Header
            HStack {
                Image(systemName: "globe")
                    .foregroundColor(Color(hex: "#0069F2"))
                Text(targetLanguage)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(hex: "#0069F2"))
                Spacer()
                Button(action: { UIPasteboard.general.string = translatedText + "\\n\\n" + aiSummary }) {
                    Image(systemName: "doc.on.doc")
                        .foregroundColor(Color(hex: "#0069F2"))
                }
            }

            if isTranslating {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                .padding(.vertical, 10)
            } else {
                Text(translatedText)
                    .font(.system(size: 16))
                    .foregroundColor(.black)
                    .lineSpacing(6)
            }

            Divider()
                .padding(.vertical, 8)

            // AI Summary Header
            HStack {
                Image(systemName: "camera.viewfinder")
                    .foregroundColor(Color(hex: "#0069F2"))
                Text("Tổng quan về hình ảnh 1")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(hex: "#0069F2"))
                Spacer()
            }

            if isSummarizing {
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        ProgressView()
                            .scaleEffect(1.2)
                        Text("Đang phân tích hình ảnh...")
                            .font(.system(size: 13))
                            .foregroundColor(Color(hex: "#64748B"))
                    }
                    Spacer()
                }
                .padding(.vertical, 10)

            } else if let error = summaryError {
                Text(error)
                    .font(.system(size: 14))
                    .foregroundColor(.red)
                    .padding(.vertical, 8)

                Button(action: { loadAISummary() }) {
                    Text("Thử lại")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(Color(hex: "#0069F2"))
                        .cornerRadius(12)
                }

            } else if !aiSummary.isEmpty {
                FormattedSummaryView(content: aiSummary)
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
    }
"""
content = content.replace("    // MARK: - Translation Content", unified_content_code + "\n    // MARK: - Translation Content")

# 3. Add LanguageBarView (replace languagePill)
language_bar_code = """
    private var languageBarView: some View {
        HStack(spacing: 0) {
            Button(action: { isSelectingSource = true; showLanguagePicker = true }) {
                Text(sourceLanguage)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
            Button(action: {
                withAnimation(.spring()) {
                    let temp = sourceLanguage
                    sourceLanguage = targetLanguage
                    targetLanguage = temp
                    retranslate()
                }
            }) {
                Image("icon_language_swap")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 42, height: 42)
            }
            .zIndex(1)
            
            Button(action: { isSelectingSource = false; showLanguagePicker = true }) {
                Text(targetLanguage)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .frame(height: 60)
        .background(Color(hex: "#000000"))
        .cornerRadius(25)
        .overlay(
            RoundedRectangle(cornerRadius: 25)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
        .padding(.horizontal, 20)
    }
"""

pill_start = content.find("    // MARK: - Language Pill")
pill_end = content.find("    // MARK: - Bottom Bar", pill_start)
content = content[:pill_start] + language_bar_code + content[pill_end:]

# 4. Improve FormattedSummaryView bold parsing
old_parse = """    private func parsedLines() -> [ParsedLine] {
        let lines = content.components(separatedBy: .newlines)
        return lines.compactMap { raw in
            let line = raw.trimmingCharacters(in: .whitespaces)
            guard !line.isEmpty else { return nil }

            if line.hasPrefix("**") && line.hasSuffix("**") {
                let text = line.replacingOccurrences(of: "**", with: "")
                return ParsedLine(text: text, type: .title)
            } else if line.hasPrefix("Tổng quan:") {
                return ParsedLine(text: line, type: .overview)
            } else if line.hasPrefix("- ") || line.hasPrefix("• ") {
                let text = line
                    .replacingOccurrences(of: "^- ", with: "", options: .regularExpression)
                    .replacingOccurrences(of: "^• ", with: "", options: .regularExpression)
                return ParsedLine(text: text, type: .bullet)
            } else {
                return ParsedLine(text: line, type: .normal)
            }
        }
    }"""

new_parse = """    private func parsedLines() -> [ParsedLine] {
        let lines = content.components(separatedBy: .newlines)
        return lines.compactMap { raw in
            let line = raw.trimmingCharacters(in: .whitespaces)
            guard !line.isEmpty else { return nil }

            if line.contains("**") {
                let text = line.replacingOccurrences(of: "**", with: "").trimmingCharacters(in: .whitespaces)
                // If it was bolded in the markdown, treat it as title logic to bold it
                return ParsedLine(text: text, type: .title)
            } else if line.hasPrefix("Tổng quan:") {
                return ParsedLine(text: line, type: .overview)
            } else if line.hasPrefix("- ") || line.hasPrefix("• ") {
                let text = line
                    .replacingOccurrences(of: "^- ", with: "", options: .regularExpression)
                    .replacingOccurrences(of: "^• ", with: "", options: .regularExpression)
                return ParsedLine(text: text, type: .bullet)
            } else {
                return ParsedLine(text: line, type: .normal)
            }
        }
    }"""

content = content.replace(old_parse, new_parse)

# 5. Remove the share icon logic from header since selectedTab is gone.
old_header_share = """            Button(action: {
                let shareText = selectedTab == .translation ? translatedText : aiSummary
                let av = UIActivityViewController("""

new_header_share = """            Button(action: {
                let shareText = translatedText + "\\n\\n" + aiSummary
                let av = UIActivityViewController("""

content = content.replace(old_header_share, new_header_share)

with open(file_path, "w") as f:
    f.write(content)

print("Updated ImageTranslationResultView")
