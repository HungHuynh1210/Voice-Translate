import SwiftUI

struct AINotesListView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var searchText = ""
    @State private var selectedFilter: AINoteType = .all
    
    // We toggle this to test empty state vs populated list.
    @State private var showEmptyState = false
    @State private var localNotes: [AINote] = []
    
    var filteredNotes: [AINote] {
        var notes = localNotes
        
        if selectedFilter != .all {
            notes = notes.filter { $0.type == selectedFilter }
        }
        
        if !searchText.isEmpty {
            notes = notes.filter { note in
                note.title.range(of: searchText, options: [.anchored, .caseInsensitive, .diacriticInsensitive]) != nil
            }
        }
        
        return notes
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Color(red: 240/255, green: 247/255, blue: 250/255).edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                
                VStack(spacing: 0) {
                    headerView
                    
                    if showEmptyState {
                        emptyStateView
                    } else {
                        searchAndFilterView
                        
                        Text("Today")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(red: 15/255, green: 23/255, blue: 42/255))
                            .padding(.horizontal, 20)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.bottom, 8)
                        
                        List {
                            ForEach(filteredNotes) { note in
                                ZStack {
                                    NavigationLink(destination: AINoteDetailView(note: note)) {
                                        EmptyView()
                                    }
                                    .opacity(0)
                                    
                                    AINoteCardView(note: note)
                                }
                                .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        deleteNote(note)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                        }
                        .listStyle(.plain)
                        .background(Color.clear)
                        .scrollContentBackground(.hidden)
                    }
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                localNotes = AINoteMockData.mockNotes
                showEmptyState = localNotes.isEmpty
            }
        }
    }
    
    private func deleteNote(_ note: AINote) {
        if let index = localNotes.firstIndex(where: { $0.id == note.id }) {
            // Delete the image file if it exists
            if let fileName = note.imageFileName {
                let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(fileName)
                try? FileManager.default.removeItem(at: url)
            }
            
            localNotes.remove(at: index)
            AINoteMockData.mockNotes = localNotes
            AINoteMockData.saveNotes()
            
            withAnimation {
                showEmptyState = localNotes.isEmpty
            }
        }
    }
    
    private var headerView: some View {
        HStack {
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(Color(red: 15/255, green: 23/255, blue: 42/255))
            }
            
            Spacer()
            
            Text("AI Notes")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color(red: 15/255, green: 23/255, blue: 42/255))
            
            Spacer()
            
            // Placeholder for right alignment
            Image(systemName: "chevron.left")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.clear)
        }
        .padding(.horizontal, 20)
        .padding(.top, topPadding)
        .padding(.bottom, 15)
        .background(Color(red: 240/255, green: 247/255, blue: 250/255))
    }
    
    private var searchAndFilterView: some View {
        VStack(spacing: 16) {
            // Search Bar
            HStack(alignment: .center, spacing: 0) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(Color(red: 148/255, green: 163/255, blue: 184/255))
                    .padding(.trailing, 8)
                
                TextField("", text: $searchText, prompt: Text("Search in notes...").foregroundColor(Color(red: 148/255, green: 163/255, blue: 184/255)))
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color.black)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, minHeight: 60, maxHeight: 60, alignment: .leading)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.05), radius: 1, x: 0, y: 1)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .inset(by: 0.5)
                    .stroke(Color(red: 0.89, green: 0.91, blue: 0.94), lineWidth: 1)
            )
            .padding(.horizontal, 20)
            
            // Filters
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(AINoteType.allCases, id: \.self) { filterType in
                        Button(action: {
                            selectedFilter = filterType
                        }) {
                            Text(filterType.rawValue)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(selectedFilter == filterType ? .white : Color(red: 71/255, green: 85/255, blue: 105/255))
                                .padding(.horizontal, 24)
                                .padding(.vertical, 10)
                                .background(selectedFilter == filterType ? Color(red: 0, green: 105/255, blue: 242/255) : Color(red: 226/255, green: 232/255, blue: 240/255).opacity(0.6))
                                .cornerRadius(20)
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.bottom, 24)
    }
    
    private var emptyStateView: some View {
        VStack {
            Spacer()
            
            // Custom drawn folder icon mimicking the Figma one
            ZStack {
                // Background back folder flap
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(red: 226/255, green: 232/255, blue: 240/255))
                    .frame(width: 100, height: 80)
                    .offset(y: -15)
                
                // Documents inside
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.white)
                    .frame(width: 80, height: 90)
                    .rotationEffect(.degrees(-10))
                    .offset(x: -10, y: -20)
                    .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.white)
                    .frame(width: 80, height: 90)
                    .rotationEffect(.degrees(5))
                    .offset(x: 10, y: -15)
                    .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                
                // Front folder flap
                Path { path in
                    path.move(to: CGPoint(x: 0, y: 30))
                    path.addLine(to: CGPoint(x: 35, y: 30))
                    path.addLine(to: CGPoint(x: 45, y: 40))
                    path.addLine(to: CGPoint(x: 110, y: 40))
                    path.addLine(to: CGPoint(x: 105, y: 90))
                    path.addQuadCurve(to: CGPoint(x: 95, y: 100), control: CGPoint(x: 105, y: 100))
                    path.addLine(to: CGPoint(x: 10, y: 100))
                    path.addQuadCurve(to: CGPoint(x: 0, y: 90), control: CGPoint(x: 0, y: 100))
                    path.closeSubpath()
                }
                .fill(Color(red: 226/255, green: 232/255, blue: 240/255))
                .frame(width: 110, height: 100)
                .offset(y: -10)
            }
            .frame(width: 150, height: 150)
            .padding(.bottom, 20)
            
            Text("Nothing here yet. Let's\nget started!")
                .font(.system(size: 20, weight: .regular))
                .foregroundColor(Color(red: 148/255, green: 163/255, blue: 184/255))
                .multilineTextAlignment(.center)
                .lineSpacing(6)
            
            Spacer()
        }
    }
    
    // Top padding logic for safe area
    private var topPadding: CGFloat {
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        let safeAreaTop = windowScene?.windows.first?.safeAreaInsets.top ?? 20
        return safeAreaTop > 20 ? 16 : 36
    }
}

