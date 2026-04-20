import SwiftUI

struct AINoteDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    
    // Provide a safe fallback if mock data is empty
    var note: AINote = AINoteMockData.mockNotes.first ?? AINote(title: "", description: "", type: .text, dateString: "", hasAISummary: false)
    
    @State private var selectedTab: Int = 0 // 0 for Translation, 1 for AI Summary
    @State private var showLanguageSheet: Bool = false
    @State private var selectedLanguage: String = "Vietnamese"
    @State private var showFullScreenImage: Bool = false
    
    @State private var translatedTitle: String = ""
    @State private var translatedDescription: String = ""
    @State private var translatedSummary: String = ""
    @State private var isTranslating: Bool = false
    
    var body: some View {
        ZStack(alignment: .top) {
            Color(red: 240/255, green: 247/255, blue: 250/255).edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                headerView
                
                languageAndDateView
                
                tabsView
                
                // Content Card
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        if selectedTab == 0 {
                            translationContent
                        } else {
                            aiSummaryContent
                        }
                    }
                    .padding(20)
                    .background(Color(red: 248/255, green: 251/255, blue: 255/255))
                    .cornerRadius(16)
                    .padding(.horizontal, 20)
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 20) // safe bottom area
                }
                
                // Feature: Hình ảnh ghim ở dưới tự động rớt sang trái và trôi xuống 1 chút
                if note.type == .image, let uiImage = note.loadImage() {
                    VStack(alignment: .leading) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 120)
                            .cornerRadius(8)
                            .clipped()
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(red: 226/255, green: 232/255, blue: 240/255), lineWidth: 1)
                            )
                            .onTapGesture {
                                showFullScreenImage = true
                            }
                    }
                    .padding(.top, 30) // Kéo hình ảnh xuống xa thân chữ ở trên hơn 1 chút
                    .padding(.bottom, 16)
                    .padding(.horizontal, 20)
                    .frame(maxWidth: .infinity, alignment: .leading) // Canh lề Left
                }
            }
        }
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $showFullScreenImage) {
            if let uiImage = note.loadImage() {
                FullScreenImageDisplayView(image: uiImage)
            }
        }
        .sheet(isPresented: $showLanguageSheet) {
            if #available(iOS 16.4, *) {
                LanguageSelectionSheet(selectedLanguage: $selectedLanguage, isPresented: $showLanguageSheet)
                    .presentationDetents([.fraction(0.35), .medium])
                    .presentationDragIndicator(.visible)
                    .presentationBackground(Color.white)
            } else {
                LanguageSelectionSheet(selectedLanguage: $selectedLanguage, isPresented: $showLanguageSheet)
                    .presentationDetents([.fraction(0.35), .medium])
                    .presentationDragIndicator(.visible)
            }
        }
        .onAppear {
            translatedTitle = note.title
            translatedDescription = note.description
            translatedSummary = note.summaryContent
        }
        .onChange(of: selectedLanguage) { newValue in
            translateContent(to: newValue)
        }
    }
    
    private func translateContent(to language: String) {
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
    }
    
    // UI Subcomponents
    
    private var headerView: some View {
        HStack {
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color(red: 15/255, green: 23/255, blue: 42/255))
            }
            
            Spacer()
            
            Text(translatedTitle.isEmpty ? note.title : translatedTitle)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(Color(red: 15/255, green: 23/255, blue: 42/255))
                .lineLimit(1)
            
            Spacer()
            
            Button(action: {
                let textToShare = selectedTab == 0 ? translatedDescription : translatedSummary
                let av = UIActivityViewController(activityItems: [textToShare], applicationActivities: nil)
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.first,
                   let rootVC = window.rootViewController {
                    var topController = rootVC
                    while let presented = topController.presentedViewController {
                        topController = presented
                    }
                    topController.present(av, animated: true)
                }
            }) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(Color(red: 0, green: 105/255, blue: 242/255))
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 15)
    }
    
    private var languageAndDateView: some View {
        HStack {
            Button(action: {
                showLanguageSheet = true
            }) {
                HStack(spacing: 8) {
                    Text(selectedLanguage)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(red: 71/255, green: 85/255, blue: 105/255))
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color(red: 148/255, green: 163/255, blue: 184/255))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.white)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(red: 226/255, green: 232/255, blue: 240/255), lineWidth: 1)
                )
            }
            
            Spacer()
            
            Text(note.displayDateString)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(Color(red: 148/255, green: 163/255, blue: 184/255))
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
    }
    
    private var tabsView: some View {
        HStack(spacing: 0) {
            Button(action: { selectedTab = 0 }) {
                Text(localizedString("Translation"))
                    .font(.system(size: 15, weight: selectedTab == 0 ? .semibold : .medium))
                    .foregroundColor(selectedTab == 0 ? Color(red: 15/255, green: 23/255, blue: 42/255) : Color(red: 100/255, green: 116/255, blue: 139/255))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(selectedTab == 0 ? Color.white : Color.clear)
                    .cornerRadius(10)
            }
            
            Button(action: { selectedTab = 1 }) {
                Text(localizedString("AI Summary"))
                    .font(.system(size: 15, weight: selectedTab == 1 ? .semibold : .medium))
                    .foregroundColor(selectedTab == 1 ? Color(red: 15/255, green: 23/255, blue: 42/255) : Color(red: 100/255, green: 116/255, blue: 139/255))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(selectedTab == 1 ? Color.white : Color.clear)
                    .cornerRadius(10)
            }
        }
        .padding(4)
        .background(Color(red: 226/255, green: 232/255, blue: 240/255).opacity(0.6))
        .cornerRadius(12)
        .padding(.horizontal, 20)
    }
    
    // Content for Translation
    private var translationContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            if note.type == .image {
                // Feature 1: Văn bản header
                HStack(spacing: 8) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(LinearGradient(gradient: Gradient(colors: [Color(red: 130/255, green: 170/255, blue: 240/255), Color(red: 90/255, green: 130/255, blue: 220/255)]), startPoint: .top, endPoint: .bottom))
                            .frame(width: 32, height: 22)
                        Text("abc")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                    }
                    Text(localizedString("Text"))
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color(red: 15/255, green: 23/255, blue: 42/255))
                }
                
                // Tiêu đề ảnh (vd: Hình ảnh 1)
                Text(translatedTitle.isEmpty ? note.title : translatedTitle)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(red: 15/255, green: 23/255, blue: 42/255))
                
                // Nội dung văn bản
                ZStack(alignment: .topLeading) {
                    BulletPointTextFormatter(text: translatedDescription.isEmpty ? note.description : translatedDescription)
                        .opacity(isTranslating ? 0 : 1)
                    
                    if isTranslating {
                        Text(localizedString("Translating..."))
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(Color(red: 15/255, green: 23/255, blue: 42/255))
                            .lineSpacing(6)
                    }
                }
                
                // Feature 2: Tổng quan header
                HStack(spacing: 8) {
                    Image(systemName: "sparkles.tv")
                        .foregroundColor(Color(red: 234/255, green: 179/255, blue: 8/255))
                    Text("\(localizedString("Overview of")) \(translatedTitle.isEmpty ? note.title : translatedTitle)")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color(red: 15/255, green: 23/255, blue: 42/255))
                }
                
                // Nội dung tổng quan
                ZStack(alignment: .topLeading) {
                    BulletPointTextFormatter(text: translatedSummary.isEmpty ? localizedString("No AI Summary available for this note.") : translatedSummary)
                        .opacity(isTranslating ? 0 : 1)
                    
                    if isTranslating {
                        Text(localizedString("Translating..."))
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(Color(red: 15/255, green: 23/255, blue: 42/255))
                            .lineSpacing(6)
                    }
                }
            } else {
                HStack(spacing: 8) {
                    Image(systemName: note.type.iconName)
                        .foregroundColor(Color(red: 100/255, green: 116/255, blue: 139/255))
                    Text(localizedString(note.type.rawValue))
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color(red: 15/255, green: 23/255, blue: 42/255))
                }
                
                Text(translatedTitle.isEmpty ? note.title : translatedTitle)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(red: 15/255, green: 23/255, blue: 42/255))
                
                ZStack(alignment: .topLeading) {
                    BulletPointTextFormatter(text: translatedDescription.isEmpty ? note.description : translatedDescription)
                        .opacity(isTranslating ? 0 : 1)
                    
                    if isTranslating {
                        Text(localizedString("Translating..."))
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(Color(red: 15/255, green: 23/255, blue: 42/255))
                            .lineSpacing(6)
                    }
                }
            }
        }
    }
    
    // Content for AI Summary
    private var aiSummaryContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "sparkles.tv")
                    .foregroundColor(Color(red: 234/255, green: 179/255, blue: 8/255)) // yellow sparkle
                Text(localizedString("AI Summary"))
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(red: 15/255, green: 23/255, blue: 42/255))
            }
            
            ZStack(alignment: .topLeading) {
                BulletPointTextFormatter(text: translatedSummary.isEmpty ? localizedString("No AI Summary available for this note.") : translatedSummary)
                    .opacity(isTranslating ? 0 : 1)
                
                if isTranslating {
                    Text(localizedString("Translating..."))
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(Color(red: 15/255, green: 23/255, blue: 42/255))
                        .lineSpacing(6)
                }
            }
        }
    }
}

