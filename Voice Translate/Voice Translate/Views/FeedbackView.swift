import SwiftUI

struct FeedbackView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State private var email: String = ""
    @State private var description: String = ""
    @State private var isSubmitting: Bool = false
    @State private var showSuccessToast: Bool = false
    
    var isFormValid: Bool {
        // Validation: email ends with @gmail.com and description length > 10
        let isEmailValid = email.lowercased().hasSuffix("@gmail.com")
        let isDescriptionValid = description.trimmingCharacters(in: .whitespacesAndNewlines).count > 10
        return isEmailValid && isDescriptionValid
    }
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 20) {
                // Header
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color(hex: "#F1F5F9"))
                                .frame(width: 36, height: 36)
                            Image(systemName: "chevron.left")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color(hex: "#0F172A"))
                        }
                    }
                    
                    Spacer()
                    
                    Text("Feedback")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color(hex: "#0F172A"))
                    
                    Spacer()
                    
                    Color.clear.frame(width: 36, height: 36) // Balance
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        
                        // Email Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Email")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Color(hex: "#0F172A"))
                            
                            TextField("", text: $email, prompt: Text("Enter your email address").foregroundColor(Color(hex: "#94A3B8")))
                                .font(.system(size: 15))
                                .foregroundColor(Color(hex: "#0F172A"))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 16)
                                .background(Color(hex: "#F1F5F9"))
                                .cornerRadius(16)
                                .autocapitalization(.none)
                                .keyboardType(.emailAddress)
                                .disableAutocorrection(true)
                        }
                        
                        // Description Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Description*")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Color(hex: "#0F172A"))
                            
                            if #available(iOS 16.0, *) {
                                TextField("", text: $description, prompt: Text("Provide details for us to better support you.\nFeature suggestions are welcomed!").foregroundColor(Color(hex: "#94A3B8")), axis: .vertical)
                                    .font(.system(size: 15))
                                    .foregroundColor(Color(hex: "#0F172A"))
                                    .lineLimit(6...12)
                                    .padding(16)
                                    .frame(minHeight: 140, alignment: .top)
                                    .background(Color(hex: "#F1F5F9"))
                                    .cornerRadius(16)
                            } else {
                                ZStack(alignment: .topLeading) {
                                    if description.isEmpty {
                                        Text("Provide details for us to better support you.\nFeature suggestions are welcomed!")
                                            .font(.system(size: 15))
                                            .foregroundColor(Color(hex: "#64748B"))
                                            .padding(16)
                                            .zIndex(1)
                                            .allowsHitTesting(false)
                                    }
                                    
                                    TextEditor(text: $description)
                                        .font(.system(size: 15))
                                        .foregroundColor(Color(hex: "#0F172A"))
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .onAppear {
                                            UITextView.appearance().backgroundColor = .clear
                                        }
                                }
                                .frame(height: 140)
                                .background(Color(hex: "#F1F5F9"))
                                .cornerRadius(16)
                            }
                        }
                        
                        // Submit Button
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
                                    Text("Submit")
                                        .font(.system(size: 18, weight: .bold))
                                    Image(systemName: "arrow.right")
                                        .font(.system(size: 16, weight: .bold))
                                }
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(isFormValid ? Color(hex: "#0069F2") : Color(hex: "#9CA3AF"))
                            .cornerRadius(16)
                            .shadow(color: isFormValid ? Color(hex: "#0069F2").opacity(0.3) : Color.clear, radius: 10, y: 4)
                        }
                        .disabled(!isFormValid || isSubmitting)
                        .padding(.top, 8)
                        
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                }
            }
            
            // Success Toast
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
        .colorScheme(.light)
        .navigationBarHidden(true)
    }
    
    private func submitFeedback() {
        // Dismiss keyboard first
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        
        isSubmitting = true
        
        // Simulate networking request delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isSubmitting = false
            withAnimation(.spring()) {
                showSuccessToast = true
            }
            
            // Hide toast and pop view back after 1.0 second duration
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation(.easeIn) {
                    showSuccessToast = false
                }
                
                // Pop back after toast animation
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
}

struct FeedbackView_Previews: PreviewProvider {
    static var previews: some View {
        FeedbackView()
    }
}
