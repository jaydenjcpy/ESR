// Vendored from spoti.pw (github.com/skopevoj/spoti.pw), trimmed: only the declaration
// SearchField.x uses. The FLEX-backed implementations of SGScreenTree/SGDumpScreen are not
// compiled into ESR; SGIsDebugBuild is provided by SGDiagnosticsShims.m.
#import <Foundation/Foundation.h>

BOOL SGIsDebugBuild(void);
NSString *SGScreenTree(void);
void SGDumpScreen(NSString *reason);
