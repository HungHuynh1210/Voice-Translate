import SwiftUI

struct SettingsView: View {
    @AppStorage("isAutoPlaybackEnabled") private var isAutoPlaybackEnabled = true
    @AppStorage("selectedIndustry") private var selectedIndustry: String = "General"
    @AppStorage("appLanguageCode") private var appLanguageCode: String = "en"
    @AppStorage("hideTabBar") private var hideTabBar = false
    @State private var showIAP = false
    
    var appLanguageDisplay: String {
        let mapping: [String: String] = [
            "en": "English", "es": "Español", "de": "Deutsch",
            "pt": "Portugués", "vi": "Tiếng Việt", "zh-Hant": "繁體中文",
            "ja": "日本語", "ko": "한국어"
        ]
        return mapping[appLanguageCode] ?? "English"
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header (Height ~76px effectively)
                HStack {
                    Image(systemName: "line.3.horizontal")
                        .font(.system(size: 24))
                        .opacity(0) // Hidden as per design
                    Spacer()
                    Text("Settings")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color(hex: "#0F172A"))
                    Spacer()
                    Image(systemName: "line.3.horizontal")
                        .opacity(0)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 16)
                .background(Color(hex: "#F0F7FA"))
                
                // Scroll Content
                ScrollView {
                    VStack(spacing: 16) {
                        
                        // Premium Banner
                        Button(action: {
                            showIAP = true
                        }) {
                            Image("Get")
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity)
                        }
                        
                        // My Industry Section
                        SettingsCard {
                            SettingsRow(
                                iconName: "icon_industry",
                                title: "My Industry",
                                trailingText: selectedIndustry,
                                destination: MyIndustryView()
                            )
                        }
                        
                        // Features Section
                        SettingsCard {
                            SettingsRow(
                                iconName: "icon_voice_clone",
                                title: "Voice Clone",
                                trailingText: "Start New",
                                destination: VoiceCloningFlowView()
                            )
                            
                            CustomDivider()
                            
                            // Auto Playback Row (Custom toggle layout)
                            HStack(spacing: 16) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color(hex: "#DBEAFE").opacity(0.6))
                                        .frame(width: 48, height: 48)
                                    Image("icon_auto_playback")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 24, height: 24)
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Text("Auto Playback")
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(Color(hex: "#0F172A"))
                                        Spacer()
                                        
                                        // Custom Toggle
                                        Button(action: {
                                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                isAutoPlaybackEnabled.toggle()
                                            }
                                        }) {
                                            ZStack(alignment: isAutoPlaybackEnabled ? .trailing : .leading) {
                                                Capsule()
                                                    .fill(isAutoPlaybackEnabled ? Color(hex: "#3b82f6") : Color(hex: "#e2e8f0"))
                                                    .frame(width: 48, height: 24)
                                                
                                                ZStack {
                                                    Circle()
                                                        .fill(isAutoPlaybackEnabled ? Color(hex: "#0069f2") : Color.white)
                                                        .frame(width: 32, height: 32)
                                                        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                                                    
                                                    if isAutoPlaybackEnabled {
                                                        Image("icon_toggle_check")
                                                            .resizable()
                                                            .aspectRatio(contentMode: .fit)
                                                            .frame(width: 24, height: 24)
                                                    }
                                                }
                                                .offset(x: isAutoPlaybackEnabled ? 4 : -4)
                                            }
                                            .frame(width: 48, height: 24)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                        .padding(.trailing, 4) // extra padding to account for the thumb overhang
                                    }
                                    
                                    Text("If activated, the translation will play automatically.")
                                        .font(.system(size: 13))
                                        .foregroundColor(Color(hex: "#94A3B8"))
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                            .padding(12)
                        }
                        
                        // Utility Section
                        SettingsCard {
                            SettingsRow(
                                iconName: "icon_app_language",
                                title: "App Language",
                                trailingText: appLanguageDisplay,
                                destination: AppLanguageView()
                            )
                            CustomDivider()
                            SettingsRow(iconName: "icon_user_guide", title: "User Guide", destination: UserGuideMenuView())
                            CustomDivider()
                            SettingsRow(iconName: "icon_feedback", title: "Feedback", destination: FeedbackView())
                            CustomDivider()
                            SettingsRow(iconName: "icon_share", title: "Share App", action: {
                                shareApp()
                            })
                            CustomDivider()
                            SettingsRow(iconName: "icon_about", title: "About", destination: AboutView())
                        }
                        
                        Spacer().frame(height: 100)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 48)
                }
                .background(Color(hex: "#F0F7FA"))
            }
            .background(Color(hex: "#F0F7FA").ignoresSafeArea())
            .navigationBarHidden(true)
            .showTabBar()
            .fullScreenCover(isPresented: $showIAP) {
                IAPView(
                    onDismiss: { showIAP = false },
                    onSubscribe: { showIAP = false }
                )
            }
        }
    }
    
    private func shareApp() {
        let appStoreLink = "https://apps.apple.com/app/id123456789" // Placeholder cho ID thật
        let textToShare = "Check out Voice Translator • AI Translate! The best app for real-time translation and voice cloning.\n\(appStoreLink)"
        
        let activityVC = UIActivityViewController(activityItems: [textToShare], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first(where: { $0.isKeyWindow }),
           let rootVC = window.rootViewController {
            
            // Dành riêng cho iPad để tránh bị crash
            if let popover = activityVC.popoverPresentationController {
                popover.sourceView = window
                popover.sourceRect = CGRect(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY, width: 0, height: 0)
                popover.permittedArrowDirections = []
            }
            
            rootVC.present(activityVC, animated: true, completion: nil)
        }
    }
}

