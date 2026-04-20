import SwiftUI

struct VoiceCloningSuccessView: View {
    @State private var voiceName: String = "My AI Voice"
    
    var body: some View {
        VStack {
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .foregroundColor(.green)
                .padding(.bottom, 32)
            
            Text("Voice Profile Ready!")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.themeMainText)
                .padding(.bottom, 16)
            
            Text("We successfully generated a clone mimicking your pitch and tone. You can now use this voice for all your translated readings.")
                .font(.system(size: 16))
                .foregroundColor(.themeSecondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .padding(.bottom, 32)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Name your Voice Profile")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.themeSecondaryText)
                
                TextField("E.g. Professional Tone", text: $voiceName)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .foregroundColor(.themeMainText)
            }
            .padding(.horizontal, 20)
            
            Spacer()
            
            // To properly mock returning to root, we use a Navigation Link logic or a hack for now.
            // In a real app we'd pop to root using an AppState or NavigationPath parameter.
            // For UI presentation, an empty alert or just pop to root method is fine.
            Button(action: {
                // Logic to dismiss back to Settings / VoiceProfilesView
            }) {
                HStack {
                    Text("Save & Finish")
                        .font(.system(size: 18, weight: .bold))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 64)
                .background(Color.themePrimary)
                .foregroundColor(.white)
                .cornerRadius(20)
                .shadow(color: Color.themePrimary.opacity(0.3), radius: 10, x: 0, y: 4)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
        .background(Color.themeBackgroundGray.ignoresSafeArea())
        .navigationBarHidden(true)
    }
}

struct VoiceCloningSuccessView_Previews: PreviewProvider {
    static var previews: some View {
        VoiceCloningSuccessView()
    }
}
