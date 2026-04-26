import SwiftUI
import UIKit

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
    var onShowFeedback: (() -> Void)? = nil
    var onClose: (() -> Void)? = nil
    var isPresentedAsSheet: Bool = false
    @State private var internalShowFeedbackForm: Bool = false
    @State private var popupDragOffset: CGFloat = 0
    
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
        ZStack(alignment: .top) {
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    // Custom Header
                    if !isPresentedAsSheet {
                        HStack {
                            Button(action: {
                                presentationMode.wrappedValue.dismiss()
                            }) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(Color(hex: "#0F172A"))
                                    .frame(width: 40, height: 40)
                                    .background(Color.clear)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            Spacer()
                            
                            Text("Interpretation")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(Color(hex: "#0F172A"))
                            
                            Spacer()
                            
                            Color.clear.frame(width: 40, height: 40)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        .padding(.bottom, 8)
                    }
                    
                    VStack(alignment: .leading, spacing: 24) {
                        // Header
                        VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Personalize Your\nInterpretation")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(Color(hex: "#0F172A"))
                                .lineSpacing(6)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            Text("Choose your field for more accurate\ninterpretation results.")
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(Color(hex: "#64748B"))
                                .lineSpacing(4)
                                .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        .padding(.top, isPresentedAsSheet ? 58 : 24)
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
                    VStack(spacing: 8) {
                        // Footer Link
                        Button(action: {
                            if let onShowFeedback = onShowFeedback {
                                presentationMode.wrappedValue.dismiss()
                                onShowFeedback()
                            } else {
                                withAnimation(.spring()) { internalShowFeedbackForm = true }
                            }
                        }) {
                            Text("Can't find your field?")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(Color(hex: "#94A3B8"))
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, 16)
                            .padding(.bottom, 0)
                            
                        // Confirm Button
                        Button(action: {
                            selectedIndustry = tempSelectedIndustry
                            onClose?() ?? presentationMode.wrappedValue.dismiss()
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
                .frame(width: geometry.size.width, height: geometry.size.height)
                .onAppear {
                    tempSelectedIndustry = selectedIndustry
                }
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
            
            // Custom Drag Handle at the top of the sheet
            if isPresentedAsSheet {
                Capsule()
                    .fill(Color(hex: "#CBD5E1"))
                    .frame(width: 40, height: 5)
                    .padding(.top, 12)
            }
            

            // Custom Feedback Form Overlay
            if internalShowFeedbackForm {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        withAnimation(.spring()) { internalShowFeedbackForm = false }
                    }
                    .zIndex(102)
                
                VStack(spacing: 0) {
                    Spacer()
                    FeedbackFormContainer(showFeedbackForm: $internalShowFeedbackForm)
                        .frame(height: 480)
                        .clipShape(RoundedCorner(radius: 24, corners: [.topLeft, .topRight]))
                        .background(
                            RoundedCorner(radius: 24, corners: [.topLeft, .topRight])
                                .fill(Color.white)
                                .ignoresSafeArea(.all, edges: .bottom)
                        )
                        .offset(y: popupDragOffset)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    if value.translation.height > 0 {
                                        popupDragOffset = value.translation.height
                                    }
                                }
                                .onEnded { value in
                                    if value.translation.height > 80 {
                                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                        withAnimation(.spring()) {
                                            internalShowFeedbackForm = false
                                            popupDragOffset = 0
                                        }
                                    } else {
                                        withAnimation(.spring()) {
                                            popupDragOffset = 0
                                        }
                                    }
                                }
                        )
                }
                .zIndex(103)
                .transition(.move(edge: .bottom))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(hex: "#F8FAFC").ignoresSafeArea())
        .preferredColorScheme(.light)
        .navigationBarHidden(true)
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
                            .lineLimit(1)
                            .truncationMode(.tail)
                        
                        Text(LocalizedStringKey(category.subtitle))
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(Color(hex: "#64748B"))
                            .lineLimit(1)
                            .truncationMode(.tail)
                    }
                    .padding(.horizontal, 8)
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

struct FeedbackFormContainer: View {
    @Binding var showFeedbackForm: Bool
    @State private var email: String = ""
    @State private var description: String = ""
    
    var body: some View {
        FeedbackFormSheet(email: $email, description: $description, showFeedbackForm: $showFeedbackForm)
    }
}

struct FeedbackFormSheet: View {
    @Binding var email: String
    @Binding var description: String
    @Binding var showFeedbackForm: Bool
    
    @State private var isSubmitting: Bool = false
    @State private var showSuccessToast: Bool = false
    
    enum Field {
        case email
        case description
    }
    @FocusState private var focusedField: Field?
    
    var isFormValid: Bool {
        let isEmailValid = email.lowercased().hasSuffix("@gmail.com")
        let isDescriptionValid = description.trimmingCharacters(in: .whitespacesAndNewlines).count > 10
        return isEmailValid && isDescriptionValid
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Custom Drag Handle
                Capsule()
                    .fill(Color(hex: "#CBD5E1"))
                    .frame(width: 40, height: 5)
                    .padding(.top, 12)
                    .padding(.bottom, 4)
                    
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Sheet Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Tailor To Your Field")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Color(hex: "#0F172A"))
                        
                        Text("Your feedback helps us grow.")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(Color(hex: "#64748B"))
                    }
                    .padding(.top, 16)
                    
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
                            .frame(height: 52)
                            .background(Color(hex: "#F8FAFC"))
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color(hex: "#E2E8F0"), lineWidth: 1)
                            )
                    }
                    
                    // Description Field
                    VStack(alignment: .leading, spacing: 8) {
                        (Text("Description").foregroundColor(Color(hex: "#0F172A")) + Text("*").foregroundColor(Color(hex: "#FF0000")))
                            .font(.system(size: 14, weight: .medium))
                        
                        ZStack(alignment: .topLeading) {
                            TextEditor(text: $description)
                                .focused($focusedField, equals: .description)
                                .scrollContentBackground(.hidden)
                                .font(.system(size: 15))
                                .foregroundColor(Color(hex: "#0F172A"))
                                .padding(12)
                                .frame(minHeight: 150) // using minHeight for Scrollable inside TextEditor
                                .background(Color(hex: "#F8FAFC"))
                                .cornerRadius(16)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color(hex: "#E2E8F0"), lineWidth: 1)
                                )
                            
                            if description.isEmpty {
                                Text("Please let us know how many hours of simultaneous interpretation you require daily.")
                                    .font(.system(size: 15))
                                    .lineSpacing(6)
                                    .foregroundColor(Color(hex: "#94A3B8"))
                                    .padding(.top, 16)
                                    .padding(.horizontal, 16)
                                    .allowsHitTesting(false)
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
            .scrollDismissesKeyboard(.interactively)
            
            Spacer(minLength: 0)
            
            // Fixed Submit Button at the bottom
            VStack {
                Button(action: {
                    if isFormValid {
                        submitFeedback()
                    }
                }) {
                    HStack {
                        if isSubmitting {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Submit Feedback")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color(hex: "#0069F2").opacity(isFormValid ? 1.0 : 0.4))
                    .cornerRadius(26)
                    .shadow(color: isFormValid ? Color(hex: "#0069F2").opacity(0.3) : Color.clear, radius: 10, y: 4)
                }
                .disabled(!isFormValid || isSubmitting)
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 16)
            }
            .background(Color.white)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white.ignoresSafeArea())
            
            if showSuccessToast {
                VStack {
                    Spacer()
                    Text("Feedback sent succesfully!")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 14)
                        .background(Color.black.opacity(0.85))
                        .cornerRadius(24)
                        .padding(.bottom, 40)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .zIndex(1)
            }
        }
    }
    
    private func submitFeedback() {
        focusedField = nil
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        
        isSubmitting = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isSubmitting = false
            withAnimation(.spring()) {
                showSuccessToast = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation(.easeIn) {
                    showSuccessToast = false
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    showFeedbackForm = false
                }
            }
        }
    }
}
