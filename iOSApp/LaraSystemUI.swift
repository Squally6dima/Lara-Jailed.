import SwiftUI
import LaraJailedCore

private struct LaraSystemApp: Identifiable {
    let id: String
    let title: String
    let symbol: String
    let tint: Color
}

struct LaraSystemView: View {
    @State private var openedApp: LaraSystemApp?
    @State private var showControlCenter = false
    @State private var selectedPage = 0

    private let apps: [LaraSystemApp] = [
        .init(id: "files", title: "Files", symbol: "folder.fill", tint: Color(red: 0.08, green: 0.52, blue: 0.96)),
        .init(id: "terminal", title: "Terminal", symbol: "terminal.fill", tint: .black),
        .init(id: "packages", title: "Packages", symbol: "shippingbox.fill", tint: Color(red: 0.96, green: 0.48, blue: 0.12)),
        .init(id: "settings", title: "Settings", symbol: "gearshape.fill", tint: Color(white: 0.48)),
        .init(id: "safari", title: "Browser", symbol: "safari.fill", tint: Color(red: 0.12, green: 0.68, blue: 0.88)),
        .init(id: "notes", title: "Notes", symbol: "note.text", tint: Color(red: 0.98, green: 0.76, blue: 0.10)),
        .init(id: "activity", title: "Activity", symbol: "waveform.path", tint: Color(red: 0.12, green: 0.72, blue: 0.34)),
        .init(id: "extensions", title: "Extensions", symbol: "puzzlepiece.extension.fill", tint: Color(red: 0.70, green: 0.12, blue: 0.82)),
        .init(id: "about", title: "Lara", symbol: "sparkles", tint: Color(red: 0.10, green: 0.66, blue: 0.96))
    ]

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 16), count: 4)
    private var dockApps: [LaraSystemApp] { [apps[0], apps[1], apps[4], apps[3]] }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                WallpaperView()
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    HStack {
                        Spacer()
                        Button { showControlCenter = true } label: {
                            Image(systemName: "slider.horizontal.3")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(width: 42, height: 42)
                                .background(.ultraThinMaterial, in: Circle())
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Control Center")
                    }
                    .padding(.horizontal, 22)
                    .padding(.top, 4)

                    TabView(selection: $selectedPage) {
                        appPage(apps, topInset: geometry.safeAreaInsets.top)
                            .tag(0)
                        appPage([], topInset: geometry.safeAreaInsets.top)
                            .tag(1)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .indexViewStyle(.page(backgroundDisplayMode: .never))

                    HStack(spacing: 7) {
                        Capsule().fill(.white.opacity(selectedPage == 0 ? 0.95 : 0.42))
                            .frame(width: selectedPage == 0 ? 17 : 6, height: 6)
                        Circle().fill(.white.opacity(selectedPage == 1 ? 0.95 : 0.42))
                            .frame(width: 6, height: 6)
                    }
                    .padding(.vertical, 12)
                    .accessibilityLabel("Home screen page \(selectedPage + 1) of 2")

                    DockView(apps: dockApps) { app in
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        openedApp = app
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 6)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 24)
                    .onEnded { value in
                        if value.translation.height < -70 {
                            showControlCenter = true
                        }
                    }
            )
        }
        .sheet(item: $openedApp) { app in
            LaraSystemAppScreen(app: app)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showControlCenter) {
            LaraControlCenter()
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .preferredColorScheme(.dark)
    }

    private func appPage(_ pageApps: [LaraSystemApp], topInset: CGFloat) -> some View {
        VStack {
            LazyVGrid(columns: columns, spacing: 25) {
                ForEach(pageApps) { app in
                    AppIconView(app: app) {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        openedApp = app
                    }
                }
            }
            .padding(.horizontal, 22)
            .padding(.top, 12)
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .contentMargins(.top, max(0, topInset * 0.08), for: .scrollContent)
    }
}

