import re

with open("/Users/hung/Documents/VoiceTranslate/Voice Translate/Voice Translate/LiveCameraView.swift", "r") as f:
    content = f.read()

old_picker = """    var body: some View {
        NavigationView {
            List {
                if searchText.isEmpty {
                    Section(header: Text("Suggestion").font(.subheadline).bold()) {
                        languageRow(sourceLanguage)
                        languageRow(targetLanguage)
                    }
                }
                
                Section(header: Text("All Language").font(.subheadline).bold()) {
                    ForEach(searchResults, id: \.self) { lang in
                        languageRow(lang)
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search language")
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text(isSelectingSource ? "Translate From" : "Translate To")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color(hex: "#0F172A"))
                        .fixedSize(horizontal: true, vertical: false) // Force layout to never truncate
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Color(hex: "#0F172A"))
                            .padding(.trailing, 4)
                    }
                }
            }
        }
    }"""

new_picker = """    var body: some View {
        VStack(spacing: 0) {
            // Custom Header
            HStack {
                Text(isSelectingSource ? "Translate From" : "Translate To")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(Color(hex: "#0F172A"))
                Spacer()
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color(hex: "#0F172A"))
                        .padding(8)
                        .background(Color.clear)
                }
            }
            .padding(.top, 24)
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
            
            // Custom Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(Color(hex: "#94A3B8"))
                TextField("Search language", text: $searchText)
                    .font(.system(size: 16))
                    .foregroundColor(Color(hex: "#0F172A"))
                    .disableAutocorrection(true)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color(hex: "#E2E8F0"))
            .cornerRadius(10)
            .padding(.horizontal, 24)
            .padding(.bottom, 8)
            
            // List
            List {
                if searchText.isEmpty {
                    Section(header: Text("Suggestion").font(.subheadline).bold()) {
                        languageRow(sourceLanguage)
                        languageRow(targetLanguage)
                    }
                }
                
                Section(header: Text("All Language").font(.subheadline).bold()) {
                    ForEach(searchResults, id: \.self) { lang in
                        languageRow(lang)
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
        }
        .background(Color(hex: "#F8FAFC").ignoresSafeArea(.all)) // standard grouped list bg
    }"""

if old_picker in content:
    content = content.replace(old_picker, new_picker)
    with open("/Users/hung/Documents/VoiceTranslate/Voice Translate/Voice Translate/LiveCameraView.swift", "w") as f:
        f.write(content)
    print("Replaced successfully.")
else:
    print("Could not find the old picker target!")