// Custom Bottom Sheet for Language Selection
struct LanguageSelectionSheet: View {
    @Binding var selectedLanguage: String
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text(selectedLanguage == "Vietnamese" ? "Hiển thị bằng" : "Display in")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(Color(red: 15/255, green: 23/255, blue: 42/255))
                Spacer()
                Button(action: {
                    isPresented = false
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(Color(red: 15/255, green: 23/255, blue: 42/255))
                }
            }
            .padding(.top, 24)
            .padding(.horizontal, 24)
            
            Text(selectedLanguage == "Vietnamese" ? "Vui lòng chọn ngôn ngữ chính cho bản dịch và tóm tắt" : "Please choose the main language for translation transcripts and summary")
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(Color(red: 100/255, green: 116/255, blue: 139/255))
                .lineSpacing(4)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 24)
            
            VStack(spacing: 12) {
                LanguageOptionButton(
                    title: "English",
                    isSelected: selectedLanguage == "English",
                    action: {
                        selectedLanguage = "English"
                        isPresented = false
                    }
                )
                
                LanguageOptionButton(
                    title: "Vietnamese",
                    isSelected: selectedLanguage == "Vietnamese",
                    action: {
                        selectedLanguage = "Vietnamese"
                        isPresented = false
                    }
                )
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 30)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.white.ignoresSafeArea())
    }
}

