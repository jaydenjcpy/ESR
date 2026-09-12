// Shims for code vendored from spoti.pw (github.com/skopevoj/spoti.pw) whose upstream
// implementation lives in the FLEX-backed Diagnostics module, which is not compiled into
// EeveeSpotify (see VENDORED.md). ESR builds are never "FLEX debug builds", so the
// debug-gated logging in Features/Appearance/SearchField.x simply stays off.
#import "Diagnostics/Diagnostics.h"

BOOL SGIsDebugBuild(void) {
    return NO;
}