private struct WallpaperView: View {
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.05, green: 0.10, blue: 0.25),
                        Color(red: 0.10, green: 0.08, blue: 0.28),
                        Color(red: 0.01, green: 0.02, blue: 0.07),
                        .black
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                Circle()
                    .fill(Color(red: 0.12, green: 0.52, blue: 0.95).opacity(0.48))
                    .frame(width: proxy.size.width * 0.8)
                    .blur(radius: 85)
                    .offset(x: proxy.size.width * 0.38, y: -proxy.size.height * 0.30)
                Circle()
                    .fill(Color.purple.opacity(0.34))
                    .frame(width: proxy.size.width * 0.72)
                    .blur(radius: 90)
                    .offset(x: -proxy.size.width * 0.35, y: proxy.size.height * 0.02)
                Circle()
                    .fill(Color.cyan.opacity(0.16))
                    .frame(width: proxy.size.width * 0.75)
                    .blur(radius: 90)
                    .offset(x: proxy.size.width * 0.2, y: proxy.size.height * 0.28)
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
            .clipped()
        }
    }
}

private struct AppIconView: View {
    let app: LaraSystemApp
    let action: () -> Void
    @State private var isPressed = false

    var body: some View {
        Button {
            action()
        } label: {
            VStack(spacing: 5) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [app.tint, app.tint.opacity(0.72)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    Image(systemName: app.symbol)
                        .font(.system(size: 29, weight: .medium))
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.18), radius: 1, y: 1)
                }
                .aspectRatio(1, contentMode: .fit)
                .overlay {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(.white.opacity(0.16), lineWidth: 0.7)
                }
                Text(app.title)
                    .font(.system(size: 11, weight: .regular, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .shadow(color: .black.opacity(0.65), radius: 2, y: 1)
            }
            .scaleEffect(isPressed ? 0.91 : 1)
            .animation(.spring(response: 0.25, dampingFraction: 0.62), value: isPressed)
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(SpringBoardPressStyle(isPressed: $isPressed))
    }
}

private struct SpringBoardPressStyle: ButtonStyle {
    @Binding var isPressed: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .onChange(of: configuration.isPressed) { pressed in
                isPressed = pressed
            }
    }
}

private struct DockView: View {
    let apps: [LaraSystemApp]
    let open: (LaraSystemApp) -> Void

    var body: some View {
        HStack(spacing: 17) {
            ForEach(apps) { app in
                Button {
                    open(app)
                } label: {
                    Image(systemName: app.symbol)
                        .font(.system(size: 25, weight: .medium))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .aspectRatio(1, contentMode: .fit)
                        .background(
                            LinearGradient(
                                colors: [app.tint, app.tint.opacity(0.72)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            in: RoundedRectangle(cornerRadius: 15, style: .continuous)
                        )
                }
                .buttonStyle(.plain)
                .accessibilityLabel(app.title)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 13)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 29, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 29, style: .continuous)
                .stroke(.white.opacity(0.16), lineWidth: 0.8)
        }
    }
}

private struct LaraSystemAppScreen: View {
    let app: LaraSystemApp
    @Environment(\.dismiss) private var dismiss
    @State private var terminalInput = ""
    @State private var terminalLines = ["Lara Terminal 0.2", "Container-local user-space shell", "Type help to list commands."]
    @State private var currentDirectory = "/"
    @State private var runtimeError: String?
    @State private var fileEntries: [String] = []
    @State private var notes = ""

    private var fileSystem: UserSpaceFileSystem {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? FileManager.default.temporaryDirectory
        return UserSpaceFileSystem(rootURL: base.appendingPathComponent("LaraJailed/RootFS", isDirectory: true))
    }

    private var shell: UserSpaceShell { UserSpaceShell(fileSystem: fileSystem) }

