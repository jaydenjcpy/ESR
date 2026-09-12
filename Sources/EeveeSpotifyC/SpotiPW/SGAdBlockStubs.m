// Compatibility stubs for code vendored from spoti.pw (github.com/skopevoj/spoti.pw).
// EeveeSpotify ships its own ad blocking and Premium spoofing (EeveeAdBlockerExtended.x,
// EeveePremiumForce.x, ...), so spoti.pw's AdBlock module is not compiled in. A few vendored
// files reference its API (Features/Flags/Flags.x, Features/Flags/FlagPages.m,
// Settings/SGModPage.m); these neutral implementations keep them linkable while leaving
// ESR's implementations authoritative.
#import "Features/AdBlock/AdBlock.h"

NSArray<SGModSection *> *SGAdBlockSections(void) {
    return @[];
}

BOOL SGAdBlockForcesFlagOff(NSString *key) {
    return NO;
}
