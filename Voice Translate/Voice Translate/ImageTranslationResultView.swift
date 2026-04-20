import SwiftUI

struct ImageTranslationResultView: View {
    @Environment(\.dismiss) var dismiss

    // Data from the camera session
    var image: UIImage
    @Binding var sourceLanguage: String
    @Binding var targetLanguage: String
    var recognizedText: String
    @State var translatedText: String

    // Passed callback to retake/reset
    var onRetake: () -> Void

    @State private var baseTranslatedText: String = ""

    @State private var showLanguagePicker = false
    @State private var isSelectingSource = true
    @State private var isTranslating = false
    @State private var isShowingOriginal = false

    // Tab state
    @State private var selectedTab: ResultTab = .translation

    // AI Summary state
    @State private var aiSummary: String = ""
    @State private var isSummarizing = false
    @State private var summaryError: String? = nil
    @State private var navBarTitle: String = "Image Translation"

    private var textTitle: String {
        switch targetLanguage.lowercased() {
        case "english": return "Text"
        case "spanish": return "Texto"
        case "french": return "Texte"
        case "japanese": return "テキスト"
        case "korean": return "텍스트"
        case "chinese": return "文本"
        default: return "Văn bản"
        }
    }

    private var summaryTitle: String {
        switch targetLanguage.lowercased() {
        case "english": return "Image Overview 1"
        case "spanish": return "Resumen de imagen 1"
        case "french": return "Aperçu de l'image 1"
        case "japanese": return "画像の概要 1"
        case "korean": return "이미지 개요 1"
        case "chinese": return "图像概述 1"
        default: return "Tổng quan về hình ảnh 1"
        }
    }

    enum ResultTab {
        case translation, aiSummary
    }

    private var analyzingText: String {
        switch targetLanguage.lowercased() {
        case "english": return "Analyzing image..."
        case "spanish": return "Analizando la imagen..."
        case "french": return "Analyse de l'image..."
        case "japanese": return "画像を分析中..."
        case "korean": return "이미지 분석 중..."
        case "chinese": return "正在分析图像..."
        default: return "Đang phân tích hình ảnh..."
        }
    }

    var body: some View {
        ZStack(alignment: .top) {
            Color(hex: "#F2F2F2").ignoresSafeArea()

            VStack(spacing: 0) {
                header

                languageBarView
                    .padding(.top, 16)
                    .padding(.bottom, 16)

                ScrollView(showsIndicators: false) {
                    unifiedContent
                }
            }

            VStack {
                Spacer()
                bottomActionBar
            }
            .ignoresSafeArea(edges: .bottom)
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showLanguagePicker, onDismiss: {
            if selectedTab == .translation {
                retranslate()
            }
        }) {
            CameraLanguagePicker(
                selectedLanguage: isSelectingSource ? $sourceLanguage : $targetLanguage,
                isSelectingSource: isSelectingSource,
                sourceLanguage: sourceLanguage,
                targetLanguage: targetLanguage
            )
        }
        .onAppear {
            baseTranslatedText = translatedText
            // Tự động load AI Summary khi mở màn hình
            loadAISummary()
        }
    }

    // MARK: - Tab Switcher

