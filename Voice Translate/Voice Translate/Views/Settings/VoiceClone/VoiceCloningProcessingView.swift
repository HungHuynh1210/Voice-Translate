import SwiftUI

struct VoiceCloningProcessingView: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color.themePrimary.opacity(0.1))
                    .frame(width: 200, height: 200)
                    .scaleEffect(isAnimating ? 1.2 : 0.8)
                    .opacity(isAnimating ? 0 : 1)
                    .animation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: false), value: isAnimating)
                
                Circle()
                    .fill(Color.themePrimary.opacity(0.2))
                    .frame(width: 150, height: 150)
                    .scaleEffect(isAnimating ? 1.1 : 0.9)
                    .animation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isAnimating)
                
                Image(systemName: "waveform")
                    .font(.system(size: 60))
                    .foregroundColor(.themePrimary)
            }
            .padding(.bottom, 40)
            
            Text("Analyzing your voice...")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.themeMainText)
                .padding(.bottom, 16)
            
            Text("Please wait while AI constructs your personalized audio profile. This may take a few moments.")
                .font(.system(size: 16))
                .foregroundColor(.themeSecondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
            
            NavigationLink(destination: VoiceCloningSuccessView()) {
                Text("Simulate Processing Complete")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.themeSecondaryText.opacity(0.5))
            }
            .padding(.bottom, 32)
        }
        .background(Color.themeBackgroundGray.ignoresSafeArea())
        .navigationBarHidden(true)
        .onAppear {
            isAnimating = true
        }
    }
}

struct VoiceCloningProcessingView_Previews: PreviewProvider {
    static var previews: some View {
        VoiceCloningProcessingView()
    }
}
