import SwiftUI
import AVFoundation
import Vision
import UIKit

struct LiveCameraView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("selectedTab") private var selectedTab = 0
    
    @Binding var sourceLanguage: String
    @Binding var targetLanguage: String
    
    @State private var showHistory = false
    @State private var showLanguagePicker = false
    @State private var isSelectingSource = true
    @State private var showResultScreen = false
    
    @ObservedObject var cameraManager: CameraManager
    
    var body: some View {
        ZStack(alignment: .top) {
            if cameraManager.isProcessing, let image = cameraManager.capturedImage {
                // Layer: Processing White Background Screen
                Color.white.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    Spacer().frame(height: 150)
                    
                    ZStack {
                        Color.black
                        
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        
                        Color.black.opacity(0.6)
                        
                        ProcessingStepsView(targetLanguage: targetLanguage)
                    }
                    .cornerRadius(24)
                    .padding(.horizontal, 20)
                    .frame(maxWidth: .infinity)
                    .frame(height: UIScreen.main.bounds.height * 0.6)
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // Independent Header for Processing Screen
                HStack {
                    Button(action: {
                        cameraManager.reset()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.black)
                            .frame(width: 44, height: 44)
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)
                .frame(width: UIScreen.main.bounds.width)
                .padding(.top, UIScreen.main.bounds.height < 800 ? 50 : 70)
                
            } else {
                // Layer 1: Filtered Camera Feed
                VStack {
                    Spacer().frame(height: 150)
                    
                    ZStack {
                        CameraPreviewRepresentable(session: cameraManager.session)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: UIScreen.main.bounds.height * 0.6)
                    .clipShape(Rectangle())
                    .overlay(
                        ZStack {
                            Rectangle()
                                .stroke(Color.white.opacity(0.6), lineWidth: 2)
                            Image(systemName: "viewfinder")
                                .font(.system(size: 60, weight: .ultraLight))
                                .foregroundColor(Color.white.opacity(0.6))
                        }
                    )
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
                // Layer 2: Header - explicitly set to screen width
                HStack {
                    // Left Back button
                    Button(action: {
                        selectedTab = 0 // Return to Main Tab
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                    }
                    
                    Spacer()
                    
                    // Center Language Pill
                    HStack(spacing: 4) {
                        Button(action: {
                            isSelectingSource = true
                            showLanguagePicker = true
                        }) {
                            Text(sourceLanguage)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(Color(hex: "#0069F2"))
                                .clipShape(Capsule())
                                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                        }
                        
                        Button(action: {
                            // Swap languages
                            let temp = sourceLanguage
                            sourceLanguage = targetLanguage
                            targetLanguage = temp
                        }) {
                            Image(systemName: "arrow.left.arrow.right")
                                .foregroundColor(Color(hex: "#0069F2"))
                                .font(.system(size: 13, weight: .bold))
                                .padding(.horizontal, 4)
                        }
                        
                        Button(action: {
                            isSelectingSource = false
                            showLanguagePicker = true
                        }) {
                            Text(targetLanguage)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(Color(hex: "#0069F2"))
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                        }
                    }
                    .padding(4)
                    .background(Color(hex: "#F2F2F2").opacity(0.85))
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(Color.white, lineWidth: 2))
                    
                    Spacer()
                    
                    // Right History/Notes icon
                    Button(action: {
                        showHistory = true
                    }) {
                        Image("camera_top_right_icon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                    }
                }
                .padding(.horizontal, 20)
                .frame(width: UIScreen.main.bounds.width) // Revert to fixed screen width constraint to fix missing side buttons
                .padding(.top, UIScreen.main.bounds.height < 800 ? 50 : 70) // Handle small notch logic
            }
        }
        .ignoresSafeArea(.all)
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $showHistory) {
            AINotesListView()
        }
        .sheet(isPresented: $showLanguagePicker) {
            CameraLanguagePicker(
                selectedLanguage: isSelectingSource ? $sourceLanguage : $targetLanguage,
                isSelectingSource: isSelectingSource,
                sourceLanguage: sourceLanguage,
                targetLanguage: targetLanguage
            )
        }
        .onChange(of: cameraManager.isProcessing) { isProcessing in
            if !isProcessing && cameraManager.capturedImage != nil && !cameraManager.translatedText.isEmpty {
                showResultScreen = true
            }
        }
        .fullScreenCover(isPresented: $showResultScreen) {
            if let image = cameraManager.capturedImage {
                ImageTranslationResultView(
                    image: image,
                    sourceLanguage: $sourceLanguage,
                    targetLanguage: $targetLanguage,
                    recognizedText: cameraManager.recognizedText,
                    translatedText: cameraManager.translatedText,
                    onRetake: {
                        cameraManager.reset()
                    }
                )
            }
        }
    }
}

struct CameraPreviewRepresentable: UIViewRepresentable {
    var session: AVCaptureSession
    
    class PreviewView: UIView {
        var previewLayer: AVCaptureVideoPreviewLayer?
        var captureSession: AVCaptureSession?
        
        override func layoutSubviews() {
            super.layoutSubviews()
            previewLayer?.frame = bounds
        }
    }
    
    func makeUIView(context: Context) -> PreviewView {
        let view = PreviewView()
        
#if targetEnvironment(simulator)
        // SILENT MOCKUP FOR SIMULATOR
        DispatchQueue.main.async {
            view.backgroundColor = UIColor(white: 0.1, alpha: 1.0)
            let mockLabel = UILabel()
            mockLabel.text = "SIMULATOR: CAMERA MOCK"
            mockLabel.textColor = .white
            mockLabel.textAlignment = .center
            mockLabel.frame = view.bounds
            mockLabel.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            view.addSubview(mockLabel)
        }
#else
        // Setup capture session for REAL DEVICES ONLY
        view.captureSession = session
        
        DispatchQueue.main.async {
            let previewLayer = AVCaptureVideoPreviewLayer(session: session)
            previewLayer.videoGravity = .resizeAspectFill
            previewLayer.frame = view.bounds
            view.layer.addSublayer(previewLayer)
            view.previewLayer = previewLayer
        }
#endif
        
        return view
    }
    
    func updateUIView(_ uiView: PreviewView, context: Context) {
        // Handle updates if necessary
    }
}

// MARK: - CameraLanguagePicker
struct CameraLanguagePicker: View {
    @Binding var selectedLanguage: String
    var isSelectingSource: Bool
    
    var sourceLanguage: String
    var targetLanguage: String
    
    @Environment(\.dismiss) var dismiss
    @State private var searchText = ""
    
    let allLanguages = [
        "English", "Vietnamese", "Spanish", "French", "Japanese", "Korean", "German", 
        "Chinese", "Hindi", "Russian", "Arabic", "Portuguese", "Italian", "Thai"
    ]
    
    var searchResults: [String] {
        if searchText.isEmpty {
            return allLanguages
        } else {
            return allLanguages.filter { $0.lowercased().contains(searchText.lowercased()) }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Custom Header
            HStack {
                Text(isSelectingSource ? "Translate From" : "Translate To")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(Color(hex: "#0F172A"))
                Spacer()
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color(hex: "#0F172A"))
                        .padding(8)
                        .background(Color.clear)
                }
            }
            .padding(.top, 24)
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
            
            // Custom Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(Color(hex: "#94A3B8"))
                TextField("Search language", text: $searchText)
                    .font(.system(size: 16))
                    .foregroundColor(Color(hex: "#0F172A"))
                    .disableAutocorrection(true)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color(hex: "#E2E8F0"))
            .cornerRadius(10)
            .padding(.horizontal, 24)
            .padding(.bottom, 8)
            
            // List
            List {
                if searchText.isEmpty {
                    Section(header: Text("Suggestion").font(.subheadline).bold()) {
                        languageRow(sourceLanguage)
                        languageRow(targetLanguage)
                    }
                }
                
                Section(header: Text("All Language").font(.subheadline).bold()) {
                    ForEach(searchResults, id: \.self) { lang in
                        languageRow(lang)
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
        }
        .background(Color(hex: "#F8FAFC").ignoresSafeArea(.all)) // standard grouped list bg
        .environment(\.colorScheme, .light)
    }
    
    private func languageRow(_ lang: String) -> some View {
        Button(action: {
            selectedLanguage = lang
            dismiss()
        }) {
            HStack {
                Text(lang)
                    .font(.system(size: 16, weight: selectedLanguage == lang ? .semibold : .regular))
                    .foregroundColor(selectedLanguage == lang ? Color(hex: "#0069F2") : Color(hex: "#0F172A"))
                Spacer()
                if selectedLanguage == lang {
                    Image(systemName: "checkmark")
                        .foregroundColor(Color(hex: "#0069F2"))
                        .font(.system(size: 16, weight: .bold))
                }
            }
        }
    }
}

// MARK: - ProcessingStepsView
struct ProcessingStepsView: View {
    var targetLanguage: String
    
    @State private var step = 0
    
    private var title1: String {
        switch targetLanguage.lowercased() {
        case "english": return "Analyzing Image"
        case "spanish": return "Analizando la imagen"
        case "french": return "Analyse de l'image"
        case "japanese": return "画像を分析中"
        case "korean": return "이미지 분석 중"
        case "chinese": return "正在分析图像"
        default: return "Đang phân tích hình ảnh"
        }
    }

    private var title2: String {
        switch targetLanguage.lowercased() {
        case "english": return "Understanding Context"
        case "spanish": return "Entendiendo el contexto"
        case "french": return "Compréhension du contexte"
        case "japanese": return "文脈を理解中"
        case "korean": return "문맥 이해 중"
        case "chinese": return "了解上下文"
        default: return "Đang hiểu ngữ cảnh"
        }
    }

    private var title3: String {
        switch targetLanguage.lowercased() {
        case "english": return "Preparing AI Translation"
        case "spanish": return "Preparando traducción IA"
        case "french": return "Préparation traduction IA"
        case "japanese": return "AI翻訳を準備中"
        case "korean": return "AI 번역 준비 중"
        case "chinese": return "准备AI翻译"
        default: return "Chuẩn bị bản dịch AI"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            loadingRow(title: title1, stepIndex: 0)
            loadingRow(title: title2, stepIndex: 1)
            loadingRow(title: title3, stepIndex: 2)
        }
        .onAppear {
            step = 0
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                withAnimation(.easeInOut(duration: 0.3)) { step = 1 }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation(.easeInOut(duration: 0.3)) { step = 2 }
                }
            }
        }
    }
    
    @ViewBuilder
    func loadingRow(title: String, stepIndex: Int) -> some View {
        HStack(spacing: 16) {
            ZStack {
                if step > stepIndex {
                    Image(systemName: "checkmark.circle")
                        .foregroundColor(.white)
                        .font(.system(size: 20, weight: .regular))
                        .transition(.scale.combined(with: .opacity))
                } else if step == stepIndex {
                    RaysSpinner(isActive: true)
                } else {
                    RaysSpinner(isActive: false)
                }
            }
            .frame(width: 24, height: 24)
            .animation(.easeInOut(duration: 0.3), value: step)
            
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(step >= stepIndex ? .white : .white.opacity(0.5))
                .animation(.easeInOut(duration: 0.3), value: step)
        }
    }
}

struct RaysSpinner: View {
    var isActive: Bool
    @State private var rotation: Double = 0
    
    var body: some View {
        Image(systemName: "rays")
            .font(.system(size: 20))
            .foregroundColor(isActive ? .white : .white.opacity(0.5))
            .rotationEffect(Angle(degrees: rotation))
            .onAppear {
                if isActive {
                    withAnimation(Animation.linear(duration: 2.0).repeatForever(autoreverses: false)) {
                        rotation = 360
                    }
                }
            }
    }
}