    var body: some View {
        NavigationStack {
            Group {
                switch app.id {
                case "terminal": terminalView
                case "files": filesView
                case "packages": packageView
                case "settings": settingsView
                case "extensions": extensionsView
                case "safari": browserView
                case "notes": notesView
                case "activity": activityView
                default: aboutView
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle(app.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private var terminalView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Circle().fill(runtimeError == nil ? .green : .red).frame(width: 8, height: 8)
                Text("lara@ios:\(currentDirectory)$").font(.system(.caption, design: .monospaced))
                    .foregroundStyle(.secondary).lineLimit(1)
                Spacer()
                Button { terminalLines = [] } label: { Image(systemName: "trash") }
                    .accessibilityLabel("Clear terminal")
            }
            if let runtimeError {
                Text(runtimeError).font(.footnote).foregroundStyle(.red)
            }
            ScrollView {
                VStack(alignment: .leading, spacing: 7) {
                    ForEach(Array(terminalLines.enumerated()), id: \.offset) { _, line in
                        Text(line.isEmpty ? " " : line)
                            .font(.system(.callout, design: .monospaced))
                            .foregroundStyle(line.hasPrefix("lara@ios:") ? .cyan : Color.primary)
                            .textSelection(.enabled)
                    }
                }.frame(maxWidth: .infinity, alignment: .leading)
            }
            HStack {
                Text("$").font(.system(.body, design: .monospaced).bold()).foregroundStyle(.green)
                TextField("help, ls, cd, cat…", text: $terminalInput)
                    .font(.system(.body, design: .monospaced))
                    .autocorrectionDisabled().textInputAutocapitalization(.never)
                    .onSubmit(runCommand)
                Button("Run", action: runCommand).fontWeight(.semibold)
            }.padding(12).background(.secondary.opacity(0.12), in: RoundedRectangle(cornerRadius: 12))
        }.padding()
        .task {
            do { try fileSystem.prepare() }
            catch { runtimeError = error.localizedDescription }
        }
    }

    private var filesView: some View {
        NavigationStack {
            List {
                Section("RootFS — app container") {
                    ForEach(fileEntries, id: \.self) { name in
                        Label(name, systemImage: "folder")
                    }
                }
                Section {
                    Text("Files are stored inside Lara's private container, not in the real iOS root filesystem.")
                        .font(.footnote).foregroundStyle(.secondary)
                }
            }
            .navigationTitle("RootFS")
            .task {
                do {
                    try fileSystem.prepare()
                    fileEntries = try fileSystem.list("/")
                } catch {
                    runtimeError = error.localizedDescription
                }
            }
        }
    }

    private var packageView: some View {
        List {
            Section("Package sources") {
                Label("Local packages", systemImage: "shippingbox")
                Label("Installed", systemImage: "checkmark.circle").badge("0")
            }
            Section("Next step") {
                Text("Connect a repository index and safe archive extraction before installing packages.")
                    .foregroundStyle(.secondary)
            }
        }.listStyle(.insetGrouped)
    }

    private var settingsView: some View {
        List {
            Section("System") {
                Label("Appearance", systemImage: "circle.lefthalf.filled")
                Label("Notifications", systemImage: "bell.badge")
                Label("Privacy & permissions", systemImage: "hand.raised")
            }
            Section("About") {
                LabeledContent("Lara version", value: "0.1 prototype")
                LabeledContent("Runtime", value: "User-space")
                LabeledContent("System integration", value: "Not connected")
            }
        }.listStyle(.insetGrouped)
    }

    private var extensionsView: some View {
        emptyState(title: "No Extensions", symbol: "puzzlepiece.extension",
                   message: "Lara-native extensions will appear here. Existing jailbreak tweaks are not automatically compatible.")
    }

    private var browserView: some View {
        emptyState(title: "Browser module", symbol: "safari",
                   message: "A browser view can be connected in a later milestone.")
    }

    private func emptyState(title: String, symbol: String, message: String) -> some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: symbol).font(.system(size: 42)).foregroundStyle(.secondary)
            Text(title).font(.title3.weight(.semibold))
            Text(message).font(.body).foregroundStyle(.secondary).multilineTextAlignment(.center)
            Spacer()
        }.padding(28).frame(maxWidth: .infinity)
    }

