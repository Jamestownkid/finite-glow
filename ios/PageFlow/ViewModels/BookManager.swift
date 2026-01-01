import Foundation
import SwiftUI

/// Manages the book library - loading, saving, importing
@MainActor
final class BookManager: ObservableObject {
    @Published var books: [Book] = []
    
    private let booksKey = "savedBooks"
    private let fileManager = FileManager.default
    
    init() {
        loadBooks()
    }
    
    // MARK: - Public Methods
    
    /// Import a book from a URL
    func importBook(from url: URL) {
        // Get the documents directory
        guard let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        
        let booksFolder = documentsPath.appendingPathComponent("Books", isDirectory: true)
        
        // Create books folder if needed
        try? fileManager.createDirectory(at: booksFolder, withIntermediateDirectories: true)
        
        // Copy file to app's documents
        let fileName = url.lastPathComponent
        let destinationURL = booksFolder.appendingPathComponent(fileName)
        
        do {
            // Remove existing file if present
            if fileManager.fileExists(atPath: destinationURL.path) {
                try fileManager.removeItem(at: destinationURL)
            }
            
            try fileManager.copyItem(at: url, to: destinationURL)
            
            // Parse EPUB metadata
            let metadata = EPUBParser.shared.parseMetadata(from: destinationURL)
            
            let book = Book(
                title: metadata.title ?? fileName.replacingOccurrences(of: ".epub", with: ""),
                author: metadata.author ?? "Unknown Author",
                filePath: destinationURL.path,
                coverData: metadata.coverData
            )
            
            // Avoid duplicates
            if !books.contains(where: { $0.filePath == book.filePath }) {
                withAnimation {
                    books.append(book)
                }
                saveBooks()
            }
        } catch {
            print("Failed to import book: \(error.localizedDescription)")
        }
    }
    
    /// Remove a book from the library
    func removeBook(_ book: Book) {
        // Remove file
        try? fileManager.removeItem(atPath: book.filePath)
        
        // Remove from list
        books.removeAll { $0.id == book.id }
        saveBooks()
    }
    
    /// Update reading progress for a book
    func updateProgress(for book: Book, chapter: Int, progress: Double) {
        guard let index = books.firstIndex(where: { $0.id == book.id }) else { return }
        
        books[index].readingProgress = progress
        books[index].lastChapter = chapter
        books[index].lastReadDate = Date()
        
        saveBooks()
    }
    
    /// Sort books by different criteria
    func sortBooks(by criteria: SortCriteria) {
        withAnimation {
            switch criteria {
            case .title:
                books.sort { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
            case .author:
                books.sort { $0.author.localizedCaseInsensitiveCompare($1.author) == .orderedAscending }
            case .dateAdded:
                books.sort { $0.addedDate > $1.addedDate }
            case .lastRead:
                books.sort { ($0.lastReadDate ?? .distantPast) > ($1.lastReadDate ?? .distantPast) }
            case .progress:
                books.sort { $0.readingProgress > $1.readingProgress }
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func saveBooks() {
        do {
            let data = try JSONEncoder().encode(books)
            UserDefaults.standard.set(data, forKey: booksKey)
        } catch {
            print("Failed to save books: \(error.localizedDescription)")
        }
    }
    
    private func loadBooks() {
        guard let data = UserDefaults.standard.data(forKey: booksKey) else { return }
        
        do {
            books = try JSONDecoder().decode([Book].self, from: data)
            
            // Verify files still exist
            books = books.filter { fileManager.fileExists(atPath: $0.filePath) }
        } catch {
            print("Failed to load books: \(error.localizedDescription)")
        }
    }
}

// MARK: - Sort Criteria

enum SortCriteria: String, CaseIterable {
    case title = "Title"
    case author = "Author"
    case dateAdded = "Date Added"
    case lastRead = "Last Read"
    case progress = "Progress"
    
    var icon: String {
        switch self {
        case .title: return "textformat"
        case .author: return "person.fill"
        case .dateAdded: return "calendar"
        case .lastRead: return "clock.fill"
        case .progress: return "chart.bar.fill"
        }
    }
}

