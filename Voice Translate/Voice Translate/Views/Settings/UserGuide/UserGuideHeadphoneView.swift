import SwiftUI

struct UserGuideHeadphoneView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                headerView
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        
                        titleSection
                        
                        FAQItemView(title: "How do I connect my headphones?") {
                            howToConnectContent
                        }
                        
                        FAQItemView(title: "Handling method for interrupted headphone connection") {
                            handlingMethodContent
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
                
                Image("issues_headphone")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
            }
            
            Text("Headphone Related Issues")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color(red: 15/255, green: 23/255, blue: 42/255))
        }
        .padding(.vertical, 20)
    }
    
    private var howToConnectContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Here are some simple step-by-step instructions on how to use the headphone translation feature in Appname:")
            
            Text("If you are using Bluetooth earphones:").fontWeight(.bold).padding(.top, 4)
            Text("1. First, turn on Bluetooth on your phone and connect the Bluetooth earphones.\n2. Then, open the Appname application.\n3. Let the person who needs translation start speaking. After a few seconds, you will hear the translated content in the target language you choose through the earphones.")
            
            Text("If you are using wired headphones:").fontWeight(.bold).padding(.top, 4)
            Text("1. Directly insert the earphones into the **earphone jack or adapter** of your phone.\n2. Open the Appname app.\n3. Let the person who needs translation start speaking. After a few seconds, you will hear the translated content in the target language you choose through the earphones.")
            
            noteContent
        }
        .font(.system(size: 14, weight: .regular))
        .foregroundColor(Color(red: 71/255, green: 85/255, blue: 105/255))
        .lineSpacing(4)
    }
    
    private var handlingMethodContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            handlingIntroContent
            
            Text("**1. Restart your device and headphones:** This is an effective way to solve many temporary connection problems.")
            
            Text("**2. Check and update the headset firmware:** Please check the official website or support documentation of your headset manufacturer to confirm whether there is a firmware update available.")
            
            Text("**3. Check and update the device system/Bluetooth driver:** Make sure your device's operating system and Bluetooth driver are the latest version.")
            
            Text("**4. Forget the headset in Bluetooth settings:**\n\"Forget\" the headset in your device's Bluetooth settings, and then go through the pairing process again.")
            
            Text("**5. Try pairing with other devices:** Test whether the headphones are stable on other devices, which helps determine whether the problem is with the headphones themselves or the original device.")
            
            tipContent
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
        + Text("If the headset fails to connect the first time, try **closing the app completely** and reopening it to try again.")
    }
    
    private var handlingIntroContent: some View {
        Text("According to current technical analysis, the unstable connection of such headphones is usually related to the ")
        + Text("hardware device itself,")
            .foregroundColor(.red)
        + Text(" rather than the functional problem of the application. It is recommended that you try the following methods to improve connection stability:")
    }
    
    private var tipContent: some View {
        Text("Tip:")
            .foregroundColor(.green)
            .fontWeight(.bold)
        + Text(" ")
        + Text("If the problem persists, you can also contact the headset manufacturer's customer service for more professional hardware support.")
    }
}
