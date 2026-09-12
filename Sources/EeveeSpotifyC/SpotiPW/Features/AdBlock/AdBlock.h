// Vendored from spoti.pw (github.com/skopevoj/spoti.pw), reduced to the declarations the
// vendored code still references. The AdBlock implementation itself is NOT compiled into
// EeveeSpotify — ESR ships its own ad blocking and Premium spoofing
// (EeveeAdBlockerExtended.x, EeveePremiumForce.x, AdServices hooks, ...), which stay
// authoritative. SGAdBlockStubs.m provides neutral implementations of the two symbols below.
#import <Foundation/Foundation.h>

@class SGModSection;

// Empty: ESR's own ad blocking covers this, and nothing in the vendored settings pushes it.
NSArray<SGModSection *> *SGAdBlockSections(void);
// Always NO: ESR's ad blocking does not force remote-config flags off.
BOOL SGAdBlockForcesFlagOff(NSString *key);
