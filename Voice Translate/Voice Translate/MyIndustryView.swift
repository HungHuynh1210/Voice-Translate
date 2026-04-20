import SwiftUI

struct CategoryItem: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let subtitle: String
}

struct MyIndustryView: View {
    @AppStorage("selectedIndustry") private var selectedIndustry: String = "General"
    @Environment(\.presentationMode) var presentationMode
    @State private var tempSelectedIndustry: String = ""
    @State private var showFeedbackForm: Bool = false
    
    @State private var email: String = ""
    @State private var description: String = ""
    
    let categories: [CategoryItem] = [
        CategoryItem(icon: "icon_industry_general", title: "General", subtitle: "Standard terms"),
        CategoryItem(icon: "icon_industry_health", title: "Healthcare", subtitle: "Medical terms"),
        CategoryItem(icon: "icon_industry_travel", title: "Travel", subtitle: "Tourist phrases"),
        CategoryItem(icon: "icon_industry_education", title: "Education", subtitle: "Academic terms"),
        CategoryItem(icon: "icon_industry_culture", title: "Culture", subtitle: "Social norms"),
        CategoryItem(icon: "icon_industry_religion", title: "Religion", subtitle: "Spiritual terms")
    ]
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        ZStack {
            Color(hex: "#F8FAFC").edgesIgnoringSafeArea(.all) // Matches standard Settings background
            
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 12) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Personalize Your\nInterpretation")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Color(hex: "#0F172A"))
                            .lineSpacing(6)
                        
                        Text("Choose your field for more accurate\ninterpretation results.")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(Color(hex: "#64748B"))
                            .lineSpacing(4)
                    }
                    .padding(.top, 16)
                    .padding(.horizontal, 24)
                    
                    // Grid
                    VStack(spacing: 12) {
                        ForEach(0..<(categories.count + 1) / 2, id: \.self) { rowIndex in
                            HStack(spacing: 16) {
                                let index1 = rowIndex * 2
                                let index2 = rowIndex * 2 + 1
                                
                                IndustryCard(
                                    category: categories[index1],
                                    isSelected: tempSelectedIndustry == categories[index1].title
                                ) { tempSelectedIndustry = categories[index1].title }
                                
                                if index2 < categories.count {
                                    IndustryCard(
                                        category: categories[index2],
                                        isSelected: tempSelectedIndustry == categories[index2].title
                                    ) { tempSelectedIndustry = categories[index2].title }
                                } else {
                                    Color.clear
                                        .frame(maxWidth: .infinity)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 8)
                }
                Spacer(minLength: 0)
                
                // Sticky Footer
                VStack(spacing: 16) {
                    // Footer Link
                    Button(action: {
                            withAnimation(.spring()) {
                                showFeedbackForm = true
                            }
                        }) {
                            Text("Can't find your field?")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Color(hex: "#0069F2"))
                                .underline()
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 32)
                        .padding(.bottom, 16)
                        
                    // Confirm Button
                    Button(action: {
                        selectedIndustry = tempSelectedIndustry
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack(spacing: 8) {
                            Text("Confirm")
                                .font(.system(size: 18, weight: .bold))
                            Image(systemName: "arrow.right")
                                .font(.system(size: 18, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color(hex: "#0069F2"))
                        .cornerRadius(16)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
                .padding(.top, 16)
                .background(Color(hex: "#F8FAFC"))
            }
            .onAppear {
                tempSelectedIndustry = selectedIndustry
            }

        }
        .sheet(isPresented: $showFeedbackForm) {
            if #available(iOS 16.4, *) {
                FeedbackFormSheet(email: $email, description: $description, showFeedbackForm: $showFeedbackForm)
                    .presentationDetents([.fraction(0.85)])
                    .presentationDragIndicator(.visible)
                    .presentationCornerRadius(24)
            } else {
                FeedbackFormSheet(email: $email, description: $description, showFeedbackForm: $showFeedbackForm)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Interpretation")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color(hex: "#0F172A"))
            }
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color(hex: "#0F172A"))
                }
            }
        }
    }
}

// Shape utility to round specific corners of the bottom sheet
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