// Full screen image viewer
struct FullScreenImageDisplayView: View {
    let image: UIImage
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
            
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white.opacity(0.8))
                            .padding()
                    }
                }
                Spacer()
            }
        }
    }
}

struct LanguageOptionButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(isSelected ? .white : Color(red: 15/255, green: 23/255, blue: 42/255))
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(isSelected ? Color(red: 0, green: 105/255, blue: 242/255) : Color(red: 241/255, green: 245/255, blue: 249/255)) // Blue if selected, light gray if not
            .cornerRadius(16)
        }
    }
}

struct BulletPointTextFormatter: View {
    let text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            let lines = text.components(separatedBy: .newlines).filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
            ForEach(lines.indices, id: \.self) { index in
                let line = lines[index].trimmingCharacters(in: .whitespaces)
                if line.hasPrefix("-") || line.hasPrefix("•") || line.hasPrefix("*") {
                    let cleanLine = line.dropFirst().trimmingCharacters(in: .whitespaces)
                    let isVietnamese = cleanLine.range(of: "[àáâãèéêìíòóôõùúýăđĩũơưÀÁÂÃÈÉÊÌÍÒÓÔÕÙÚÝĂĐĨŨƠƯ]", options: .regularExpression) != nil
                    let isGray = !isVietnamese
                    
                    HStack(alignment: .top, spacing: 12) {
                        Circle()
                            .fill(Color(red: 200/255, green: 205/255, blue: 215/255))
                            .frame(width: 4, height: 4)
                            .padding(.top, 8)
                        
                        Text(cleanLine)
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(isGray ? Color(red: 148/255, green: 163/255, blue: 184/255) : Color(red: 15/255, green: 23/255, blue: 42/255))
                            .lineSpacing(6)
                    }
                    .padding(.leading, 8)
                } else {
                    Text(line)
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(Color(red: 15/255, green: 23/255, blue: 42/255))
                        .lineSpacing(6)
                }
            }
        }
    }
}

struct AINoteDetailView_Previews: PreviewProvider {
    static var previews: some View {
        AINoteDetailView()
    }
}


