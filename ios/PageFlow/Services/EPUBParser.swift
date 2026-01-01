import Foundation
import UIKit
import ZIPFoundation

/// Parses EPUB files to extract metadata and content
final class EPUBParser {
    static let shared = EPUBParser()
    
    private init() {}
    
    // MARK: - Metadata Parsing
    
    struct EPUBMetadata {
        var title: String?
        var author: String?
        var coverData: Data?
        var description: String?
        var language: String?
        var publisher: String?
    }
    
    /// Extract metadata from an EPUB file
    func parseMetadata(from url: URL) -> EPUBMetadata {
        var metadata = EPUBMetadata()
        
        guard let archive = Archive(url: url, accessMode: .read) else {
            return extractMetadataFromFilename(url)
        }
        
        // Find and parse container.xml to get the OPF location
        guard let containerEntry = archive["META-INF/container.xml"],
              let containerData = extractData(from: containerEntry, in: archive),
              let opfPath = parseContainerXML(containerData) else {
            return extractMetadataFromFilename(url)
        }
        
        // Parse the OPF file for metadata
        if let opfEntry = archive[opfPath],
           let opfData = extractData(from: opfEntry, in: archive) {
            metadata = parseOPFMetadata(opfData, archive: archive, opfPath: opfPath)
        }
        
        return metadata
    }
    
    /// Parse book into chapters
    func parse(book: Book) -> [Chapter]? {
        let url = URL(fileURLWithPath: book.filePath)
        
        guard let archive = Archive(url: url, accessMode: .read) else {
            return nil
        }
        
        // Find OPF file
        guard let containerEntry = archive["META-INF/container.xml"],
              let containerData = extractData(from: containerEntry, in: archive),
              let opfPath = parseContainerXML(containerData) else {
            return nil
        }
        
        // Get spine order from OPF
        guard let opfEntry = archive[opfPath],
              let opfData = extractData(from: opfEntry, in: archive),
              let spineItems = parseSpine(opfData, opfPath: opfPath) else {
            return nil
        }
        
        // Parse each chapter
        var chapters: [Chapter] = []
        
        for item in spineItems {
            if let entry = archive[item.path],
               let data = extractData(from: entry, in: archive),
               let content = String(data: data, encoding: .utf8) {
                
                let cleanedContent = stripHTML(content)
                let title = item.title ?? "Chapter \(chapters.count + 1)"
                
                if !cleanedContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    chapters.append(Chapter(title: title, content: cleanedContent))
                }
            }
        }
        
