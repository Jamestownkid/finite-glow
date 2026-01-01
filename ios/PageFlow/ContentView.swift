import SwiftUI

/// Main content view with tab navigation
struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTab: Tab = .library
    
    enum Tab {
        case library, settings
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            LibraryView()
                .tabItem {
                    Label("Library", systemImage: "books.vertical.fill")
                }
                .tag(Tab.library)
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(Tab.settings)
        }
        .tint(.primary)
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
        .environmentObject(BookManager())
}

