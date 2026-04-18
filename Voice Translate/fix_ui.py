import re

with open("Voice Translate/VoiceTranslatorView.swift", "r") as f:
    text = f.read()

# 1. Remove the old editModalOverlay from ZStack body
zstack_overlay = """            // Edit Modal Overlay
            if showEditModal {
                editModalOverlay
            }

"""
text = text.replace(zstack_overlay, "")

# 2. Extract editModalOverlay to a new struct and remove it from VoiceTranslatorView
# Find editModalOverlay block
overlay_block = re.search(r'    // MARK: - Modals\n\s+private var editModalOverlay: some View \{.*?\n        \}\n        \.zIndex\(2\)\n    \}', text, re.DOTALL)
if overlay_block:
    text = text.replace(overlay_block.group(0), "")

# 3. Add .sheet to VoiceTranslatorView body
sheet_mod = """        .sheet(isPresented: $showIndustryPopup) {"""
new_sheet_mod = """        .sheet(isPresented: $showEditModal) {
            EditTranslationSheet(
                editingText: $editingText,
                showEditModal: $showEditModal,
                editingField: editingField,
                sourceText: $sourceText,
                targetText: $targetText,
                sourceLanguage: sourceLanguage,
                targetLanguage: targetLanguage,
                selectedIndustry: selectedIndustry
            )
        }
        .sheet(isPresented: $showIndustryPopup) {"""
text = text.replace(sheet_mod, new_sheet_mod)

# 4. Add the EditTranslationSheet struct at the bottom
new_struct = """
struct EditTranslationSheet: View {
    @Binding var editingText: String
    @Binding var showEditModal: Bool
    var editingField: FocusedField
    @Binding var sourceText: String
    @Binding var targetText: String
    var sourceLanguage: String
    var targetLanguage: String
    var selectedIndustry: String
    
    @FocusState private var isEditingTextFocused: Bool

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                TextEditor(text: $editingText)
                    .scrollContentBackground(.hidden)
                    .focused($isEditingTextFocused)
                    .padding(12)
                    .background(Color.white)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(hex: "#2563EB"), lineWidth: 1)
                    )
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.black)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            isEditingTextFocused = true
                        }
                    }
                Spacer()
            }
            .padding(20)
            .background(Color(hex: "#F8FAFC").ignoresSafeArea())
            .navigationTitle("Edit Text")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showEditModal = false }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.themeSecondaryText)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        if editingField == .source {
                            sourceText = editingText
                            targetText = "Translating..."
                            OpenAIService.shared.translate(text: sourceText, from: sourceLanguage, to: targetLanguage, industry: selectedIndustry) { result in
                                DispatchQueue.main.async { self.targetText = result ?? "Translation failed." }
                            }
                        } else {
                            targetText = editingText
                            sourceText = "Translating..."
                            OpenAIService.shared.translate(text: targetText, from: targetLanguage, to: sourceLanguage, industry: selectedIndustry) { result in
                                DispatchQueue.main.async { self.sourceText = result ?? "Translation failed." }
                            }
                        }
                        showEditModal = false
                    }) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Color(hex: "#2563EB"))
                    }
                }
            }
        }
        .presentationDetents([.height(350), .large])
    }
}
"""

text = text.replace("struct TranslationLanguagePicker: View {", new_struct + "\nstruct TranslationLanguagePicker: View {")

with open("Voice Translate/VoiceTranslatorView.swift", "w") as f:
    f.write(text)

