import SwiftUI

struct TextSettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var readOutEntireSentence = true
    @State private var autoClearText = false
    @State private var autoDetectLanguage = true
    
    var body: some View {
        VStack(spacing: 0) {
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
                Text("Text Settings")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.themeMainText)
                Spacer()
                Image(systemName: "chevron.left").opacity(0)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 24)
            
            // Settings Blocks
            VStack(spacing: 0) {
                // Read Out Sentence
                Toggle(isOn: $readOutEntireSentence) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Read Out the Entire Sentence")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.themeMainText)
                        Text("Automatically play the translated audio")
                            .font(.system(size: 12))
                            .foregroundColor(.themeSecondaryText)
                    }
                }
                .tint(.themePrimary)
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                
                Divider().padding(.leading, 16)
                
                // Auto Detect Language
                Toggle(isOn: $autoDetectLanguage) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Auto-Detect Language")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.themeMainText)
                        Text("Detect language from speech or photo automatically")
                            .font(.system(size: 12))
                            .foregroundColor(.themeSecondaryText)
                    }
                }
                .tint(.themePrimary)
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                
                Divider().padding(.leading, 16)
                
                // Auto Clear Text
                Toggle(isOn: $autoClearText) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Auto-clear Text")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.themeMainText)
                        Text("Clear the input box on successful translation")
                            .font(.system(size: 12))
                            .foregroundColor(.themeSecondaryText)
                    }
                }
                .tint(.themePrimary)
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
            }
            .background(Color.white)
            .cornerRadius(16)
            .padding(.horizontal, 20)
            
            Spacer()
        }
        .background(Color.themeBackgroundGray.ignoresSafeArea())
        .navigationBarHidden(true)
    }
}

struct TextSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        TextSettingsView()
    }
}
