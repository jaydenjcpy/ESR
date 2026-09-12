// Glue between EeveeSpotify and the code vendored from spoti.pw
// (github.com/skopevoj/spoti.pw, GPL-3.0). Upstream registered its pages and put its entry
// row into Spotify's settings from Settings/SGModSettings.x, which is not compiled in here —
// the settings UI is ESR's SwiftUI section instead. This file does the registration and
// exposes the page constructors to Swift (declared in include/Tweak.h).
#import "SpotiPW/Settings/SGPage.h"
#import "SpotiPW/Features/Appearance/Appearance.h"
#import "SpotiPW/Features/Home/Home.h"
#import "SpotiPW/Features/Playlist/Playlist.h"
#import "SpotiPW/Features/NowPlaying/NowPlaying.h"
#import "SpotiPW/Features/Navbar/Navbar.h"
#import "SpotiPW/Features/Gestures/Gestures.h"
#import "SpotiPW/Features/Flags/Flags.h"
#import "SpotiPW/Features/About/About.h"

void SpotiPWRegisterPages(void) {
    SGRegisterPages();
}

UIViewController *SpotiPWPage(NSString *page) {
    if ([page isEqualToString:@"appearance"])  return SGAppearanceSettingsPage();
    if ([page isEqualToString:@"home"])        return SGHomeSettingsPage();
    if ([page isEqualToString:@"playlist"])    return SGPlaylistSettingsPage();
    if ([page isEqualToString:@"player"])      return SGNowPlayingSettingsPage();
    if ([page isEqualToString:@"navbar"])      return SGNavbarSettingsPage();
    if ([page isEqualToString:@"gestures"])    return SGGesturesSettingsPage();
    if ([page isEqualToString:@"ads"])         return SGAdsSettingsPage();
    if ([page isEqualToString:@"labs"])        return SGLabsPage();
    if ([page isEqualToString:@"flags"])       return SGAllFlagsPage();
    if ([page isEqualToString:@"mod"])         return SGAboutPage();
    return nil;
}

// Not a Logos file (plain .m), so a constructor attribute replaces %ctor. Registration is
// cheap, idempotent, and also performed by the SwiftUI side before use — this is a safety net.
__attribute__((constructor)) static void SpotiPWBootstrapInit(void) {
    SpotiPWRegisterPages();
}
