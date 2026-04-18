import re

with open("Voice Translate/MyIndustryView.swift", "r") as f:
    text = f.read()

# 1. Add tempSelectedIndustry
old_states = """    @AppStorage("selectedIndustry") private var selectedIndustry: String = "General"
    @Environment(\\.presentationMode) var presentationMode
    @State private var showFeedbackForm: Bool = false"""
new_states = """    @AppStorage("selectedIndustry") private var selectedIndustry: String = "General"
    @Environment(\\.presentationMode) var presentationMode
    @State private var tempSelectedIndustry: String = ""
    @State private var showFeedbackForm: Bool = false"""
text = re.sub(r'    @AppStorage\("selectedIndustry"\) private var selectedIndustry: String = "General"\n    @Environment\(\\.presentationMode\) var presentationMode\n    @State private var showFeedbackForm: Bool = false', new_states, text)

# 2. Update Grid selection
old_grid = """                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(categories) { category in
                                IndustryCard(
                                    category: category,
                                    isSelected: selectedIndustry == category.title
                                ) {
                                    selectedIndustry = category.title
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Footer Link
                        Button(action: {"""
new_grid = """                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(categories) { category in
                                IndustryCard(
                                    category: category,
                                    isSelected: tempSelectedIndustry == category.title
                                ) {
                                    tempSelectedIndustry = category.title
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 24)
                    }
                }
                
                // Sticky Footer
                VStack(spacing: 16) {
                    // Footer Link
                    Button(action: {"""
text = text.replace(old_grid, new_grid)

# 3. Update Confirm action and adjust layout. Need to find Confirm Button
old_confirm = """                        // Confirm Button
                        Button(action: {
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
                        .padding(.horizontal, 24)
                        .padding(.bottom, 40)
                    }
                }
            }"""
new_confirm = """                    // Confirm Button
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
                .padding(.bottom, 40)
                .padding(.top, 16)
                .background(Color(hex: "#F8FAFC"))
            }
            .onAppear {
                tempSelectedIndustry = selectedIndustry
            }"""
text = text.replace(old_confirm, new_confirm)

# 4. Remove tick from IndustryCard
old_tick = """                .shadow(color: Color(hex: "#10347D").opacity(0.06), radius: 10, y: 2)
                
                // Radio/Check circle top right
                ZStack {
                    Circle()
                        .fill(isSelected ? Color(hex: "#0069F2") : Color.white)
                        .frame(width: 20, height: 20)
                        .overlay(
                            Circle()
                                .stroke(Color(hex: "#CBD5E1"), lineWidth: isSelected ? 0 : 1.5)
                        )
                    
                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .padding(10)
            }
        }
        .buttonStyle(PlainButtonStyle())"""

new_tick = """                .shadow(color: Color(hex: "#10347D").opacity(0.06), radius: 10, y: 2)
            }
        }
        .buttonStyle(PlainButtonStyle())"""
text = text.replace(old_tick, new_tick)

with open("Voice Translate/MyIndustryView.swift", "w") as f:
    f.write(text)

