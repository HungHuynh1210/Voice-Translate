import SwiftUI

struct AboutView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.openURL) var openURL
    
    var appIcon: UIImage {
        if let icons = Bundle.main.infoDictionary?["CFBundleIcons"] as? [String: Any],
           let primaryIcon = icons["CFBundlePrimaryIcon"] as? [String: Any],
           let iconFiles = primaryIcon["CFBundleIconFiles"] as? [String],
           let lastIcon = iconFiles.last,
           let icon = UIImage(named: lastIcon) {
            return icon
        }
        return UIImage() // Fallback
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    ZStack {
                        Circle()
                            .fill(Color(hex: "#E2E8F0").opacity(0.8))
                            .frame(width: 32, height: 32)
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color(hex: "#0F172A"))
                    }
                }
                
                Spacer()
                
                Text("About")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color(hex: "#0F172A"))
                
                Spacer()
                
                Color.clear.frame(width: 32, height: 32)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 16)
            .background(Color(hex: "#F8FAFC"))
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 40) {
                    
                    // App Logo & Version
                    VStack(spacing: 12) {
                        Image(uiImage: appIcon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 22))
                            .shadow(color: Color.black.opacity(0.1), radius: 10, y: 4)
                        
                        Text("Voice Translator • AI Translate")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(hex: "#0F172A"))
                        
                        Text("V1.0")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(hex: "#94A3B8"))
                    }
                    .padding(.top, 24)
                    
                    // Contact Us
                    VStack(spacing: 0) {
                        Button(action: {
                            if let url = URL(string: "mailto:manhhung05bn@gmail.com") {
                                openURL(url)
                            }
                        }) {
                            HStack {
                                Text("Contact Us")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(Color(hex: "#0F172A"))
                                Spacer()
                                Text("manhhung05bn@gmail.com")
                                    .font(.system(size: 15))
                                    .foregroundColor(Color(hex: "#94A3B8"))
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.8)
                                    .padding(.trailing, 4)
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color(hex: "#94A3B8"))
                            }
                            .padding(16)
                        }
                    }
                    .background(Color.white)
                    .cornerRadius(16)
                    .padding(.horizontal, 20)
                    
                    // Links Card
                    VStack(spacing: 0) {
                        Button(action: {
                            if let url = URL(string: "https://sites.google.com/view/voice-translator-ai-translates/privacy-policy") {
                                openURL(url)
                            }
                        }) {
                            HStack {
                                Text("Privacy Policy")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(Color(hex: "#0F172A"))
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color(hex: "#94A3B8"))
                            }
                            .padding(16)
                        }
                        
                        Rectangle()
                            .fill(Color(hex: "#F1F5F9"))
                            .frame(height: 1)
                            .padding(.horizontal, 16)
                        
                        Button(action: {
                            if let url = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/") {
                                openURL(url)
                            }
                        }) {
                            HStack {
                                Text("Terms of Service")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(Color(hex: "#0F172A"))
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color(hex: "#94A3B8"))
                            }
                            .padding(16)
                        }
                    }
                    .background(Color.white)
                    .cornerRadius(16)
                    .padding(.horizontal, 20)
                    
                    Spacer(minLength: 40)
                }
            }
            .background(Color(hex: "#F8FAFC"))
        }
        .background(Color(hex: "#F8FAFC").ignoresSafeArea())
        .navigationBarHidden(true)
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
