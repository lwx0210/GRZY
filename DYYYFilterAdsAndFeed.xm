#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "DYYYToast.h"
#import "DYYYUtils.h"
#import "AwemeHeaders.h"

%hook MTKView

- (void)layoutSubviews {
	%orig;
	NSString *colorHex = [[NSUserDefaults standardUserDefaults] objectForKey:@"DYYYVideoBGColor"];
	if (colorHex && colorHex.length > 0) {
		UIColor *customColor = [DYYYUtils colorWithHexString:colorHex];
		if (customColor) {
			self.backgroundColor = customColor;
		}
	}
}

%end

// 拦截开屏广告
%hook BDASplashControllerView
+ (id)alloc {
	BOOL noAds = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYNoAds"];
	if (noAds) {
		return nil;
	}
	return %orig;
}
%end


// 去除启动视频广告
%hook AWEAwesomeSplashFeedCellOldAccessoryView

- (id)ddExtraView {
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYNoAds"]) {
		return NULL;
	}

	return %orig;
}

%end

// 去广告功能
%hook AwemeAdManager
- (void)showAd {
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYNoAds"])
		return;
	%orig;
}
%end



%ctor {
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYUserAgreementAccepted"]) {
		%init;
	}
}
