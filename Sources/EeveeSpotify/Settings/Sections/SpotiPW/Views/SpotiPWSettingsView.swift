import SwiftUI
import EeveeSpotifyC

// Settings section for the features vendored from spoti.pw
// (https://github.com/skopevoj/spoti.pw, GPL-3.0). The vendored hooks read their
// "spotifyglass.*" switches from NSUserDefaults at launch, so most changes apply after
// Spotify restarts; the tab bar (Navbar) relayouts live. The sub-pages below are the
// vendored UIKit pages themselves, built by SpotiPWPage() and pushed onto Spotify's
// navigation stack like every other ESR page.
//
// Preference keys live in the shared "spotifyglass." domain, so this UI and the vendored
// hooks always agree on state, and spoti.pw's own settings (if ever co-installed) see the
// same switches.

private struct SpotiPWPageView: UIViewControllerRepresentable {
    let pageName: String

    func makeUIViewController(context: Context) -> UIViewController {
        // Safety net; the vendored bootstrap already registers at load.
        SpotiPWRegisterPages()
        if let page = SpotiPWPage(pageName) {
            return page
        }
        let missing = UIViewController()
        missing.view.backgroundColor = .clear
        let label = UILabel()
        label.text = "spotipw_page_unavailable".localized
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        missing.view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: missing.view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: missing.view.centerYAnchor),
            label.leadingAnchor.constraint(greaterThanOrEqualTo: missing.view.leadingAnchor, constant: 24),
        ])
        return missing
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

struct SpotiPWSettingsView: View {
    let navigationController: UINavigationController

    private struct Entry {
        let page: String
        let titleKey: String
        let color: Color
        let systemImage: String
    }

    // Grouped like spoti.pw's own Mod Settings page: look, playback, privacy, then tools.
    // Titles are localized once here (lazily, on first render) so the l10n linter
    // (Tools/l10n_lint.py) sees each key used.
    private static let titles: [String] = [
        "spotipw_glass".localized,    // appearance
        "spotipw_navbar".localized,   // navbar
        "spotipw_home".localized,     // home
        "spotipw_player".localized,   // player
        "spotipw_playlist".localized, // playlist
        "spotipw_gestures".localized, // gestures
        "spotipw_privacy".localized,  // ads
        "spotipw_labs".localized,     // labs
        "spotipw_flags".localized,    // flags
        "spotipw_about".localized,    // mod
    ]

    private static let entries: [Entry] = [
        Entry(page: "appearance", titleKey: titles[0], color: Color(hex: "#64D2FF"), systemImage: "drop.fill"),
        Entry(page: "navbar",     titleKey: titles[1], color: Color(hex: "#32ADE6"), systemImage: "dock.rectangle"),
        Entry(page: "home",       titleKey: titles[2], color: .green,     systemImage: "house.fill"),
        Entry(page: "player",     titleKey: titles[3], color: .purple,    systemImage: "play.circle.fill"),
        Entry(page: "playlist",   titleKey: titles[4], color: .blue,      systemImage: "music.note.list"),
        Entry(page: "gestures",   titleKey: titles[5], color: .orange,    systemImage: "hand.tap.fill"),
        Entry(page: "ads",        titleKey: titles[6], color: .red,       systemImage: "crown.fill"),
        Entry(page: "labs",       titleKey: titles[7], color: .yellow,    systemImage: "testtube.2"),
        Entry(page: "flags",      titleKey: titles[8], color: .pink,      systemImage: "flag.fill"),
        Entry(page: "mod",        titleKey: titles[9], color: .gray,      systemImage: "info.circle.fill"),
    ]

    private func pushSettingsController(with view: any View, title: String) {
        let viewController = EeveeSettingsViewController(
            navigationController.view.frame,
            settingsView: AnyView(view),
            navigationTitle: title
        )
        navigationController.pushViewController(viewController, animated: true)
    }

    var body: some View {
        List {
            Section(footer: Text("spotipw_section_footer".localized)) {
                ForEach(Self.entries, id: \.page) { entry in
                    Button {
                        pushSettingsController(
                            with: SpotiPWPageView(pageName: entry.page),
                            title: entry.titleKey
                        )
                    } label: {
                        NavigationSectionView(
                            color: entry.color,
                            title: entry.titleKey,
                            imageSystemName: entry.systemImage
                        )
                    }
                }
            }

            Section {
                Button {
                    if let url = URL(string: "https://github.com/skopevoj/spoti.pw") {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    HStack {
                        Image(systemName: "link")
                        Text("spotipw_view_source".localized)
                    }
                }
            }
        }
        .listStyle(GroupedListStyle())
        .onAppear {
            WindowHelper.shared.overrideUserInterfaceStyle(.dark)
        }
    }
}
