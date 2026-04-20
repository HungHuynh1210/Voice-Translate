import SwiftUI

struct UserGuideLiveTranslationView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                headerView
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        
                        titleSection
                        
                        FAQItemView(title: "How do I start live translation?") {
                            howToStartLiveTranslationContent
                        }
                        
                        FAQItemView(title: "What should I do if there is a long delay and no translated sentences are loaded when starting Live Translation?") {
                            delayIssueContent
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
    }
    
    private var headerView: some View {
        ZStack {
            Text("User Guide")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(Color(red: 15/255, green: 23/255, blue: 42/255))
            
            HStack {
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color(red: 15/255, green: 23/255, blue: 42/255))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 15)
                }
                Spacer()
            }
        }
    }
    
    private var titleSection: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(red: 241/255, green: 245/255, blue: 249/255))
                    .frame(width: 44, height: 44)
                
                Image("issues_live")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
            }
            
            Text("Issues Related to Live Translation")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color(red: 15/255, green: 23/255, blue: 42/255))
        }
        .padding(.vertical, 20)
    }
    
    private var howToStartLiveTranslationContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("1. Click the **Start button** on the homepage, wait for 4-5 seconds until the Connecting state ends, then you can start speaking for Live Translation.")
            
            Image("issues_live_1")
                .resizable()
                .scaledToFit()
                .cornerRadius(16)
                .frame(maxWidth: .infinity)
            
            Text("2. It also supports **one-way interpretation** mode or tap-free dialogue mode for speakers of two different languages.")
            
            Text("3. After the Live Translation starts, you need to **pause** the translation and click the language name to switch languages. To swap the left and right languages, simply click the **double arrow**. Generally speaking, the language to the **right of the double** arrow is your mother tongue. (In the latest version, the mother tongue language has the Me logo)")
            
            Text("4. During a free conversation between the two parties, there is **no need to click**, and speech from both parties will appear in the **top and bottom sections**, and you usually only need to focus on the section showing your native languages.")
            
            Image("issues_live_2")
                .resizable()
                .scaledToFit()
                .cornerRadius(16)
                .frame(maxWidth: .infinity)
            
            Text("5. Tap **the text on the screen or the speaker** at the end of the text to play the audio of the original text and translation.")
        }
        .font(.system(size: 14, weight: .regular))
        .foregroundColor(Color(red: 71/255, green: 85/255, blue: 105/255))
        .lineSpacing(4)
    }
    
    private var delayIssueContent: some View {
        var str = try! AttributedString(markdown: "In normal network conditions, the first translation takes about **4-5 seconds**. If it takes much longer, this is usually a **network issue**. Try **switching to a different network**. If delays persist despite good connectivity, feel free to contact us through the app's feedback feature.")
        if let range = str.range(of: "network issue") {
            str[range].foregroundColor = .red
        }
        return Text(str)
            .font(.system(size: 14, weight: .regular))
            .foregroundColor(Color(red: 71/255, green: 85/255, blue: 105/255))
            .lineSpacing(4)
    }
}
