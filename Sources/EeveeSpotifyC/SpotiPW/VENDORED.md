# Vendored: spoti.pw

Source: https://github.com/skopevoj/spoti.pw (tweak/ + scripts/extract-flags.py)
License: GPL-3.0 (see LICENSE in this directory)
Upstream commit at time of vendoring: see `UPSTREAM_COMMIT` (spotifyglass 0.16.0)

spoti.pw is a Theos tweak that rebuilds Spotify for iOS in Liquid Glass. Its feature code
is vendored here so EeveeSpotify can expose the pieces ESR does not have, under a
"spoti.pw" section in ESR settings (Sources/EeveeSpotify/Settings/Sections/SpotiPW/).

## Not compiled in (and why)

| Path upstream                       | Reason                                                              |
|-------------------------------------|---------------------------------------------------------------------|
| Features/AdBlock/* (implementation) | ESR ships its own ad blocking / Premium spoofing; the two must not both hook. Only AdBlock.h (declarations) and SGAdBlockStubs.m remain. |
| Features/NowPlaying/Lyrics.x        | ESR has its own lyrics stack (Sources/EeveeSpotify/Lyrics/).          |
| Features/Onboarding/*               | spoti.pw's welcome tour assumes its own settings entry; replaced by the ESR settings section. |
| Settings/SGModSettings.x            | Injects a "Mod Settings" row into Spotify's own settings and drawer; replaced by the ESR settings section. |
| Diagnostics/*                       | AutoFLEX (FLEX) inspector, dev tool, not needed in ESR builds.        |

## Changes vs upstream

- `Core/SGRuntime.h`: the iOS 26 / iOS 17 API forward-declarations are guarded with
  `__IPHONE_OS_VERSION_MAX_ALLOWED` checks, because ESR builds against the latest SDK
  (upstream pinned an old SDK instead).
- `Features/About/AboutSettings.m`, `Features/About/Signing.m`: references to the excluded
  Onboarding module removed (no welcome tour to re-open, no fix sheet to defer to it).
- `Features/Appearance/SearchField.x`: removed the unused Diagnostics import.
- `Features/Flags/SGFlagList.m`: a placeholder is committed; it is regenerated from the
  vanilla Spotify IPA by `Tools/SpotiPW/extract-flags.py` (build-ipa-local.sh and the IPA
  workflows run this automatically; `make spotipw-flags IPA=...` runs it by hand).
- `Tools/SpotiPW/extract-flags.py` output path points at this tree.
- `SpotiPWBootstrap.m` (outside this directory): registers the pages and exposes them to
  the SwiftUI settings; replaces the registration that lived in SGModSettings.x.

## Updating the vendored copy

```bash
git clone https://github.com/skopevoj/spoti.pw /tmp/spoti.pw
git -C /tmp/spoti.pw rev-parse HEAD > Sources/EeveeSpotifyC/SpotiPW/UPSTREAM_COMMIT
rsync -a --delete /tmp/spoti.pw/tweak/Sources/ Sources/EeveeSpotifyC/SpotiPW/
# then re-apply the exclusions and edits listed above, and re-run the flag extraction
```
