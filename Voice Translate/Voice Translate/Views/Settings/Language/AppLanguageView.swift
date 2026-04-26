import SwiftUI

struct AppLanguageView: View {
    @Environment(\.presentationMode) var presentationMode
    @AppStorage("appLanguageCode") private var appLanguageCode = "en"
    @AppStorage("selectedTab") private var selectedTab = 0
    @State private var pendingLanguageCode: String = "en"
    
    let languageData: [(name: String, code: String)] = [
        ("English", "en"), 
        ("Español", "es"), 
        ("Deutsch", "de"), 
        ("Portugués", "pt"), 
        ("Tiếng Việt", "vi"),
        ("繁體中文", "zh-Hant"),
        ("日本語", "ja"),
        ("한국어", "ko")
    ]
    
    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                // Header (Top: 45px, Height: ~40px)
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(Color(red: 15/255, green: 23/255, blue: 42/255))
                            .frame(width: 40, height: 40)
                    }
                    Spacer()
                    Text("Language")
                        .font(.system(size: 18, weight: .bold)) // SF Pro Display Bold
                        .foregroundColor(Color(red: 15/255, green: 23/255, blue: 42/255))
                    Spacer()
                    // Dummy for spacing
                    Color.clear.frame(width: 40, height: 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 20)
                
                // Content (Table View)
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        
                        Divider()
                            .background(Color(red: 226/255, green: 232/255, blue: 240/255))
                            .padding(.bottom, 28)
                        
                        ForEach(languageData.indices, id: \.self) { index in
                            let lang = languageData[index]
                            
                            Button(action: {
                                pendingLanguageCode = lang.code
                            }) {
                                HStack {
                                    Text(lang.name)
                                        .font(.system(size: 18, weight: .semibold)) // SF Pro Display Semibold
                                        .foregroundColor(pendingLanguageCode == lang.code ? Color(red: 0, green: 105/255, blue: 242/255) : Color(red: 15/255, green: 23/255, blue: 42/255))
                                    
                                    Spacer()
                                }
                                .padding(.horizontal, 20)
                                .contentShape(Rectangle())
                            }
                            
                            Divider()
                                .background(Color(red: 226/255, green: 232/255, blue: 240/255))
                                .padding(.top, 28)
                                .padding(.bottom, index == languageData.count - 1 ? 0 : 28)
                        }
                        
                        // Extra space at bottom to push content above floating button
                        Spacer().frame(height: 120)
                    }
                    .padding(.top, 10)
                }
            }
            
            // Absolutely Positioned Confirm Button at Bottom
            VStack {
                Spacer()
                
                VStack {
                    Button(action: {
                        selectedTab = 0
                        appLanguageCode = pendingLanguageCode
                    }) {
                        Text("Confirm")
                            .font(.system(size: 18, weight: .semibold)) // Inter Semi_Bold
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(Color(red: 20/255, green: 73/255, blue: 244/255)) // #1449f4
                            .cornerRadius(9999)
                            .shadow(color: Color(red: 0, green: 122/255, blue: 255/255, opacity: 0.3), radius: 15, x: 0, y: 7)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 34)
                    .padding(.top, 20)
                }
                .background(
                    LinearGradient(
                        colors: [Color.white.opacity(0), Color.white, Color.white],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
            .ignoresSafeArea(.all, edges: .bottom)
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            pendingLanguageCode = appLanguageCode
        }
    }
}
