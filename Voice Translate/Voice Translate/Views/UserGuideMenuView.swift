import SwiftUI

struct UserGuideMenuView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            Color(red: 250/255, green: 250/255, blue: 252/255).edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                headerView
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        
                        greetingView
                        
                        menuList
                        
                        supportCard
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
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
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color(red: 15/255, green: 23/255, blue: 42/255))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 15)
                }
                Spacer()
            }
        }
        .background(Color(red: 250/255, green: 250/255, blue: 252/255))
    }
    
    private var greetingView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Text("Hi There!")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Color(red: 15/255, green: 23/255, blue: 42/255))
                
                Text("👋")
                    .font(.system(size: 28))
            }
            
            Text("What can I help you with?")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color(red: 100/255, green: 116/255, blue: 139/255))
        }
        .padding(.bottom, 10)
    }
    
    private var menuList: some View {
        VStack(spacing: 0) {
            UserGuideMenuRow(
                imageName: "issues_live",
                title: "Issues Related to Live Translation",
                destination: AnyView(UserGuideLiveTranslationView())
            )
            
            Divider().background(Color(red: 226/255, green: 232/255, blue: 240/255))
            
            UserGuideMenuRow(
                imageName: "issues_headphone",
                title: "Headphone Related Issues",
                destination: AnyView(UserGuideHeadphoneView())
            )
            
            Divider().background(Color(red: 226/255, green: 232/255, blue: 240/255))
            
            UserGuideMenuRow(
                imageName: "issues_mic",
                title: "Microphone Related Issues",
                destination: AnyView(UserGuideMicrophoneView())
            )
            
            Divider().background(Color(red: 226/255, green: 232/255, blue: 240/255))
            
            UserGuideMenuRow(
                imageName: "issues_photo",
                title: "Photo Translation Related Issues",
                destination: AnyView(UserGuidePhotoTranslationView())
            )
        }
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.03), radius: 10, x: 0, y: 5)
    }
    
    private var supportCard: some View {
        VStack(spacing: 16) {
            Circle()
                .fill(Color(red: 59/255, green: 130/255, blue: 246/255)) // Blue
                .frame(width: 48, height: 48)
                .overlay(
                    Image(systemName: "envelope")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.white)
                )
            
            Text("We're here to help!")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Color(red: 15/255, green: 23/255, blue: 42/255))
            
            Text("Can't find what you're looking for? Reach out to us directly.")
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(Color(red: 100/255, green: 116/255, blue: 139/255))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 10)
            
            Button(action: {
                if let url = URL(string: "mailto:bravohk.inc.app@gmail.com") {
                    UIApplication.shared.open(url)
                }
            }) {
                Text("bravohk.inc.app@gmail.com")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color(red: 59/255, green: 130/255, blue: 246/255)) // Blue
            }
            .padding(.top, 4)
        }
        .padding(.vertical, 30)
        .frame(maxWidth: .infinity)
        .background(Color(red: 248/255, green: 250/255, blue: 252/255))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(red: 226/255, green: 232/255, blue: 240/255), lineWidth: 1)
        )
    }
}

struct UserGuideMenuRow: View {
    let imageName: String
    let title: String
    let destination: AnyView
    
    var body: some View {
        NavigationLink(destination: destination) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(red: 241/255, green: 245/255, blue: 249/255))
                        .frame(width: 44, height: 44)
                    
                    Image(imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                }
                
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color(red: 15/255, green: 23/255, blue: 42/255))
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(red: 148/255, green: 163/255, blue: 184/255))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(Color.white)
        }
    }
}
