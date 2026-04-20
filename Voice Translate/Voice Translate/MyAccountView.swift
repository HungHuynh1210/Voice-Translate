import SwiftUI

struct MyAccountView: View {
    @Environment(\.presentationMode) var presentationMode
    
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
                Text("My Account")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.themeMainText)
                Spacer()
                // Placeholder to balance
                Image(systemName: "chevron.left").opacity(0)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 24)
            
            // Profile Card
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.themePrimary.opacity(0.1))
                        .frame(width: 100, height: 100)
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.themePrimary)
                    
                    // Subscription Badge
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Text("PRO")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.yellow)
                                .cornerRadius(10)
                                .offset(x: -10, y: -10)
                        }
                    }
                    .frame(width: 100, height: 100)
                }
                
                VStack(spacing: 4) {
                    Text("Guest User")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.themeMainText)
                    Text("user@example.com")
                        .font(.system(size: 16))
                        .foregroundColor(.themeSecondaryText)
                }
            }
            .padding(.bottom, 40)
            
            // Actions List
            VStack(spacing: 0) {
                Button(action: {}) {
                    HStack(spacing: 16) {
                        Image(systemName: "lock.fill")
                            .foregroundColor(.themeSecondaryText)
                        Text("Change Password")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.themeMainText)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.themeSecondaryText.opacity(0.5))
                    }
                    .padding(.vertical, 16)
                    .padding(.horizontal, 20)
                }
                
                Divider()
                    .padding(.leading, 56)
                
                Button(action: {}) {
                    HStack(spacing: 16) {
                        Image(systemName: "arrow.right.square")
                            .foregroundColor(.themeSecondaryText)
                        Text("Log Out")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.themeMainText)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.themeSecondaryText.opacity(0.5))
                    }
                    .padding(.vertical, 16)
                    .padding(.horizontal, 20)
                }
                
                Divider()
                    .padding(.leading, 56)
                
                Button(action: {}) {
                    HStack(spacing: 16) {
                        Image(systemName: "trash.fill")
                            .foregroundColor(.red)
                        Text("Delete Account")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.red)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.themeSecondaryText.opacity(0.5))
                    }
                    .padding(.vertical, 16)
                    .padding(.horizontal, 20)
                }
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

struct MyAccountView_Previews: PreviewProvider {
    static var previews: some View {
        MyAccountView()
    }
}
