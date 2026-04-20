import SwiftUI

struct FAQItemView<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: 10) {
                Circle()
                    .fill(Color(red: 0, green: 105/255, blue: 242/255))
                    .frame(width: 4, height: 4)
                    .padding(.top, 8)
                
                Text(title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(Color(red: 15/255, green: 23/255, blue: 42/255))
                    .multilineTextAlignment(.leading)
                    .padding(.bottom, 16)
                
                Spacer()
            }
            .padding(.top, 16)
            
            VStack(alignment: .leading, spacing: 12) {
                content
            }
            .padding(.bottom, 20)
            
            Divider()
                .background(Color(red: 226/255, green: 232/255, blue: 240/255))
        }
    }
}
