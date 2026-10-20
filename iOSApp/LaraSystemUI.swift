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

    private let apps: [LaraSystemApp] = [
        .init(id: "files", title: "Files", symbol: "folder.fill", tint: .blue),
        .init(id: "terminal", title: "Terminal", symbol: "terminal.fill", tint: .black),
        .init(id: "packages", title: "Packages", symbol: "shippingbox.fill", tint: .orange),
        .init(id: "settings", title: "Settings", symbol: "gearshape.fill", tint: .gray),
        .init(id: "safari", title: "Browser", symbol: "safari.fill", tint: .cyan),
        .init(id: "notes", title: "Notes", symbol: "note.text", tint: .yellow),
        .init(id: "activity", title: "Activity", symbol: "waveform.path", tint: .green),
        .init(id: "extensions", title: "Extensions", symbol: "puzzlepiece.extension.fill", tint: .purple),
        .init(id: "about", title: "Lara", symbol: "sparkles", tint: .cyan)
    ]

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 20), count: 4)

    var body: some View {
        ZStack {
            wallpaper.ignoresSafeArea()
            VStack(spacing: 0) {
                statusBar
                HStack {
                    Text(Date.now, format: .dateTime.weekday(.wide).month(.abbreviated).day())
                        .font(.system(size: 15, weight: .medium))
                    Spacer()
                    Button { showControlCenter = true } label: {
                        Image(systemName: "slider.horizontal.3")
                            .font(.system(size: 16, weight: .semibold))
                            .padding(11).background(.ultraThinMaterial, in: Circle())
                    }.buttonStyle(.plain)
                }.padding(.horizontal, 24).padding(.top, 12)

                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("LARA").font(.system(size: 12, weight: .heavy)).tracking(4).foregroundStyle(.cyan)
                        Text("Welcome back").font(.system(size: 29, weight: .bold, design: .rounded))
                    }
                    Spacer()
                }.padding(.horizontal, 24).padding(.top, 24)

                HStack(spacing: 10) {
                    Image(systemName: "sparkles").foregroundStyle(.cyan)
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Lara User Space").font(.subheadline.weight(.semibold))
                        Text("Your isolated environment").font(.caption).foregroundStyle(.white.opacity(0.6))
                    }
                    Spacer()
                    Text("0.1").font(.caption2.bold()).padding(.horizontal, 9).padding(.vertical, 5)
                        .background(.white.opacity(0.12), in: Capsule())
                }.padding(15).background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 22))
                    .overlay(RoundedRectangle(cornerRadius: 22).stroke(.white.opacity(0.1), lineWidth: 1))
                    .padding(.horizontal, 20).padding(.top, 22)

                LazyVGrid(columns: columns, spacing: 25) {
                    ForEach(apps) { app in
                        Button {
                            openedApp = app
                        } label: {
                            VStack(spacing: 7) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 17)
                                        .fill(LinearGradient(colors: [app.tint.opacity(0.95), app.tint.opacity(0.58)],
                                                             startPoint: .topLeading, endPoint: .bottomTrailing))
                                    Image(systemName: app.symbol).font(.system(size: 26, weight: .medium))
                                        .foregroundStyle(.white)
                                        .shadow(color: .black.opacity(0.15), radius: 2, y: 1)
                                }.frame(width: 58, height: 58)
                                    .overlay(RoundedRectangle(cornerRadius: 17).stroke(.white.opacity(0.25), lineWidth: 0.8))
                                Text(app.title).font(.system(size: 11, weight: .medium)).lineLimit(1)
                            }.frame(maxWidth: .infinity)
                        }.buttonStyle(.plain)
                    }
                }.padding(.horizontal, 22).padding(.top, 30)

                Spacer()

                HStack(spacing: 18) {
                    dockButton(apps[0])
                    dockButton(apps[1])
                    dockButton(apps[4])
                    dockButton(apps[3])
                }.padding(.horizontal, 18).padding(.vertical, 15)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 30))
                    .overlay(RoundedRectangle(cornerRadius: 30).stroke(.white.opacity(0.15), lineWidth: 1))
                    .padding(.horizontal, 28).padding(.bottom, 12)

                Capsule().fill(.white.opacity(0.85)).frame(width: 135, height: 5).padding(.bottom, 7)
            }
        }
        .sheet(item: $openedApp) { app in
            LaraSystemAppScreen(app: app).presentationDetents([.large]).presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showControlCenter) {
            LaraControlCenter().presentationDetents([.medium, .large]).presentationDragIndicator(.visible)
        }
    }

    private var wallpaper: some View {
        ZStack {
            LinearGradient(colors: [Color(red: 0.08, green: 0.12, blue: 0.25),
                                    Color(red: 0.03, green: 0.04, blue: 0.1), .black],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
            Circle().fill(.cyan.opacity(0.20)).frame(width: 290).blur(radius: 75)
                .offset(x: 120, y: -230)
            Circle().fill(.purple.opacity(0.17)).frame(width: 300).blur(radius: 90)
                .offset(x: -130, y: 70)
        }
    }

    private var statusBar: some View {
        HStack {
            Text(Date.now, format: .dateTime.hour().minute()).font(.system(size: 15, weight: .bold))
            Spacer()
            Image(systemName: "antenna.radiowaves.left.and.right")
            Image(systemName: "wifi")
            Image(systemName: "battery.75percent").font(.system(size: 18))
        }.padding(.horizontal, 25).padding(.top, 10)
    }

    private func dockButton(_ app: LaraSystemApp) -> some View {
        Button { openedApp = app } label: {
            Image(systemName: app.symbol).font(.system(size: 23, weight: .medium))
                .foregroundStyle(.white).frame(maxWidth: .infinity).frame(height: 58)
                .background(LinearGradient(colors: [app.tint.opacity(0.95), app.tint.opacity(0.6)],
                                           startPoint: .topLeading, endPoint: .bottomTrailing),
                            in: RoundedRectangle(cornerRadius: 17))
        }.buttonStyle(.plain)
    }
}

private struct LaraSystemAppScreen: View {
    let app: LaraSystemApp
    @Environment(\.dismiss) private var dismiss
    @State private var terminalInput = ""
    @State private var terminalLines = ["Lara Terminal 0.2", "Container-local user-space shell", "Type help to list commands."]
    @State private var currentDirectory = "/"
    @State private var runtimeError: String?
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
                    ForEach((try? fileSystem.list("/")) ?? [], id: \.self) { name in
                        Label(name, systemImage: "folder")
                    }
                }
                Section {
                    Text("Files are stored inside Lara's private container, not in the real iOS root filesystem.")
                        .font(.footnote).foregroundStyle(.secondary)
                }
            }
            .navigationTitle("RootFS")
            .task { try? fileSystem.prepare() }
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