    private var tabSwitcher: some View {
        HStack(spacing: 0) {
            Button(action: {
                selectedTab = .translation
            }) {
                Text("Translation")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(selectedTab == .translation ? .white : Color(hex: "#64748B"))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        selectedTab == .translation
                            ? Color.black
                            : Color.clear
                    )
                    .cornerRadius(20)
            }

            Button(action: {
                selectedTab = .aiSummary
                if aiSummary.isEmpty && !isSummarizing {
                    loadAISummary()
                }
            }) {
                Text("AI Summary")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(selectedTab == .aiSummary ? .white : Color(hex: "#64748B"))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        selectedTab == .aiSummary
                            ? Color.black
                            : Color.clear
                    )
                    .cornerRadius(20)
            }
        }
        .padding(4)
        .background(Color(hex: "#E2E8F0"))
        .cornerRadius(24)
    }


    // MARK: - Unified Content
    private var unifiedContent: some View {
        VStack(spacing: 20) {
            if isShowingOriginal {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(24)
            } else {
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
                Image(systemName: "doc.text")
                    .foregroundColor(.black)
                    .font(.system(size: 14, weight: .bold))
                Text(textTitle)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.black)
                Spacer()
                Button(action: { UIPasteboard.general.string = translatedText + "\n\n" + aiSummary }) {
                    Image(systemName: "doc.on.doc")
                        .foregroundColor(Color(hex: "#64748B"))
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
                FormattedSummaryView(content: translatedText)
            }

            Divider()
                .padding(.vertical, 8)

            // AI Summary Header
            HStack {
                Text("📸")
                    .font(.system(size: 14))
                Text(summaryTitle)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.black)
                Spacer()
            }

            if isSummarizing {
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        ProgressView()
                            .scaleEffect(1.2)
                        Text(analyzingText)
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

    // MARK: - Translation Content

    private var translationContent: some View {
        VStack(spacing: 20) {
            if isShowingOriginal {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(24)
            } else {
                sourceCard
                targetCard
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 120)
    }

    // MARK: - AI Summary Content

    private var aiSummaryContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header card
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("📸")
                        .font(.system(size: 14))
                    Text(summaryTitle)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.black)
                    Spacer()
                    if !aiSummary.isEmpty {
                        Button(action: {
                            UIPasteboard.general.string = aiSummary
                        }) {
                            Image(systemName: "doc.on.doc")
                                .foregroundColor(Color(hex: "#0069F2"))
                        }
                    }
                }

                if isSummarizing {
                    HStack {
                        Spacer()
                        VStack(spacing: 8) {
                            ProgressView()
                                .scaleEffect(1.2)
                            Text(analyzingText)
                                .font(.system(size: 13))
                                .foregroundColor(Color(hex: "#64748B"))
                        }
                        Spacer()
                    }
                    .padding(.vertical, 20)

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
                    // Hiển thị từng dòng đúng format
                    FormattedSummaryView(content: aiSummary)
                }
            }
            .padding(20)
            .background(Color.white)
            .cornerRadius(24)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 120)
    }

    // MARK: - Source Card (Translation tab)

    private var sourceCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "doc.text")
                    .foregroundColor(Color(hex: "#64748B"))
                Text(textTitle)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(hex: "#64748B"))
                Spacer()
                Button(action: { UIPasteboard.general.string = recognizedText }) {
                    Image(systemName: "doc.on.doc")
                        .foregroundColor(Color(hex: "#64748B"))
                }
            }

            Text(recognizedText)
                .font(.system(size: 16))
                .foregroundColor(.black)
                .lineSpacing(4)
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(24)
    }

    // MARK: - Target Card (Translation tab)

    private var targetCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "doc.text")
                    .foregroundColor(.black)
                    .font(.system(size: 14, weight: .bold))
                Text(textTitle)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.black)
                Spacer()
                Button(action: { UIPasteboard.general.string = translatedText }) {
                    Image(systemName: "doc.on.doc")
                        .foregroundColor(Color(hex: "#64748B"))
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
                FormattedSummaryView(content: translatedText)
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(24)
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            Button(action: {
                onRetake()
                dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.black)
            }

            Spacer()

            Text(navBarTitle)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.black)
                .lineLimit(1)
                
            Spacer()

            Button(action: {
                let shareText = translatedText + "\n\n" + aiSummary
                let av = UIActivityViewController(
                    activityItems: [shareText],
                    applicationActivities: nil
                )
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let rootVC = windowScene.windows.first?.rootViewController {
                    var topController = rootVC
                    while let presented = topController.presentedViewController {
                        topController = presented
                    }
                    topController.present(av, animated: true)
                }
            }) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.black)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 16)
        .background(Color.white)
    }


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
    // MARK: - Bottom Bar

    private var bottomActionBar: some View {
        HStack(spacing: 12) {
            Button(action: {
                withAnimation {
                    isShowingOriginal.toggle()
                }
            }) {
                VStack(spacing: 4) {
                    Image(systemName: isShowingOriginal ? "text.alignleft" : "doc")
                        .font(.system(size: 20))
                    Text(isShowingOriginal ? "Show text" : "Show original")
                        .font(.system(size: 12, weight: .medium))
                }
                .foregroundColor(Color(hex: "#64748B"))
                .frame(width: 80, height: 56)
                .background(Color(hex: "#F8FAFC"))
                .cornerRadius(16)
            }

            Button(action: {
                onRetake()
                dismiss()
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "camera")
                        .font(.system(size: 20))
                    Text("Scan New Image")
                        .font(.system(size: 18, weight: .bold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color(hex: "#0069F2"))
                .cornerRadius(16)
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 24)
        .padding(.bottom, 34)
        .background(Color.white)
        .cornerRadius(32, corners: [.topLeft, .topRight])
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: -5)
    }

    // MARK: - API Calls

    /// Dịch thuật — chỉ dùng cho tab Translation
    private func retranslate() {
        let textToTranslate = baseTranslatedText.isEmpty ? recognizedText : baseTranslatedText
        guard !textToTranslate.isEmpty else { return }
        isTranslating = true

        OpenAIService.shared.translate(
            text: textToTranslate,
            from: "Auto-detect",
            to: targetLanguage,
            industry: "General"
        ) { result in
            DispatchQueue.main.async {
                self.translatedText = result ?? "Không thể dịch."
                self.isTranslating = false
            }
        }
  
        // Translate AI Summary when language changes
        if !aiSummary.isEmpty {
            isSummarizing = true
            OpenAIService.shared.translate(
                text: aiSummary,
                from: "Auto-detect",
                to: targetLanguage,
                industry: "General"
            ) { summaryResult in
                DispatchQueue.main.async {
                    if let summaryResult = summaryResult {
                        self.aiSummary = summaryResult
                    }
                    self.isSummarizing = false
                }
            }
        }
    }

    /// AI Summary — chỉ dùng cho tab AI Summary
    private func loadAISummary() {
        guard !isSummarizing else { return }
        isSummarizing = true
        summaryError = nil

        Task {
            do {
                let result = try await OpenAIService.shared.summarize(image: image, targetLanguage: targetLanguage)
                DispatchQueue.main.async {
                    self.aiSummary = result.content
                    self.isSummarizing = false
                    
                    // Parse title and subtitle
                    let cleanLines = result.content.components(separatedBy: .newlines).map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
                    
                    var parsedTitle = "Image Summary"
                    var parsedSubtitle = "Captured Image Details"
                    
                    if let firstLine = cleanLines.first {
                        parsedTitle = firstLine.replacingOccurrences(of: "**", with: "")
                    }
                    
                    if cleanLines.count > 1 {
                        let overviewLine = cleanLines[1]
                        let parts = overviewLine.split(separator: ":", maxSplits: 1)
                        if parts.count == 2 {
                            parsedSubtitle = String(parts[1]).trimmingCharacters(in: .whitespaces)
                        } else {
                            parsedSubtitle = overviewLine
                        }
                    }
                    
                    // Cập nhật navibar title
                    self.navBarTitle = parsedTitle
                    
                    // Lưu note sau khi parse xong
                    AINoteMockData.addNote(
                        title: parsedTitle,
                        description: parsedSubtitle,
                        type: .image,
                        image: self.image,
                        summary: result.content
                    )
                }
            } catch {
                DispatchQueue.main.async {
                    self.summaryError = error.localizedDescription
                    self.isSummarizing = false
                }
            }
        }
    }
}

