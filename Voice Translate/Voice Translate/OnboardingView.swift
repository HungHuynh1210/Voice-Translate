import SwiftUI

struct OnboardingItem: Identifiable {
    let id = UUID()
    let imageName: String
    let title: String
    let subtitle: String
}

struct OnboardingView: View {
    @State private var currentPage = 0
    
    let items: [OnboardingItem] = [
        OnboardingItem(
            imageName: "onboarding_1",
            title: "Your Voice\nAny Language",
            subtitle: "Clone your voice and listen to it speak other languages"
        ),
        OnboardingItem(
            imageName: "onboarding_2",
            title: "Smart \nPhoto Translation",
            subtitle: "Take a picture and let AI detect and translate the text for you"
        ),
        OnboardingItem(
            imageName: "onboarding_3",
            title: "Real-Time\nTranslation",
            subtitle: "Hear real-time translations and get smart AI summaries instantly"
        )
    ]
    
    // We'll pass a closure or use a router to navigate to IAP.
    var onFinish: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $currentPage) {
                ForEach(0..<items.count, id: \.self) { index in
                    OnboardingPage(item: items[index])
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            
            // Page Indicators
            HStack(spacing: 8) {
                ForEach(0..<items.count, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 4)
                        .fill(currentPage == index ? Color(red: 30/255, green: 41/255, blue: 59/255) : Color(white: 0.85))
                        .frame(width: currentPage == index ? 46 : 10, height: 8)
                        .animation(.easeInOut(duration: 0.3), value: currentPage)
                }
            }
            .padding(.bottom, 24)
            
            // Continue Button (Always present at the bottom)
            VStack {
                Button(action: {
                    if currentPage < items.count - 1 {
                        withAnimation {
                            currentPage += 1
                        }
                    } else {
                        onFinish()
                    }
                }) {
                    ZStack {
                        Text("Continue")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                        
                        HStack {
                            Spacer()
                            Image(systemName: "arrow.right")
                                .foregroundColor(.white)
                                .font(.system(size: 16, weight: .bold))
                        }
                        .padding(.horizontal, 24)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 64)
                    .background(Color(red: 17/255, green: 17/255, blue: 17/255))
                    .cornerRadius(20)
                    .shadow(color: Color(red: 0, green: 69/255, blue: 230/255).opacity(0.25), radius: 21.4, x: 0, y: 4)
                }
                .padding(.horizontal, 20)
                
                // Small bottom bar indicator slot if needed, usually managed by system.
                Spacer().frame(height: 8)
            }
            .padding(.bottom, 16)
        }
        .background(Color.themeBackgroundWhite.ignoresSafeArea())
    }
}

struct OnboardingPage: View {
    let item: OnboardingItem
    
    var body: some View {
        VStack(spacing: 0) {
            // Top Image Area
            ZStack {
                // Placeholder background matching figma's light area
                Color(red: 247/255, green: 249/255, blue: 255/255).ignoresSafeArea(edges: .top)
                
                VStack {
                    Spacer()
                    Image(item.imageName)
                        .resizable()
                        .scaledToFit()
                        .scaleEffect(1.15)
                        .offset(y: item.imageName == "onboarding_3" ? 30 : 0)
                        .frame(maxWidth: .infinity)
                    Spacer()
                }
            }
            .frame(maxHeight: UIScreen.main.bounds.height * 0.52)
            .clipped()
            
            // Text Area
            VStack(spacing: 16) {
                Text(LocalizedStringKey(item.title))
                    .font(.system(size: UIScreen.main.bounds.height < 800 ? 32 : 36, weight: .bold))
                    .foregroundColor(Color(red: 15/255, green: 23/255, blue: 42/255))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                
                Text(LocalizedStringKey(item.subtitle))
                    .font(.system(size: UIScreen.main.bounds.height < 800 ? 16 : 18, weight: .medium))
                    .foregroundColor(Color(red: 17/255, green: 24/255, blue: 39/255).opacity(0.6))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 32)
            }
            .padding(.top, UIScreen.main.bounds.height < 800 ? 24 : 40)
            
            Spacer()
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(onFinish: {})
    }
}
