#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

void EeveeSBInvokeSeekDouble(id target, SEL selector, double argument);
NSString *EeveeJBRootPath(NSString *path);

// spoti.pw (vendored under Sources/EeveeSpotifyC/SpotiPW) — see SpotiPWBootstrap.m.
// Registers the vendored pages with Spotify's page protocol (needed before any of the
// SpotiPWPage pages are pushed); idempotent, but call it once before use.
void SpotiPWRegisterPages(void);
// One of: "appearance", "home", "playlist", "player", "navbar", "gestures",
// "ads", "labs", "flags", "mod". Returns a freshly built view controller, or nil.
UIViewController * _Nullable SpotiPWPage(NSString *page);

NS_ASSUME_NONNULL_END
