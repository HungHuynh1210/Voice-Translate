import SwiftUI

struct UserGuideMicrophoneView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                headerView
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        
                        titleSection
                        
                        FAQItemView(title: "What is the function of voice cloning?\nHow to use voice cloning?") {
                            voiceCloningFunctionContent
                        }
                        
                        FAQItemView(title: "Why Does My Voice Cloning Always Fail?") {
                            voiceCloningFailContent
                        }
                        
                        FAQItemView(title: "What if my voice cloning failed multiple times and reached the limit?") {
                            voiceLimitContent
                        }
                        
                        FAQItemView(title: "The voice cloning function cloned my voice, but I can't hear my cloned voice speaking the foreign language?") {
                            voiceNotHeardContent
                        }
                        
                        FAQItemView(title: "What should I do if the cloned voice doesn't sound like mine?") {
                            voiceDoesNotSoundLikeMeContent
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
                
                Image("issues_mic")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
            }
            
            Text("Microphone Related Issues")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color(red: 15/255, green: 23/255, blue: 42/255))
        }
        .padding(.vertical, 20)
    }
    
    private var voiceCloningFunctionContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Simply record your voice for **more than 5 seconds** to clone your voice. You can enter **the voice cloning process from the voice cloning pop-up window** or the **\"Setting page > Voice clone option\"**, and follow the instructions to complete voice cloning.")
            
            noteContent
            
            Text("After successful cloning, enter the normal Live Translation process, click on the **translated text on the screen** , or the speaker at the end of the translation, **you can hear your voice speaking a foreign language!**")
            
            Image("issues_mic_1")
                .resizable()
                .scaledToFit()
                .cornerRadius(16)
                .frame(maxWidth: .infinity)
        }
        .font(.system(size: 14, weight: .regular))
        .foregroundColor(Color(red: 71/255, green: 85/255, blue: 105/255))
        .lineSpacing(4)
    }
    
    private var voiceCloningFailContent: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("When recording your voice, please ensure you:\n- Read the entire passage displayed on the screen completely.\n- Do not omit or misread more than three words.\n- Insert your own name into the paragraph as you read it.\n- Do not read any extra words that are not part of the passage on the screen.\n- Do not read too fast or too slow.")
            
            Text("\nIf it still fails, please **check you network Status and contact us by submitting feedback** on the Settings page of the APP. We are always here to help.")
        }
        .font(.system(size: 14, weight: .regular))
        .foregroundColor(Color(red: 71/255, green: 85/255, blue: 105/255))
        .lineSpacing(4)
    }
    
    private var noteContent: some View {
        Text("Note:")
            .foregroundColor(.red)
            .fontWeight(.bold)
        + Text(" ")
        + Text("When recording your voice, ensure **a quiet environment** with **clear speech** at a moderate pace for the best cloning results. After completing the voice cloning process, wait for more than 30 seconds (you can exit the app while waiting), you can check the \"Setting page > Voice Clone option\" state. If the state is ")
        + Text("\"Cloned\"")
            .foregroundColor(.green)
            .fontWeight(.bold)
        + Text(", the voice cloning is successful. If it shows ")
        + Text("\"Start new\"")
            .foregroundColor(.red)
            .fontWeight(.bold)
        + Text(", then voice cloning is unsuccessful.")
    }
    
    private var voiceLimitContent: some View {
        (Text("First, you need to go to the **Settings page > Voice clone option** to confirm the cloning status again. If it shows ")
        + Text("Cloned,")
            .foregroundColor(.green)
            .fontWeight(.bold)
        + Text(" it is a successful cloning. You can enter the Live Translation process and use your cloned voice to talk to foreign friends normally. If it still shows ")
        + Text("Start new,")
            .foregroundColor(.red)
            .fontWeight(.bold)
        + Text(" you can contact us to request additional attempts."))
            .font(.system(size: 14, weight: .regular))
            .foregroundColor(Color(red: 71/255, green: 85/255, blue: 105/255))
            .lineSpacing(4)
    }
    
    private var voiceNotHeardContent: some View {
        Text("When translating, **bilingual text** will appear on the screen. Click on the **foreign language text or click the speaker button** at the end of the foreign language sentence to hear your voice speaking the foreign language.")
            .font(.system(size: 14, weight: .regular))
            .foregroundColor(Color(red: 71/255, green: 85/255, blue: 105/255))
            .lineSpacing(4)
    }
    
    private var voiceDoesNotSoundLikeMeContent: some View {
        (Text("It is recommended that you **re-record** your voice for cloning in a **quiet environment** with **clearer and louder speech.** ")
        + Text("Background noise levels,")
            .foregroundColor(.red)
            .fontWeight(.bold)
        + Text(" your **volume , intonation and speaking speed** will all affect the effect of voice cloning."))
            .font(.system(size: 14, weight: .regular))
            .foregroundColor(Color(red: 71/255, green: 85/255, blue: 105/255))
            .lineSpacing(4)
    }
}
