import SwiftUI

/// Immersive reading experience with beautiful typography
struct ReaderView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var bookManager: BookManager
    @Environment(\.dismiss) private var dismiss
    
    let book: Book
    
    @State private var currentChapter: Int = 0
    @State private var showControls = true
    @State private var showSettings = false
    @State private var scrollOffset: CGFloat = 0
    @State private var chapters: [Chapter] = []
    @State private var isLoading = true
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                if isLoading {
                    loadingView
                } else {
                    // Main content
                    VStack(spacing: 0) {
                        // Header (when visible)
                        if showControls {
                            headerView
                                .transition(.move(edge: .top).combined(with: .opacity))
                        }
                        
                        // Reading area
                        ScrollViewReader { proxy in
                            ScrollView(.vertical, showsIndicators: false) {
                                readerContent
                                    .padding(.horizontal, appState.marginSize)
                                    .padding(.vertical, 40)
                            }
                            .onChange(of: currentChapter) { _, newValue in
                                withAnimation {
                                    proxy.scrollTo("chapter-\(newValue)", anchor: .top)
                                }
                            }
                        }
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                showControls.toggle()
                            }
                        }
                        
                        // Footer (when visible)
                        if showControls {
                            footerView
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                        }
                    }
                }
            }
        }
        .statusBarHidden(!showControls)
        .sheet(isPresented: $showSettings) {
            ReaderSettingsSheet()
                .environmentObject(appState)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
        .task {
            await loadBook()
        }
        .onDisappear {
            saveProgress()
        }
    }
    
    // MARK: - Loading View
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Loading book...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
    
    // MARK: - Header
    
    private var headerView: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            VStack(spacing: 2) {
                Text(book.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                
                if !chapters.isEmpty && currentChapter < chapters.count {
                    Text(chapters[currentChapter].title)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            .frame(maxWidth: 200)
            
            Spacer()
            
            Button {
                showSettings = true
            } label: {
                Image(systemName: "textformat.size")
                    .font(.title2)
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
    }
    
    // MARK: - Reader Content
    
    private var readerContent: some View {
        LazyVStack(alignment: .leading, spacing: 32) {
            ForEach(Array(chapters.enumerated()), id: \.offset) { index, chapter in
                VStack(alignment: .leading, spacing: 20) {
                    // Chapter title
                    Text(chapter.title)
                        .font(.system(size: 24, weight: .bold, design: .serif))
                        .foregroundStyle(.primary)
                        .id("chapter-\(index)")
                    
                    // Chapter content
                    Text(chapter.content)
                        .font(.custom(appState.fontFamily.fontName, size: appState.fontSize))
                        .lineSpacing(appState.fontSize * (appState.lineSpacing - 1))
                        .foregroundStyle(.primary.opacity(0.87))
                        .textSelection(.enabled)
                }
                
                if index < chapters.count - 1 {
                    Divider()
                        .padding(.vertical, 20)
                }
            }
        }
    }
    
    // MARK: - Footer
    
    private var footerView: some View {
        VStack(spacing: 12) {
            // Chapter navigation
            HStack(spacing: 20) {
                Button {
                    if currentChapter > 0 {
                        withAnimation {
                            currentChapter -= 1
                        }
                    }
                } label: {
                    Image(systemName: "chevron.left.circle.fill")
                        .font(.title)
                        .symbolRenderingMode(.hierarchical)
                }
                .disabled(currentChapter == 0)
                .opacity(currentChapter == 0 ? 0.3 : 1)
                
                Spacer()
                
                // Progress indicator
                if !chapters.isEmpty {
                    Text("\(currentChapter + 1) of \(chapters.count)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                }
                
                Spacer()
                
                Button {
                    if currentChapter < chapters.count - 1 {
                        withAnimation {
                            currentChapter += 1
                        }
                    }
                } label: {
                    Image(systemName: "chevron.right.circle.fill")
                        .font(.title)
                        .symbolRenderingMode(.hierarchical)
                }
                .disabled(currentChapter >= chapters.count - 1)
                .opacity(currentChapter >= chapters.count - 1 ? 0.3 : 1)
            }
            .padding(.horizontal, 40)
            
            // Progress bar
            if !chapters.isEmpty {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(.primary.opacity(0.1))
                        
                        Capsule()
                            .fill(.tint)
                            .frame(width: geo.size.width * progressPercentage)
                    }
                }
                .frame(height: 4)
                .padding(.horizontal, 20)
            }
        }
        .padding(.vertical, 16)
        .background(.ultraThinMaterial)
    }
    
    // MARK: - Helpers
    
    private var progressPercentage: CGFloat {
        guard !chapters.isEmpty else { return 0 }
        return CGFloat(currentChapter + 1) / CGFloat(chapters.count)
    }
    
    private func loadBook() async {
        // Simulate loading - replace with actual EPUB parsing
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        // Load chapters from book
        if let parsedChapters = EPUBParser.shared.parse(book: book) {
            chapters = parsedChapters
        } else {
            // Demo content if parsing fails
            chapters = [
                Chapter(title: "Chapter 1", content: sampleText),
                Chapter(title: "Chapter 2", content: sampleText),
                Chapter(title: "Chapter 3", content: sampleText)
            ]
        }
        
        // Restore reading position
        currentChapter = book.lastChapter
        
        withAnimation {
            isLoading = false
        }
    }
    
    private func saveProgress() {
        let progress = chapters.isEmpty ? 0 : Double(currentChapter + 1) / Double(chapters.count)
        bookManager.updateProgress(for: book, chapter: currentChapter, progress: progress)
    }
    
    private var sampleText: String {
        """
        Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.
        
        Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
        
        Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo.
        """
    }
}

/// Reading settings bottom sheet
struct ReaderSettingsSheet: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        NavigationStack {
            List {
                // Font Size
                Section("Text Size") {
                    HStack {
                        Text("Aa")
                            .font(.system(size: 14))
                        
                        Slider(value: $appState.fontSize, in: 14...28, step: 1)
                        
                        Text("Aa")
                            .font(.system(size: 24))
                    }
                    .padding(.vertical, 4)
                }
                
                // Font Family
                Section("Font") {
                    ForEach(FontFamily.allCases, id: \.self) { font in
                        Button {
                            appState.fontFamily = font
                        } label: {
                            HStack {
                                Text(font.rawValue)
                                    .font(.custom(font.fontName, size: 17))
                                    .foregroundStyle(.primary)
                                
                                Spacer()
                                
                                if appState.fontFamily == font {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(.tint)
                                }
                            }
                        }
                    }
                }
                
                // Line Spacing
                Section("Line Spacing") {
                    HStack {
                        Image(systemName: "text.alignleft")
                            .font(.caption)
                        
                        Slider(value: $appState.lineSpacing, in: 1.2...2.0, step: 0.1)
                        
                        Image(systemName: "text.alignleft")
                            .font(.body)
                    }
                    .padding(.vertical, 4)
                }
                
                // Margins
                Section("Margins") {
                    HStack {
                        Image(systemName: "arrow.left.and.right")
                            .font(.caption)
                        
                        Slider(value: $appState.marginSize, in: 16...48, step: 4)
                        
                        Image(systemName: "arrow.left.and.right")
                            .font(.body)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Reading Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    ReaderView(book: Book.preview)
        .environmentObject(AppState())
        .environmentObject(BookManager())
}

