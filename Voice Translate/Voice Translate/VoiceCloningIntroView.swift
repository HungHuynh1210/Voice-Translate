import SwiftUI

struct VoiceCloningIntroView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            // Header
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.themeMainText)
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            
            Spacer()
            
            // Illustration Placeholder
            Image(systemName: "waveform.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
                .foregroundColor(.themePrimary)
                .padding(.bottom, 32)
            
            // Title & Description
            Text("Personalize Your\nInterpretation")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.themeMainText)
                .multilineTextAlignment(.center)
                .padding(.bottom, 16)
            
            Text("Enable voice cloning to generate interpreted voices that sound exactly like you.")
                .font(.system(size: 16))
                .foregroundColor(.themeSecondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .padding(.bottom, 32)
            
            // Steps UI
            VStack(alignment: .leading, spacing: 24) {
                HStack(spacing: 16) {
                    Image(systemName: "1.circle.fill").foregroundColor(.themePrimary).font(.system(size: 24))
                    VStack(alignment: .leading) {
                        Text("Record a Sample").font(.system(size: 16, weight: .bold)).foregroundColor(.themeMainText)
                        Text("Read 3 short sentences aloud.").font(.system(size: 14)).foregroundColor(.themeSecondaryText)
                    }
                }
                HStack(spacing: 16) {
                    Image(systemName: "2.circle.fill").foregroundColor(.themePrimary).font(.system(size: 24))
                    VStack(alignment: .leading) {
                        Text("AI Processing").font(.system(size: 16, weight: .bold)).foregroundColor(.themeMainText)
                        Text("Our engine trains a model on your pitch.").font(.system(size: 14)).foregroundColor(.themeSecondaryText)
                    }
                }
                HStack(spacing: 16) {
                    Image(systemName: "3.circle.fill").foregroundColor(.themePrimary).font(.system(size: 24))
                    VStack(alignment: .leading) {
                        Text("Ready to Translate").font(.system(size: 16, weight: .bold)).foregroundColor(.themeMainText)
                        Text("Hear translations in your own voice!").font(.system(size: 14)).foregroundColor(.themeSecondaryText)
                    }
                }
            }
            .padding(.horizontal, 40)
            
            Spacer()
            
            // Navigation Action
            NavigationLink(destination: VoiceCloningRecordView()) {
                HStack {
                    Text("Enable Voice Cloning")
                        .font(.system(size: 18, weight: .bold))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 64)
                .background(Color.themePrimary)
                .foregroundColor(.white)
                .cornerRadius(20)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
        }
        .background(Color.themeBackgroundWhite.ignoresSafeArea())
        .navigationBarHidden(true)
    }
}

struct VoiceCloningIntroView_Previews: PreviewProvider {
    static var previews: some View {
        VoiceCloningIntroView()
    }
}
