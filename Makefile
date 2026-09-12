TARGET := iphone:clang:latest:14.0
INSTALL_TARGET_PROCESSES = Spotify
ARCHS = arm64

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = EeveeSpotify

REPO_SLUG ?= $(shell git remote get-url origin 2>/dev/null | sed -E 's|.*github\.com[:/]([^/]+/[^/.]+)(\.git)?$$|\1|')
REPO_SLUG_FINAL := $(if $(REPO_SLUG),$(REPO_SLUG),jaydenjcpy/EeveeSpotifyReincarnated)

BRANCH_NAME ?= $(shell git rev-parse --abbrev-ref HEAD 2>/dev/null)
BRANCH_NAME_FINAL := $(if $(BRANCH_NAME),$(BRANCH_NAME),Master)

$(shell mkdir -p Sources/EeveeSpotify/Generated)
$(shell printf 'enum GeneratedConfig {\n    static let repoSlug = "%s"\n    static let branchName = "%s"\n}\n' "$(REPO_SLUG_FINAL)" "$(BRANCH_NAME_FINAL)" > Sources/EeveeSpotify/Generated/RepoSlug.swift)

# spoti.pw (vendored under Sources/EeveeSpotifyC/SpotiPW) ships Logos .x files, so
# ObjC sources are found by .m/.x/.c/.mm/.cpp. The vendored code includes its headers as
# "Core/SGCore.h" etc. relative to the SpotiPW root, hence the extra include path.
SPOTIPW_VERSION := $(shell sed -n 's/^Version: //p' Sources/EeveeSpotifyC/SpotiPW/control)
SPOTIPW_VERSION_FINAL := $(if $(SPOTIPW_VERSION),$(SPOTIPW_VERSION),0.0.0)

EeveeSpotify_FILES = $(shell find Sources/EeveeSpotify -name '*.swift') $(shell find Sources/EeveeSpotifyC \( -name '*.m' -o -name '*.x' -o -name '*.c' -o -name '*.mm' -o -name '*.cpp' \))
EeveeSpotify_SWIFTFLAGS = -ISources/EeveeSpotifyC/include -Osize
EeveeSpotify_EXTRA_FRAMEWORKS = EeveeSwiftProtobuf
EeveeSpotify_CFLAGS = -fobjc-arc -ISources/EeveeSpotifyC/include -ISources/EeveeSpotifyC/SpotiPW -Os -DSG_VERSION=\"$(SPOTIPW_VERSION_FINAL)\"
EeveeSpotify_FRAMEWORKS = UIKit QuartzCore
# The dylib is injected into sideloaded IPAs where libsubstrate does not exist, so the
# vendored spoti.pw Logos hooks must use the internal (runtime-swizzling) generator.
EeveeSpotify_LOGOS_DEFAULT_GENERATOR = internal

# RootHide's compatibility implementation of libroot resolves jailbreak paths
# through libroothide at runtime. Rootless builds continue to use libroot.
ifeq ($(THEOS_PACKAGE_SCHEME),roothide)
EeveeSpotify_SWIFTFLAGS += -D ROOTHIDE
EeveeSpotify_LDFLAGS += -lroothide -Xlinker -rpath -Xlinker @loader_path/.jbroot/Library/Frameworks
else
EeveeSpotify_LDFLAGS += -lroot
endif

# Sideload compatibility (keychain redirect, group containers, CloudKit) is
# handled out-of-process by modules/zxPluginsInject — LC-injected via ipapatch
# in build-ipa-local.sh and the GitHub workflow. No flags needed here.

include $(THEOS_MAKE_PATH)/tweak.mk

internal-stage::
	# Bundle EeveeSwiftProtobuf.framework into the package. Renamed from
	# SwiftProtobuf so the @objc class names don't collide with the
	# SwiftProtobuf statically embedded in SpotifyShared.framework.
	mkdir -p $(THEOS_STAGING_DIR)/Library/Frameworks
	cp -r $(THEOS)/lib/iphone/$(or $(THEOS_PACKAGE_SCHEME),rootless)/EeveeSwiftProtobuf.framework $(THEOS_STAGING_DIR)/Library/Frameworks/
	# Compile the karaoke background Metal shader into a .metallib and
	# stage it next to the tweak binary so device.makeLibrary(filepath:)
	# can load it at runtime (Theos's tweak.mk has no built-in Metal
	# shader compilation step the way an Xcode app target's build phases
	# do, so this is done by hand here — UNTESTED, no Theos/Metal
	# toolchain was available to verify this actually produces a working
	# .metallib or that the staged path is correct; if `make package`
	# fails at this step or the shader doesn't load at runtime, check
	# this block first).
	xcrun -sdk iphoneos metal -c Sources/EeveeSpotify/Karaoke/KaraokeBackgroundShader.metal \
		-o $(THEOS_OBJ_DIR)/KaraokeBackgroundShader.air
	xcrun -sdk iphoneos metallib $(THEOS_OBJ_DIR)/KaraokeBackgroundShader.air \
		-o $(THEOS_STAGING_DIR)/Library/MobileSubstrate/DynamicLibraries/KaraokeBackgroundShader.metallib

# Build EeveeSwiftProtobuf.framework from apple/swift-protobuf source. Run
# this once before `make package`. Re-run if SWIFTPROTOBUF_VERSION changes
# or `swift --version` jumps a major.
build-eeveeswiftprotobuf:
	Tools/SwiftProtobufBuild/build-eeveeswiftprotobuf.sh

# Regenerate the spoti.pw remote-config flag table from a decrypted Spotify IPA.
# Usage: make spotipw-flags IPA=path/to/Spotify-Decrypted.ipa
# build-ipa-local.sh and the IPA workflows run this automatically against the IPA
# being built; .deb-only builds keep the committed placeholder (empty All flags page).
spotipw-flags:
	@[ -n "$(IPA)" ] || { echo "usage: make spotipw-flags IPA=path/to/Spotify-Decrypted.ipa" >&2; exit 1; }
	python3 Tools/SpotiPW/extract-flags.py "$(IPA)"
