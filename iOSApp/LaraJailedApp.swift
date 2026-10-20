import SwiftUI
import LaraJailedCore

@main
struct LaraJailedApp: App {
    var body: some Scene {
        WindowGroup {
            LaraHomeView().preferredColorScheme(.dark)
        }
    }
}

private enum LaraTab: String, CaseIterable, Identifiable {
    case home = "Home"
    case packages = "Packages"
    case extensions = "Extensions"
    case settings = "Settings"
    var id: String { rawValue }
    var symbol: String {
        switch self {
        case .home: return "square.grid.2x2.fill"
        case .packages: return "shippingbox.fill"
        case .extensions: return "puzzlepiece.extension.fill"
        case .settings: return "gearshape.fill"
        }
    }
}

struct LaraHomeView: View {
    @State private var selectedTab: LaraTab = .home
    @State private var showPrototypeInfo = false

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(red: 0.07, green: 0.09, blue: 0.17), .black],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            VStack(spacing: 0) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("LARA").font(.system(size: 13, weight: .bold, design: .rounded))
                            .tracking(3).foregroundStyle(.cyan)
                        Text(selectedTab.rawValue).font(.system(size: 32, weight: .bold, design: .rounded))
                    }
                    Spacer()
                    Image(systemName: "sparkles").font(.title2.weight(.semibold))
                        .foregroundStyle(.cyan).frame(width: 48, height: 48)
                        .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 16))
                }.padding(.horizontal, 22).padding(.top, 16)

                ScrollView {
                    VStack(spacing: 16) {
                        switch selectedTab {
                        case .home:
                            heroCard
                            statusCard
                            HStack(spacing: 12) {
                                quickAction("Packages", symbol: "shippingbox.fill", tab: .packages)
                                quickAction("Extensions", symbol: "puzzlepiece.extension.fill", tab: .extensions)
                            }
                        case .packages:
                            infoCard(title: "Package manager", subtitle: "Manifest validation is the first milestone.",
                                     symbol: "shippingbox", detail: "Package downloads, binary installation, and scripts are not enabled yet.")
                        case .extensions:
                            infoCard(title: "Extension API", subtitle: "A capability-based API for Lara-native extensions.",
                                     symbol: "puzzlepiece.extension", detail: "Existing jailbreak tweaks are not automatically compatible with a jailed app.")
                        case .settings:
                            infoCard(title: "Runtime settings", subtitle: "Runtime files stay inside the app container.",
                                     symbol: "lock.shield", detail: "No root access, protected-process injection, or system replacement is assumed.")
                        }
                    }.padding(20)
                }

                HStack(spacing: 0) {
                    ForEach(LaraTab.allCases) { tab in
                        Button {
                            withAnimation(.snappy(duration: 0.2)) { selectedTab = tab }
                        } label: {
                            VStack(spacing: 6) {
                                Image(systemName: tab.symbol).font(.system(size: 18, weight: .semibold))
                                Text(tab.rawValue).font(.system(size: 10, weight: .medium))
                            }
                            .foregroundStyle(selectedTab == tab ? .cyan : .white.opacity(0.5))
                            .frame(maxWidth: .infinity).padding(.vertical, 12)
                            .contentShape(Rectangle())
                        }.buttonStyle(.plain)
                    }
                }.padding(.horizontal, 8).background(.ultraThinMaterial)
            }
        }
        .alert("Prototype build", isPresented: $showPrototypeInfo) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("This is the initial UI shell. Runtime installation, package downloads, and tweak compatibility are not implemented yet.")
        }
    }

    private var heroCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Label("JAILED ENVIRONMENT", systemImage: "shield.lefthalf.filled")
                    .font(.system(size: 11, weight: .bold)).tracking(1).foregroundStyle(.cyan)
                Spacer()
                Text("MVP 0.1").font(.caption2.weight(.bold))
                    .padding(.horizontal, 9).padding(.vertical, 5)
                    .background(.white.opacity(0.1), in: Capsule())
            }
            Text("Your space.\nYour tools.").font(.system(size: 30, weight: .bold, design: .rounded))
            Text("A modular user-space environment inspired by iOS 18.")
                .font(.subheadline).foregroundStyle(.white.opacity(0.68))
            Button { showPrototypeInfo = true } label: {
                HStack { Text("Explore prototype"); Spacer(); Image(systemName: "arrow.up.right") }
                    .font(.subheadline.weight(.semibold)).padding(14)
                    .background(.cyan.opacity(0.18), in: RoundedRectangle(cornerRadius: 14))
            }.buttonStyle(.plain)
        }.padding(20)
            .background(LinearGradient(colors: [.white.opacity(0.12), .white.opacity(0.04)],
                                       startPoint: .topLeading, endPoint: .bottomTrailing),
                        in: RoundedRectangle(cornerRadius: 26))
            .overlay(RoundedRectangle(cornerRadius: 26).stroke(.white.opacity(0.12), lineWidth: 1))
    }

    private var statusCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("PROJECT STATUS").font(.caption.weight(.bold)).tracking(1.5)
                .foregroundStyle(.white.opacity(0.55))
            statusRow("Shell interface", state: "Prototype")
            statusRow("Manifest validation", state: "Core added")
            statusRow("Bootstrap runtime", state: "Not connected")
            statusRow("Existing tweak support", state: "Not guaranteed")
        }.padding(18).background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 22))
    }

    private func quickAction(_ title: String, symbol: String, tab: LaraTab) -> some View {
        Button { withAnimation(.snappy(duration: 0.2)) { selectedTab = tab } } label: {
            VStack(alignment: .leading, spacing: 12) {
                Image(systemName: symbol).font(.title2).foregroundStyle(.cyan)
                Text(title).font(.headline)
                Text("Open section").font(.caption).foregroundStyle(.white.opacity(0.55))
            }.frame(maxWidth: .infinity, alignment: .leading).padding(16)
                .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 20))
        }.buttonStyle(.plain)
    }

    private func infoCard(title: String, subtitle: String, symbol: String, detail: String) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Image(systemName: symbol).font(.system(size: 28)).foregroundStyle(.cyan)
            Text(title).font(.title2.bold())
            Text(subtitle).foregroundStyle(.white.opacity(0.7))
            Divider().overlay(.white.opacity(0.12))
            Text(detail).font(.subheadline).foregroundStyle(.white.opacity(0.6))
        }.frame(maxWidth: .infinity, alignment: .leading).padding(20)
            .background(.white.opacity(0.07), in: RoundedRectangle(cornerRadius: 24))
    }

    private func statusRow(_ title: String, state: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "circle.dotted").foregroundStyle(.cyan)
            Text(title).font(.subheadline)
            Spacer(minLength: 8)
            Text(state).font(.caption).foregroundStyle(.white.opacity(0.5))
        }
    }
}
