import SwiftUI

/// Minimalist settings screen
struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var bookManager: BookManager
    @State private var showingAbout = false
    
    var body: some View {
        NavigationStack {
            List {
                // Appearance
                Section {
                    // Theme picker
                    HStack {
                        Label("Theme", systemImage: "paintbrush.fill")
                        
                        Spacer()
                        
                        Picker("", selection: $appState.theme) {
                            ForEach(AppTheme.allCases, id: \.self) { theme in
                                Label(theme.rawValue, systemImage: theme.icon)
                                    .tag(theme)
                            }
                        }
                        .pickerStyle(.menu)
                        .labelsHidden()
                    }
                } header: {
                    Text("Appearance")
                } footer: {
                    Text("Choose between light, dark, or system theme.")
                }
                
                // Reading Defaults
                Section("Reading Defaults") {
                    NavigationLink {
                        DefaultReadingSettings()
                            .environmentObject(appState)
                    } label: {
                        Label("Typography", systemImage: "textformat")
                    }
                }
                
                // Library
                Section("Library") {
                    HStack {
                        Label("Books", systemImage: "books.vertical.fill")
                        Spacer()
                        Text("\(bookManager.books.count)")
                            .foregroundStyle(.secondary)
                            .monospacedDigit()
                    }
                    
                    Button(role: .destructive) {
                        // Clear all books
                    } label: {
                        Label("Clear Library", systemImage: "trash")
                    }
                    .disabled(bookManager.books.isEmpty)
                }
                
                // About
                Section {
                    Button {
                        showingAbout = true
                    } label: {
                        HStack {
                            Label("About PageFlow", systemImage: "info.circle.fill")
                                .foregroundStyle(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                    }
                    
                    Link(destination: URL(string: "https://github.com/PageFlow/PageFlow")!) {
                        HStack {
                            Label("Source Code", systemImage: "chevron.left.forwardslash.chevron.right")
                                .foregroundStyle(.primary)
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                    }
                } header: {
                    Text("Info")
                } footer: {
                    Text("PageFlow is open source software.")
                }
                
                // App Info
                Section {
                    HStack {
                        Spacer()
                        VStack(spacing: 8) {
                            Image(systemName: "book.fill")
                                .font(.largeTitle)
                                .foregroundStyle(.tint)
                            
                            Text("PageFlow")
                                .font(.headline)
                            
                            Text("Version 1.0.0")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 20)
                        Spacer()
                    }
                }
                .listRowBackground(Color.clear)
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showingAbout) {
                AboutView()
            }
        }
    }
}

/// Default reading settings screen
struct DefaultReadingSettings: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        List {
            // Preview
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    Text("The quick brown fox jumps over the lazy dog.")
                        .font(.custom(appState.fontFamily.fontName, size: appState.fontSize))
                        .lineSpacing(appState.fontSize * (appState.lineSpacing - 1))
                }
                .padding(.vertical, 8)
            } header: {
                Text("Preview")
            }
            
            // Font Size
            Section("Text Size") {
                VStack {
                    HStack {
                        Text("\(Int(appState.fontSize)) pt")
                            .monospacedDigit()
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                    
                    HStack {
                        Text("Aa")
                            .font(.system(size: 14))
                        
                        Slider(value: $appState.fontSize, in: 14...28, step: 1)
                        
                        Text("Aa")
                            .font(.system(size: 24))
                    }
                }
            }
            
            // Font Family
            Section("Font") {
                ForEach(FontFamily.allCases, id: \.self) { font in
                    Button {
                        withAnimation {
                            appState.fontFamily = font
                        }
                    } label: {
                        HStack {
                            Text(font.rawValue)
                                .font(.custom(font.fontName, size: 17))
                                .foregroundStyle(.primary)
                            
                            Spacer()
                            
                            if appState.fontFamily == font {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.tint)
                            }
                        }
                    }
                }
            }
            
            // Line Spacing
            Section("Line Spacing") {
                VStack {
                    HStack {
                        Text("\(appState.lineSpacing, specifier: "%.1f")x")
                            .monospacedDigit()
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                    
                    Slider(value: $appState.lineSpacing, in: 1.2...2.0, step: 0.1)
                }
            }
            
            // Margins
            Section("Margins") {
                VStack {
                    HStack {
                        Text("\(Int(appState.marginSize)) pt")
                            .monospacedDigit()
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                    
                    Slider(value: $appState.marginSize, in: 16...48, step: 4)
                }
            }
        }
        .navigationTitle("Typography")
        .navigationBarTitleDisplayMode(.inline)
    }
}

/// About screen with app info
struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    // App Icon
                    VStack(spacing: 16) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 28, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [.indigo, .purple],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 100, height: 100)
                            
                            Image(systemName: "book.fill")
                                .font(.system(size: 44))
                                .foregroundStyle(.white)
                        }
                        .shadow(color: .indigo.opacity(0.3), radius: 20, y: 10)
                        
                        VStack(spacing: 4) {
                            Text("PageFlow")
                                .font(.title)
                                .fontWeight(.bold)
                            
                            Text("Version 1.0.0")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.top, 40)
                    
                    // Description
                    VStack(spacing: 16) {
                        Text("A minimalist EPUB reader designed for focused reading.")
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)
                        
                        Text("No accounts. No tracking. Just reading.")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(.primary)
                    }
                    .padding(.horizontal, 32)
                    
                    // Features
                    VStack(alignment: .leading, spacing: 16) {
                        FeatureRow(icon: "book.fill", title: "Beautiful Typography", description: "Carefully crafted reading experience")
                        FeatureRow(icon: "moon.fill", title: "Dark & Light Themes", description: "Read comfortably day or night")
                        FeatureRow(icon: "lock.fill", title: "Privacy First", description: "Your books stay on your device")
                        FeatureRow(icon: "chevron.left.forwardslash.chevron.right", title: "Open Source", description: "Free forever, community driven")
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer(minLength: 40)
                    
                    // Footer
                    VStack(spacing: 8) {
                        Text("Made with")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                        +
                        Text(" ♥ ")
                            .font(.caption)
                            .foregroundStyle(.red)
                        +
                        Text("using SwiftUI")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                    .padding(.bottom, 32)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.tint)
                .frame(width: 44, height: 44)
                .background(.tint.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppState())
        .environmentObject(BookManager())
}