    private var notesView: some View {
        TextEditor(text: $notes).padding(8).overlay(alignment: .topLeading) {
            if notes.isEmpty { Text("Write a note…").foregroundStyle(.secondary).padding(.horizontal, 13).padding(.vertical, 16).allowsHitTesting(false) }
        }
    }

    private var activityView: some View {
        List {
            Label("Lara UI", systemImage: "checkmark.circle.fill").foregroundStyle(.green)
            Label("Package manager", systemImage: "clock").foregroundStyle(.secondary)
            Label("Bootstrap runtime", systemImage: "clock").foregroundStyle(.secondary)
            Label("Extension host", systemImage: "clock").foregroundStyle(.secondary)
        }.listStyle(.insetGrouped)
    }

    private var aboutView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: "sparkles").font(.system(size: 42)).foregroundStyle(.cyan)
            Text("Lara Jailed").font(.largeTitle.bold())
            Text("An isolated iOS user-space environment prototype.")
            Text("This build simulates a system UI. It does not replace SpringBoard, grant root, or install a bootstrap.")
                .font(.footnote).foregroundStyle(.secondary)
        }.padding(24)
    }

    private func runCommand() {
        let command = terminalInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !command.isEmpty else { return }
        terminalLines.append("lara@ios:\(currentDirectory)$ " + command)
        let result = shell.execute(command, currentDirectory: currentDirectory)
        currentDirectory = result.currentDirectory
        if result.output.contains("\u{001B}[2J") {
            terminalLines = []
        } else if !result.output.isEmpty {
            terminalLines.append(contentsOf: result.output.components(separatedBy: "\n"))
        }
        if result.shouldExit { terminalLines.append("Session ended (close this sheet to return).") }
        terminalInput = ""
    }
}

private struct LaraControlCenter: View {
    @State private var lowPower = false
    @State private var darkMode = true
    @State private var brightness = 0.7

    var body: some View {
        NavigationStack {
            VStack(spacing: 18) {
                HStack(spacing: 12) {
                    controlTile("Airplane Mode", symbol: "airplane", color: .orange)
                    controlTile("Wi-Fi", symbol: "wifi", color: .blue)
                    controlTile("Bluetooth", symbol: "bluetooth", color: .cyan)
                }
                VStack(alignment: .leading, spacing: 10) {
                    Label("Brightness", systemImage: "sun.max.fill")
                    Slider(value: $brightness)
                }.padding(18).background(.secondary.opacity(0.12), in: RoundedRectangle(cornerRadius: 20))
                Toggle(isOn: $lowPower) { Label("Low Power Mode (demo)", systemImage: "battery.25percent") }
                    .padding(18).background(.secondary.opacity(0.12), in: RoundedRectangle(cornerRadius: 20))
                Toggle(isOn: $darkMode) { Label("Dark appearance (demo)", systemImage: "moon.fill") }
                    .padding(18).background(.secondary.opacity(0.12), in: RoundedRectangle(cornerRadius: 20))
                Text("These controls change only this prototype UI; they do not change iOS system settings.")
                    .font(.footnote).foregroundStyle(.secondary)
                Spacer()
            }.padding()
            .navigationTitle("Control Center")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func controlTile(_ title: String, symbol: String, color: Color) -> some View {
        Button {} label: {
            VStack(spacing: 12) {
                Image(systemName: symbol).font(.title2)
                Text(title).font(.caption.weight(.medium))
            }.foregroundStyle(.white).frame(maxWidth: .infinity).padding(.vertical, 20)
                .background(color.gradient, in: RoundedRectangle(cornerRadius: 18))
        }.buttonStyle(.plain)
    }
}