// MARK: - Formatted Summary View
/// Render đúng format **Tiêu đề**, Tổng quan, bullet points
struct FormattedSummaryView: View {
    let content: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(parsedLines(), id: \.id) { line in
                switch line.type {
                case .title:
                    Text(line.text)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.black)

                case .overview:
                    Text(line.text)
                        .font(.system(size: 15))
                        .foregroundColor(Color(hex: "#334155"))

                case .bullet:
                    HStack(alignment: .top, spacing: 8) {
                        Text("•")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(Color(hex: "#0069F2"))
                        Text(line.text)
                            .font(.system(size: 15))
                            .foregroundColor(Color(hex: "#334155"))
                    }

                case .normal:
                    Text(line.text)
                        .font(.system(size: 15))
                        .foregroundColor(Color(hex: "#334155"))
                }
            }
        }
    }

    struct ParsedLine: Identifiable {
        let id = UUID()
        let text: String
        let type: LineType
    }

    enum LineType {
        case title, overview, bullet, normal
    }

    private func parsedLines() -> [ParsedLine] {
        let lines = content.components(separatedBy: .newlines)
        var parsed = [ParsedLine]()
        var isFirstNonTitleLine = true
        
        for raw in lines {
            let line = raw.trimmingCharacters(in: .whitespaces)
            guard !line.isEmpty else { continue }
            
            if line.contains("**") {
                let text = line.replacingOccurrences(of: "**", with: "").trimmingCharacters(in: .whitespaces)
                parsed.append(ParsedLine(text: text, type: .title))
            } else if line.hasPrefix("- ") || line.hasPrefix("• ") || line.hasPrefix("* ") {
                let text = line
                    .replacingOccurrences(of: "^- ", with: "", options: .regularExpression)
                    .replacingOccurrences(of: "^• ", with: "", options: .regularExpression)
                    .replacingOccurrences(of: "^\\* ", with: "", options: .regularExpression)
                parsed.append(ParsedLine(text: text, type: .bullet))
            } else {
                // Determine if it is overview or normal
                if isFirstNonTitleLine && line.contains(":") {
                    parsed.append(ParsedLine(text: line, type: .overview))
                    isFirstNonTitleLine = false
                } else {
                    parsed.append(ParsedLine(text: line, type: .normal))
                }
            }
        }
        return parsed
    }
}