struct AINoteCardView: View {
    let note: AINote
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 15) {
                // Icon styling
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(red: 229/255, green: 240/255, blue: 255/255))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: note.type.iconName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(red: 15/255, green: 23/255, blue: 42/255))
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(note.title)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Color(red: 15/255, green: 23/255, blue: 42/255))
                        
                        Spacer()
                        
                        Text(note.relativeDateString)
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(Color(red: 148/255, green: 163/255, blue: 184/255))
                    }
                    
                    Text(displayDescription)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(Color(red: 100/255, green: 116/255, blue: 139/255))
                        .lineLimit(2)
                        .padding(.trailing, 10)
                        
                    if note.hasAISummary {
                        HStack(spacing: 4) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 12))
                                .foregroundColor(Color(red: 15/255, green: 23/255, blue: 42/255))
                            
                            Text("AI Summary")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(Color(red: 15/255, green: 23/255, blue: 42/255))
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color(red: 241/255, green: 245/255, blue: 249/255))
                        .cornerRadius(12)
                        .padding(.top, 4)
                    }
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .padding(.horizontal, 20)
    }
    
    private var displayDescription: String {
        let desc = note.description
        if let range = desc.range(of: "Translated: ") {
            return String(desc[range.upperBound...]).trimmingCharacters(in: .whitespacesAndNewlines)
        }
        if let range = desc.range(of: "Text: ") {
            return String(desc[range.upperBound...]).trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return desc
    }
}

struct AINotesListView_Previews: PreviewProvider {
    static var previews: some View {
        AINotesListView()
    }
}

struct AINoteCardView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color(red: 240/255, green: 247/255, blue: 250/255).ignoresSafeArea()
            AINoteCardView(note: AINoteMockData.mockNotes.isEmpty ? AINote(title: "Preview", description: "Desc", type: .text, dateString: "Now", hasAISummary: true) : AINoteMockData.mockNotes[0])
        }
    }
}