        return chapters.isEmpty ? nil : chapters
    }
    
    // MARK: - Private Helpers
    
    private func extractData(from entry: Entry, in archive: Archive) -> Data? {
        var data = Data()
        do {
            _ = try archive.extract(entry) { chunk in
                data.append(chunk)
            }
            return data
        } catch {
            return nil
        }
    }
    
    private func extractMetadataFromFilename(_ url: URL) -> EPUBMetadata {
        var metadata = EPUBMetadata()
        let filename = url.deletingPathExtension().lastPathComponent
        
        // Try to extract author from "Title - Author" format
        if let dashRange = filename.range(of: " - ") {
            metadata.title = String(filename[..<dashRange.lowerBound])
            metadata.author = String(filename[dashRange.upperBound...])
        } else {
            metadata.title = filename
        }
        
        return metadata
    }
    
    private func parseContainerXML(_ data: Data) -> String? {
        guard let xml = String(data: data, encoding: .utf8) else { return nil }
        
        // Simple XML parsing for rootfile path
        if let range = xml.range(of: "full-path=\""),
           let endRange = xml[range.upperBound...].range(of: "\"") {
            return String(xml[range.upperBound..<endRange.lowerBound])
        }
        
        return nil
    }
    
    private func parseOPFMetadata(_ data: Data, archive: Archive, opfPath: String) -> EPUBMetadata {
        var metadata = EPUBMetadata()
        guard let xml = String(data: data, encoding: .utf8) else { return metadata }
        
        // Extract title
        metadata.title = extractXMLValue(from: xml, tag: "dc:title")
            ?? extractXMLValue(from: xml, tag: "title")
        
        // Extract author
        metadata.author = extractXMLValue(from: xml, tag: "dc:creator")
            ?? extractXMLValue(from: xml, tag: "creator")
        
        // Extract description
        metadata.description = extractXMLValue(from: xml, tag: "dc:description")
        
        // Extract language
        metadata.language = extractXMLValue(from: xml, tag: "dc:language")
        
        // Extract publisher
        metadata.publisher = extractXMLValue(from: xml, tag: "dc:publisher")
        
        // Try to find cover image
        if let coverId = extractCoverId(from: xml),
           let coverHref = extractHref(for: coverId, from: xml) {
            
            // Resolve cover path relative to OPF
            let opfDir = (opfPath as NSString).deletingLastPathComponent
            let coverPath = opfDir.isEmpty ? coverHref : "\(opfDir)/\(coverHref)"
            
            if let coverEntry = archive[coverPath],
               let coverData = extractData(from: coverEntry, in: archive) {
                metadata.coverData = coverData
            }
        }
        
        return metadata
    }
    
    private func extractXMLValue(from xml: String, tag: String) -> String? {
        let pattern = "<\(tag)[^>]*>([^<]+)</\(tag)>"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
              let match = regex.firstMatch(in: xml, range: NSRange(xml.startIndex..., in: xml)),
              let range = Range(match.range(at: 1), in: xml) else {
            return nil
        }
        return String(xml[range]).trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func extractCoverId(from xml: String) -> String? {
        // Look for meta name="cover" content="cover-id"
        let patterns = [
            "name=\"cover\"[^>]*content=\"([^\"]+)\"",
            "content=\"([^\"]+)\"[^>]*name=\"cover\""
        ]
        
        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
               let match = regex.firstMatch(in: xml, range: NSRange(xml.startIndex..., in: xml)),
               let range = Range(match.range(at: 1), in: xml) {
                return String(xml[range])
            }
        }
        
        // Also check for item with id containing "cover"
        let coverPattern = "<item[^>]*id=\"([^\"]*cover[^\"]*)\"[^>]*media-type=\"image/[^\"]+\""
        if let regex = try? NSRegularExpression(pattern: coverPattern, options: .caseInsensitive),
           let match = regex.firstMatch(in: xml, range: NSRange(xml.startIndex..., in: xml)),
           let range = Range(match.range(at: 1), in: xml) {
            return String(xml[range])
        }
        
        return nil
    }
    
    private func extractHref(for id: String, from xml: String) -> String? {
        let pattern = "<item[^>]*id=\"\(id)\"[^>]*href=\"([^\"]+)\""
        if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
           let match = regex.firstMatch(in: xml, range: NSRange(xml.startIndex..., in: xml)),
           let range = Range(match.range(at: 1), in: xml) {
            return String(xml[range])
        }
        
        // Try reverse order
        let reversePattern = "<item[^>]*href=\"([^\"]+)\"[^>]*id=\"\(id)\""
        if let regex = try? NSRegularExpression(pattern: reversePattern, options: .caseInsensitive),
           let match = regex.firstMatch(in: xml, range: NSRange(xml.startIndex..., in: xml)),
           let range = Range(match.range(at: 1), in: xml) {
            return String(xml[range])
        }
        
        return nil
    }
    
    private struct SpineItem {
        let path: String
        let title: String?
    }
    
    private func parseSpine(_ data: Data, opfPath: String) -> [SpineItem]? {
        guard let xml = String(data: data, encoding: .utf8) else { return nil }
        
        let opfDir = (opfPath as NSString).deletingLastPathComponent
        
        // Build manifest map: id -> href
        var manifest: [String: String] = [:]
        let manifestPattern = "<item[^>]*id=\"([^\"]+)\"[^>]*href=\"([^\"]+)\""
        if let regex = try? NSRegularExpression(pattern: manifestPattern, options: .caseInsensitive) {
            let matches = regex.matches(in: xml, range: NSRange(xml.startIndex..., in: xml))
            for match in matches {
                if let idRange = Range(match.range(at: 1), in: xml),
                   let hrefRange = Range(match.range(at: 2), in: xml) {
                    let id = String(xml[idRange])
                    let href = String(xml[hrefRange])
                    manifest[id] = href
                }
            }
        }
        
        // Parse spine order
        var spineItems: [SpineItem] = []
        let spinePattern = "<itemref[^>]*idref=\"([^\"]+)\""
        if let regex = try? NSRegularExpression(pattern: spinePattern, options: .caseInsensitive) {
            let matches = regex.matches(in: xml, range: NSRange(xml.startIndex..., in: xml))
            for match in matches {
                if let idRange = Range(match.range(at: 1), in: xml) {
                    let id = String(xml[idRange])
                    if let href = manifest[id] {
                        let path = opfDir.isEmpty ? href : "\(opfDir)/\(href)"
                        spineItems.append(SpineItem(path: path, title: nil))
                    }
                }
            }
        }
        
        return spineItems.isEmpty ? nil : spineItems
    }
    
    private func stripHTML(_ html: String) -> String {
        var text = html
        
        // Remove scripts and styles
        text = text.replacingOccurrences(of: "<script[^>]*>[\\s\\S]*?</script>", with: "", options: .regularExpression)
        text = text.replacingOccurrences(of: "<style[^>]*>[\\s\\S]*?</style>", with: "", options: .regularExpression)
        
        // Convert common elements to readable format
        text = text.replacingOccurrences(of: "</p>", with: "\n\n")
        text = text.replacingOccurrences(of: "<br[^>]*>", with: "\n", options: .regularExpression)
        text = text.replacingOccurrences(of: "</div>", with: "\n")
        text = text.replacingOccurrences(of: "</h[1-6]>", with: "\n\n", options: .regularExpression)
        
        // Remove all remaining tags
        text = text.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
        
        // Decode HTML entities
        text = text.replacingOccurrences(of: "&nbsp;", with: " ")
        text = text.replacingOccurrences(of: "&amp;", with: "&")
        text = text.replacingOccurrences(of: "&lt;", with: "<")
        text = text.replacingOccurrences(of: "&gt;", with: ">")
        text = text.replacingOccurrences(of: "&quot;", with: "\"")
        text = text.replacingOccurrences(of: "&#39;", with: "'")
        text = text.replacingOccurrences(of: "&apos;", with: "'")
        text = text.replacingOccurrences(of: "&mdash;", with: "—")
        text = text.replacingOccurrences(of: "&ndash;", with: "–")
        text = text.replacingOccurrences(of: "&hellip;", with: "...")
        
        // Clean up whitespace
        text = text.replacingOccurrences(of: "\r\n", with: "\n")
        text = text.replacingOccurrences(of: "\r", with: "\n")
        text = text.replacingOccurrences(of: "\n{3,}", with: "\n\n", options: .regularExpression)
        text = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        return text
    }
}