struct IndustryCard: View {
    let category: CategoryItem
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack(alignment: .topTrailing) {
                VStack(spacing: 8) {
                    // Icon Circle
                    ZStack {
                        Circle()
                            .fill(isSelected ? Color(hex: "#0069F2") : Color(hex: "#F1F5F9"))
                            .frame(width: 48, height: 48)
                        Group {
                            if category.icon.starts(with: "icon_industry_") {
                                Image(category.icon)
                                    .renderingMode(.template)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 22, height: 22)
                            } else {
                                Image(systemName: category.icon)
                                    .font(.system(size: 20))
                            }
                        }
                        .foregroundColor(isSelected ? .white : Color(hex: "#64748B"))
                    }
                    .padding(.top, 12)
                    
                    // Text Labels
                    VStack(spacing: 2) {
                        Text(LocalizedStringKey(category.title))
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color(hex: "#0F172A"))
                        
                        Text(LocalizedStringKey(category.subtitle))
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(Color(hex: "#64748B"))
                    }
                    .padding(.bottom, 12)
                }
                .frame(maxWidth: .infinity)
                .background(isSelected ? Color(hex: "#0D7CF2").opacity(0.04) : Color.white)
                .cornerRadius(24)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(isSelected ? Color(hex: "#0069F2") : Color.clear, lineWidth: 2.4)
                )
                .shadow(color: Color(hex: "#10347D").opacity(0.06), radius: 10, y: 2)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct MyIndustryView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MyIndustryView()
        }
    }
}

struct FeedbackFormSheet: View {
    @Binding var email: String
    @Binding var description: String
    @Binding var showFeedbackForm: Bool
    
    enum Field {
        case email
        case description
    }
    @FocusState private var focusedField: Field?
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Sheet Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Tailor To Your Field")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Color(hex: "#0F172A"))
                        
                        Text("Your feedback helps us grow.")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(Color(hex: "#64748B"))
                    }
                    .padding(.top, 24)
                    
                    // Email Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Email")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(hex: "#0F172A"))
                        
                        TextField("", text: $email, prompt: Text("Enter your email address").foregroundColor(Color(hex: "#94A3B8")))
                            .focused($focusedField, equals: .email)
                            .font(.system(size: 15))
                            .foregroundColor(Color(hex: "#0F172A"))
                            .padding(.horizontal, 16)
                            .frame(height: 56)
                            .background(Color(hex: "#F8FAFC"))
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color(hex: "#E2E8F0"), lineWidth: 1)
                            )
                    }
                    
                    // Description Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description*")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(hex: "#0F172A"))
                        
                        ZStack(alignment: .topLeading) {
                            TextEditor(text: $description)
                                .focused($focusedField, equals: .description)
                                .scrollContentBackground(.hidden)
                                .font(.system(size: 15))
                                .foregroundColor(Color(hex: "#0F172A"))
                                .padding(12)
                                .frame(minHeight: 120) // using minHeight for Scrollable inside TextEditor
                                .background(Color(hex: "#F8FAFC"))
                                .cornerRadius(16)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color(hex: "#E2E8F0"), lineWidth: 1)
                                )
                            
                            if description.isEmpty {
                                Text("Please let us know how many hours of simultaneous interpretation you require daily.")
                                    .font(.system(size: 15))
                                    .foregroundColor(Color(hex: "#94A3B8"))
                                    .padding(.top, 20)
                                    .padding(.horizontal, 16)
                                    .allowsHitTesting(false)
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
            .scrollDismissesKeyboard(.interactively)
            
            // Fixed Submit Button at the bottom
            VStack {
                Button(action: {
                    focusedField = nil
                    showFeedbackForm = false
                }) {
                    Text("Submit Feedback")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color(hex: "#0069F2"))
                        .cornerRadius(28)
                        .shadow(color: Color(hex: "#0069F2").opacity(0.3), radius: 10, y: 4)
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, UIScreen.main.bounds.height < 800 ? 24 : 34) // Ensure safe area clearance
            }
            .background(Color.white)
            // Optional separator line
            .overlay(Rectangle().frame(height: 1).foregroundColor(Color(hex: "#E2E8F0")), alignment: .top)
        }
        .background(Color.white.ignoresSafeArea())
    }
}
