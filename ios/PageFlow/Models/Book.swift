import Foundation
import SwiftUI

/// Represents an ebook in the library
struct Book: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var author: String
    var filePath: String
    var coverData: Data?
    var addedDate: Date
    var lastReadDate: Date?
    var readingProgress: Double
    var lastChapter: Int
    
    init(
        id: UUID = UUID(),
        title: String,
        author: String = "Unknown Author",
        filePath: String,
        coverData: Data? = nil,
        addedDate: Date = Date(),
        lastReadDate: Date? = nil,
        readingProgress: Double = 0,
        lastChapter: Int = 0
    ) {
        self.id = id
        self.title = title
        self.author = author
        self.filePath = filePath
        self.coverData = coverData
        self.addedDate = addedDate
        self.lastReadDate = lastReadDate
        self.readingProgress = readingProgress
        self.lastChapter = lastChapter
    }
    
    /// Generate consistent placeholder colors based on title
    var placeholderColors: [Color] {
        let hash = abs(title.hashValue)
        let colorSets: [[Color]] = [
            [.indigo, .purple],
            [.blue, .cyan],
            [.teal, .green],
            [.orange, .red],
            [.pink, .purple],
            [.mint, .teal],
            [.brown, .orange]
        ]
        return colorSets[hash % colorSets.count]
    }
    
    // MARK: - Codable
    
    enum CodingKeys: String, CodingKey {
        case id, title, author, filePath, coverData
        case addedDate, lastReadDate, readingProgress, lastChapter
    }
    
    // MARK: - Preview
    
    static var preview: Book {
        Book(
            title: "The Great Gatsby",
            author: "F. Scott Fitzgerald",
            filePath: "/preview/gatsby.epub"
        )
    }
    
    static var previews: [Book] {
        [
            Book(title: "The Great Gatsby", author: "F. Scott Fitzgerald", filePath: "/1.epub"),
            Book(title: "1984", author: "George Orwell", filePath: "/2.epub", readingProgress: 0.4),
            Book(title: "Pride and Prejudice", author: "Jane Austen", filePath: "/3.epub", readingProgress: 0.8),
            Book(title: "To Kill a Mockingbird", author: "Harper Lee", filePath: "/4.epub"),
            Book(title: "The Catcher in the Rye", author: "J.D. Salinger", filePath: "/5.epub", readingProgress: 0.2)
        ]
    }
}

/// Represents a chapter within a book
struct Chapter: Identifiable, Hashable {
    let id: UUID
    let title: String
    let content: String
    
    init(id: UUID = UUID(), title: String, content: String) {
        self.id = id
        self.title = title
        self.content = content
    }
}

/// Reading progress for syncing
struct ReadingProgress: Codable {
    let bookId: UUID
    var chapter: Int
    var progress: Double
    var lastUpdated: Date
}

