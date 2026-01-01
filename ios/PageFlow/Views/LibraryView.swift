import SwiftUI
import UniformTypeIdentifiers

/// Beautiful library view with book grid
struct LibraryView: View {
    @EnvironmentObject var bookManager: BookManager
    @EnvironmentObject var appState: AppState
    @State private var showingFilePicker = false
    @State private var selectedBook: Book?
    @State private var searchText = ""
    @Namespace private var namespace
    
    private let columns = [
        GridItem(.adaptive(minimum: 140, maximum: 180), spacing: 20)
    ]
    
    var filteredBooks: [Book] {
        if searchText.isEmpty {
            return bookManager.books
        }
        return bookManager.books.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.author.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if bookManager.books.isEmpty {
                    emptyLibraryView
                } else {
                    bookGridView
                }
            }
            .navigationTitle("Library")
            .searchable(text: $searchText, prompt: "Search books")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingFilePicker = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .symbolRenderingMode(.hierarchical)
                    }
                }
            }
            .fileImporter(
                isPresented: $showingFilePicker,
                allowedContentTypes: [UTType(filenameExtension: "epub")!],
                allowsMultipleSelection: true
            ) { result in
                handleFileImport(result)
            }
            .fullScreenCover(item: $selectedBook) { book in
                ReaderView(book: book)
                    .environmentObject(appState)
                    .environmentObject(bookManager)
            }
        }
    }
    
    // MARK: - Empty State
    
    private var emptyLibraryView: some View {
        VStack(spacing: 32) {
            Spacer()
            
            VStack(spacing: 16) {
                Image(systemName: "book.closed.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.tertiary)
                
                Text("Your Library is Empty")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Add EPUB books to start reading")
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
            
            Button {
                showingFilePicker = true
            } label: {
                Label("Add Books", systemImage: "plus")
                    .font(.headline)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 14)
                    .background(.tint.opacity(0.1))
                    .foregroundStyle(.tint)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
            
            Spacer()
            Spacer()
        }
        .padding()
    }
    
    // MARK: - Book Grid
    
    private var bookGridView: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 24) {
                ForEach(filteredBooks) { book in
                    BookCardView(book: book)
                        .onTapGesture {
                            withAnimation(.spring(response: 0.35)) {
                                selectedBook = book
                            }
                        }
                        .contextMenu {
                            Button(role: .destructive) {
                                withAnimation {
                                    bookManager.removeBook(book)
                                }
                            } label: {
                                Label("Remove", systemImage: "trash")
                            }
                        }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
    }
    
    // MARK: - Helpers
    
    private func handleFileImport(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            for url in urls {
                guard url.startAccessingSecurityScopedResource() else { continue }
                defer { url.stopAccessingSecurityScopedResource() }
                bookManager.importBook(from: url)
            }
        case .failure(let error):
            print("Import error: \(error.localizedDescription)")
        }
    }
}

/// Individual book card in the library grid
struct BookCardView: View {
    let book: Book
    @State private var isPressed = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Cover
            ZStack {
                if let coverData = book.coverData,
                   let uiImage = UIImage(data: coverData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    // Placeholder cover with gradient
                    LinearGradient(
                        colors: book.placeholderColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .overlay {
                        VStack(spacing: 8) {
                            Image(systemName: "book.fill")
                                .font(.largeTitle)
                            Text(book.title.prefix(20))
                                .font(.caption)
                                .fontWeight(.medium)
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                        }
                        .foregroundStyle(.white.opacity(0.9))
                        .padding()
                    }
                }
            }
            .frame(height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(.primary.opacity(0.05), lineWidth: 1)
            )
            
            // Title and Author
            VStack(alignment: .leading, spacing: 4) {
                Text(book.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                    .foregroundStyle(.primary)
                
                Text(book.author)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            
            // Progress bar
            if book.readingProgress > 0 {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(.primary.opacity(0.1))
                            .frame(height: 4)
                        
                        Capsule()
                            .fill(.tint)
                            .frame(width: geo.size.width * book.readingProgress, height: 4)
                    }
                }
                .frame(height: 4)
            }
        }
        .scaleEffect(isPressed ? 0.96 : 1)
        .animation(.spring(response: 0.3), value: isPressed)
        .onLongPressGesture(minimumDuration: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

#Preview {
    LibraryView()
        .environmentObject(AppState())
        .environmentObject(BookManager())
}

