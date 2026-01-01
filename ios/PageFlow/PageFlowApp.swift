import SwiftUI

/// PageFlow - A minimalist EPUB reader
/// Open source, no login required, beautifully simple
@main
struct PageFlowApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var bookManager = BookManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .environmentObject(bookManager)
                .preferredColorScheme(appState.colorScheme)
        }
    }
}

/// Global app state for theme and settings
@MainActor
final class AppState: ObservableObject {
    @AppStorage("theme") var theme: AppTheme = .system
    @AppStorage("fontSize") var fontSize: Double = 18
    @AppStorage("fontFamily") var fontFamily: FontFamily = .newYork
    @AppStorage("lineSpacing") var lineSpacing: Double = 1.6
    @AppStorage("marginSize") var marginSize: Double = 24
    
    var colorScheme: ColorScheme? {
        switch theme {
        case .light: return .light
        case .dark: return .dark
        case .system: return nil
        }
    }
}

enum AppTheme: String, CaseIterable, Codable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"
    
    var icon: String {
        switch self {
        case .system: return "circle.lefthalf.filled"
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        }
    }
}

enum FontFamily: String, CaseIterable, Codable {
    case newYork = "New York"
    case georgia = "Georgia"
    case palatino = "Palatino"
    case sanFrancisco = "SF Pro"
    case charter = "Charter"
    
    var fontName: String {
        switch self {
        case .newYork: return ".NewYork-Regular"
        case .georgia: return "Georgia"
        case .palatino: return "Palatino"
        case .sanFrancisco: return ".AppleSystemUIFont"
        case .charter: return "Charter-Roman"
        }
    }
}

