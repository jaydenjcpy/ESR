// Declarations the SDK Theos builds against does not have: iOS 26 API and private UIKit.
// Everything here is resolved at runtime; a call site checks respondsToSelector: first.
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

// EeveeSpotify builds against the latest SDK (unlike upstream spoti.pw, which pinned iOS 16.5
// because these declarations predate the public API). Everything guarded below is public API in
// newer SDKs; redeclaring it would be a duplicate-interface error, so it is only declared when the
// SDK in use predates it.
#if __IPHONE_OS_VERSION_MAX_ALLOWED < 260000
@interface UIGlassEffect : UIVisualEffect
+ (instancetype)effectWithStyle:(NSInteger)style;
@property (nonatomic, copy) UIColor *tintColor;
@property (nonatomic, getter=isInteractive) BOOL interactive;
@end
#endif

@interface NSObject (SGiOS26)
+ (id)capsuleConfiguration;
+ (id)configurationWithUniformRadius:(id)radius;
+ (id)fixedRadius:(CGFloat)radius;
- (void)setCornerConfiguration:(id)configuration;
@end

@interface UIView (SGPrivate)
- (NSString *)recursiveDescription;
@end

@interface UIViewController (SGPrivate)
- (NSString *)_printHierarchy;
@end

@interface UIButtonConfiguration (SGiOS26)
+ (instancetype)glassButtonConfiguration;
+ (instancetype)prominentGlassButtonConfiguration;
@end

#if __IPHONE_OS_VERSION_MAX_ALLOWED < 170000
@interface UIImageView (SGiOS17)
- (void)addSymbolEffect:(id)effect;
@end

@interface NSObject (SGiOS17)
+ (id)effect;   // NSSymbolBounceEffect and the other symbol effects
@end
#endif