// MARK: - Subcomponents

struct SettingsCard<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            content
        }
        .padding(8)
        .background(Color.white)
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

struct SettingsRow<Destination: View>: View {
    var iconName: String
    var title: String
    var trailingText: String? = nil
    var destination: Destination? = nil
    var showChevron: Bool = true
    var action: (() -> Void)? = nil
    
    var body: some View {
        Group {
            if let dest = destination {
                NavigationLink(destination: dest.hideTabBar()) {
                    rowContent
                }
            } else if let act = action {
                Button(action: act) {
                    rowContent
                }
            } else {
                Button(action: {}) {
                    rowContent
                }
            }
        }
    }
    
    var rowContent: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(hex: "#DBEAFE").opacity(0.6))
                    .frame(width: 48, height: 48)
                Image(iconName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
            }
            
            Text(LocalizedStringKey(title))
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color(hex: "#0F172A"))
                .lineLimit(1)
                .truncationMode(.tail)
            
            Spacer()
            
            if let tr = trailingText {
                Text(LocalizedStringKey(tr))
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Color(hex: "#94A3B8"))
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .frame(maxWidth: 100, alignment: .trailing)
            }
            
            if showChevron {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: "#94A3B8"))
            }
        }
        .padding(12)
    }
}

extension SettingsRow where Destination == EmptyView {
    init(iconName: String, title: String, trailingText: String? = nil, showChevron: Bool = true, action: (() -> Void)? = nil) {
        self.init(iconName: iconName, title: title, trailingText: trailingText, destination: nil, showChevron: showChevron, action: action)
    }
}

struct CustomDivider: View {
    var body: some View {
        Rectangle()
            .fill(Color(hex: "#F9FAFB"))
            .frame(height: 1)
            .padding(.horizontal, 12)
    }
}



struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}

struct SparkleShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        path.move(to: CGPoint(x: w/2, y: 0))
        path.addLine(to: CGPoint(x: w/2 + w*0.15, y: h/2 - h*0.15))
        path.addLine(to: CGPoint(x: w, y: h/2))
        path.addLine(to: CGPoint(x: w/2 + w*0.15, y: h/2 + h*0.15))
        path.addLine(to: CGPoint(x: w/2, y: h))
        path.addLine(to: CGPoint(x: w/2 - w*0.15, y: h/2 + h*0.15))
        path.addLine(to: CGPoint(x: 0, y: h/2))
        path.addLine(to: CGPoint(x: w/2 - w*0.15, y: h/2 - h*0.15))
        path.closeSubpath()
        return path
    }
}

struct DiamondShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        path.move(to: CGPoint(x: w * 0.25, y: 0))
        path.addLine(to: CGPoint(x: w * 0.75, y: 0))
        path.addLine(to: CGPoint(x: w, y: h * 0.35))
        path.addLine(to: CGPoint(x: w / 2, y: h))
        path.addLine(to: CGPoint(x: 0, y: h * 0.35))
        path.closeSubpath()
        return path
    }
}

struct DiamondFacets: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        // horizontal line
        path.move(to: CGPoint(x: 0, y: h * 0.35))
        path.addLine(to: CGPoint(x: w, y: h * 0.35))
        // Bottom facets
        path.move(to: CGPoint(x: w * 0.25, y: h * 0.35))
        path.addLine(to: CGPoint(x: w / 2, y: h))
        path.move(to: CGPoint(x: w * 0.75, y: h * 0.35))
        path.addLine(to: CGPoint(x: w / 2, y: h))
        // Top facets
        path.move(to: CGPoint(x: w * 0.25, y: h * 0.35))
        path.addLine(to: CGPoint(x: w * 0.4, y: 0))
        path.move(to: CGPoint(x: w * 0.75, y: h * 0.35))
        path.addLine(to: CGPoint(x: w * 0.6, y: 0))
        return path
    }
}
