//
//  DYYY
//
//  Copyright (c) 2024 huami. All rights reserved.
//  Channel: @huamidev
//  Created on: 2024/10/04
//
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

#import "AwemeHeaders.h"
#import "CityManager.h"
#import "DYYYBottomAlertView.h"
#import "DYYYManager.h"

#import "DYYYConstants.h"
#import "DYYYSettingViewController.h"
#import "DYYYToast.h"
#import "DYYYCdyy.h"
#import "DYYYUtils.h"

// 关闭不可见水印
%hook AWEHPChannelInvisibleWaterMarkModel

- (BOOL)isEnter {
	return NO;
}

- (BOOL)isAppear {
	return NO;
}

%end

//游戏作弊声明
NSArray<NSString *> *diceImageURLs = @[@"url1", @"url2"];
NSArray<NSString *> *rpsImageURLs = @[@"url1", @"url2"];

UIViewController *ViewControllerForView(UIView *view) {
    UIResponder *responder = view;
    while (responder && ![responder isKindOfClass:[UIViewController class]]) {
        responder = [responder nextResponder];
    }
    return (UIViewController *)responder;
}

typedef NS_ENUM(NSInteger, GameType) {
    GameTypeDice,
    GameTypeRPS
};

void ShowGameSelectorAlert(UIViewController *presentingVC, GameType type, void (^onSelected)(NSInteger selectedIndex));

void ShowGameSelectorAlert(UIViewController *presentingVC, GameType type, void (^onSelected)(NSInteger selectedIndex)) {
    NSString *title = (type == GameTypeDice) ? @"选择骰子点数" : @"选择猜拳类型";
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    NSArray<NSString *> *options;
    if (type == GameTypeDice) {
        options = @[@"1 点", @"2 点", @"3 点", @"4 点", @"5 点", @"6 点", @"随机"];
    } else {
        options = @[@"石头", @"布", @"剪刀", @"随机"];
    }

    for (NSInteger i = 0; i < options.count; i++) {
        NSString *optionTitle = options[i];
        UIAlertAction *action = [UIAlertAction actionWithTitle:optionTitle
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * _Nonnull action) {

            [[NSUserDefaults standardUserDefaults] synchronize];
            if (onSelected) onSelected(i);
        }];
        [alert addAction:action];
    }

    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消"
                                                     style:UIAlertActionStyleCancel
                                                   handler:^(UIAlertAction * _Nonnull action) {
        if (onSelected) onSelected(-1);
    }];
    [alert addAction:cancel];

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        alert.popoverPresentationController.sourceView = presentingVC.view;
        alert.popoverPresentationController.sourceRect = CGRectMake(presentingVC.view.bounds.size.width/2, 
                                                                   presentingVC.view.bounds.size.height/2, 
                                                                   1, 1);
        alert.popoverPresentationController.permittedArrowDirections = 0;
    }

    if (presentingVC) {
        [presentingVC presentViewController:alert animated:YES completion:nil];
    }
}
//声明结束

//游戏作弊
%hook AWEIMEmoticonInteractivePage

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];

    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYGameCheat"]) {
        %orig;
        return;
    }

    UIViewController *vc = ViewControllerForView(collectionView);

    if ([cell.accessibilityLabel isEqualToString:@"摇骰子"]) {
        ShowGameSelectorAlert(vc, GameTypeDice, ^(NSInteger selectedIndex) {
            if (selectedIndex >= 0) {
                [[NSUserDefaults standardUserDefaults] setInteger:selectedIndex + 1 forKey:@"selectedDicePoint"];
                [[NSUserDefaults standardUserDefaults] synchronize];

                %orig;
            }
        });
        return;
    }

    if ([cell.accessibilityLabel isEqualToString:@"猜拳"]) {
        ShowGameSelectorAlert(vc, GameTypeRPS, ^(NSInteger selectedIndex) {
            if (selectedIndex >= 0) {
                [[NSUserDefaults standardUserDefaults] setInteger:selectedIndex forKey:@"selectedRPS"];
                [[NSUserDefaults standardUserDefaults] synchronize];

                %orig;
            }
        });
        return;
    }

    %orig;
}

%end

%hook TIMXOSendMessage

- (void)setContent:(id)arg1 {

    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYGameCheat"]) {
        %orig(arg1); 
        return;
    }

    NSMutableDictionary *mutableContent = [arg1 mutableCopy];
    if ([mutableContent isKindOfClass:[NSMutableDictionary class]]) {
        NSNumber *resourceType = mutableContent[@"resource_type"];
        NSNumber *stickerType = mutableContent[@"sticker_type"];
        NSString *displayName = mutableContent[@"display_name"];

        // 替换骰子图像
        if ([resourceType intValue] == 5 &&
            [stickerType intValue] == 12 &&
            [displayName isEqualToString:@"摇骰子"]) {

            NSMutableDictionary *urlDict = [mutableContent[@"url"] mutableCopy];
            if ([urlDict isKindOfClass:[NSMutableDictionary class]]) {
                NSInteger selectedDicePoint = [[NSUserDefaults standardUserDefaults] integerForKey:@"selectedDicePoint"];
                if (selectedDicePoint > 0 && selectedDicePoint <= 6) {
                    NSString *selectedURL = diceImageURLs[selectedDicePoint - 1];
                    urlDict[@"url_list"] = @[selectedURL];
                    mutableContent[@"url"] = urlDict;
                    
                }
            }
        }

        // 替换猜拳图像
        if ([resourceType intValue] == 5 &&
            [stickerType intValue] == 12 &&
            [displayName isEqualToString:@"猜拳"]) {

            NSMutableDictionary *urlDict = [mutableContent[@"url"] mutableCopy];
            if ([urlDict isKindOfClass:[NSMutableDictionary class]]) {
                NSInteger selectedRPS = [[NSUserDefaults standardUserDefaults] integerForKey:@"selectedRPS"];
                if (selectedRPS >= 0 && selectedRPS <= 2) {
                    NSString *selectedURL = rpsImageURLs[selectedRPS];
                    urlDict[@"url_list"] = @[selectedURL];
                    mutableContent[@"url"] = urlDict;
                    
                }
            }
        }
    }

    %orig(mutableContent);
}

%end

//默契回答
%hook AWEIMExchangeAnswerMessage

- (void)setUnlocked:(BOOL)unlocked {

BOOL enabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYtacitanswer"];

            if (enabled) {
           %orig(YES);
           } else {

          %orig(unlocked);

      }
}

- (BOOL)unlocked {

BOOL enabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYtacitanswer"];

          if (enabled) {
          return YES;
      }
   return %orig;
}

%end

// 长按复制个人简介
%hook AWEProfileMentionLabel

- (void)layoutSubviews {
	%orig;

	if (![[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYBioCopyText"]) {
		return;
	}

	BOOL hasLongPressGesture = NO;
	for (UIGestureRecognizer *gesture in self.gestureRecognizers) {
		if ([gesture isKindOfClass:[UILongPressGestureRecognizer class]]) {
			hasLongPressGesture = YES;
			break;
		}
	}

	if (!hasLongPressGesture) {
		UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
		longPressGesture.minimumPressDuration = 0.5;
		[self addGestureRecognizer:longPressGesture];
		self.userInteractionEnabled = YES;
	}
}

%new
- (void)handleLongPress:(UILongPressGestureRecognizer *)gesture {
	if (gesture.state == UIGestureRecognizerStateBegan) {
		NSString *bioText = self.text;
		if (bioText && bioText.length > 0) {
			[[UIPasteboard generalPasteboard] setString:bioText];
			[DYYYToast showSuccessToastWithMessage:@"个人简介已复制"];
		}
	}
}

%end

//全屏修复
%hook AWECommentInputViewController

- (UIView *)view {
	UIView *originalView = %orig;

	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYisEnableFullScreen"]) {	
		for (UIView *subview in originalView.subviews) {
			[subview setBackgroundColor:[UIColor clearColor]];
		}	
	}

	return originalView;
}

%end

//最高画质
%hook AWEVideoModel

- (AWEURLModel *)playURL {
	if (![[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYEnableVideoHighestQuality"]) {
		return %orig;
	}

	// 获取比特率模型数组
	NSArray *bitrateModels = [self bitrateModels];
	if (!bitrateModels || bitrateModels.count == 0) {
		return %orig;
	}

	// 查找比特率最高的模型
	id highestBitrateModel = nil;
	NSInteger highestBitrate = 0;

	for (id model in bitrateModels) {
		NSInteger bitrate = 0;
		BOOL validModel = NO;

		if ([model isKindOfClass:NSClassFromString(@"AWEVideoBSModel")]) {
			id bitrateValue = [model bitrate];
			if (bitrateValue) {
				bitrate = [bitrateValue integerValue];
				validModel = YES;
			}
		}

		if (validModel && bitrate > highestBitrate) {
			highestBitrate = bitrate;
			highestBitrateModel = model;
		}
	}

	// 如果找到了最高比特率模型，获取其播放地址
	if (highestBitrateModel) {
		id playAddr = [highestBitrateModel valueForKey:@"playAddr"];
		if (playAddr && [playAddr isKindOfClass:%c(AWEURLModel)]) {
			return playAddr;
		}
	}

	return %orig;
}

- (NSArray *)bitrateModels {

	NSArray *originalModels = %orig;

	if (![[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYEnableVideoHighestQuality"]) {
		return originalModels;
	}

	if (originalModels.count == 0) {
		return originalModels;
	}

	// 查找比特率最高的模型
	id highestBitrateModel = nil;
	NSInteger highestBitrate = 0;

	for (id model in originalModels) {

		NSInteger bitrate = 0;
		BOOL validModel = NO;

		if ([model isKindOfClass:NSClassFromString(@"AWEVideoBSModel")]) {
			id bitrateValue = [model bitrate];
			if (bitrateValue) {
				bitrate = [bitrateValue integerValue];
				validModel = YES;
			}
		}

		if (validModel) {
			if (bitrate > highestBitrate) {
				highestBitrate = bitrate;
				highestBitrateModel = model;
			}
		}
	}

	if (highestBitrateModel) {
		return @[ highestBitrateModel ];
	}

	return originalModels;
}

%end

//二次关注
%hook AWEPlayInteractionUserAvatarElement
- (void)onFollowViewClicked:(UITapGestureRecognizer *)gesture {
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYfollowTips"]) {
		// 获取用户信息
		AWEUserModel *author = nil;
		NSString *nickname = @"";
		NSString *signature = @"";
		NSString *avatarURL = @"";

		if ([self respondsToSelector:@selector(model)]) {
			id model = [self model];
			if ([model isKindOfClass:NSClassFromString(@"AWEAwemeModel")]) {
				author = [model valueForKey:@"author"];
			}
		}

		if (author) {
			// 获取昵称
			if ([author respondsToSelector:@selector(nickname)]) {
				nickname = [author valueForKey:@"nickname"] ?: @"";
			}

			// 获取签名
			if ([author respondsToSelector:@selector(signature)]) {
				signature = [author valueForKey:@"signature"] ?: @"";
			}

			// 获取头像URL
			if ([author respondsToSelector:@selector(avatarThumb)]) {
				AWEURLModel *avatarThumb = [author valueForKey:@"avatarThumb"];
				if (avatarThumb && avatarThumb.originURLList.count > 0) {
					avatarURL = avatarThumb.originURLList.firstObject;
				}
			}
		}

		NSMutableString *messageContent = [NSMutableString string];
		if (signature.length > 0) {
			[messageContent appendFormat:@"%@", signature];
		}

		NSString *title = nickname.length > 0 ? nickname : @"关注确认";

		[DYYYBottomAlertView showAlertWithTitle:title
						message:messageContent
					      avatarURL:avatarURL
				       cancelButtonText:@"取消"
				      confirmButtonText:@"关注"
					   cancelAction:nil
					    closeAction:nil
					  confirmAction:^{
					    %orig(gesture);
					  }];
	} else {
		%orig;
	}
}

%end

%hook AWEPlayInteractionUserAvatarFollowController
- (void)onFollowViewClicked:(UITapGestureRecognizer *)gesture {
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYfollowTips"]) {
		// 获取用户信息
		AWEUserModel *author = nil;
		NSString *nickname = @"";
		NSString *signature = @"";
		NSString *avatarURL = @"";

		if ([self respondsToSelector:@selector(model)]) {
			id model = [self model];
			if ([model isKindOfClass:NSClassFromString(@"AWEAwemeModel")]) {
				author = [model valueForKey:@"author"];
			}
		}

		if (author) {
			// 获取昵称
			if ([author respondsToSelector:@selector(nickname)]) {
				nickname = [author valueForKey:@"nickname"] ?: @"";
			}

			// 获取签名
			if ([author respondsToSelector:@selector(signature)]) {
				signature = [author valueForKey:@"signature"] ?: @"";
			}

			// 获取头像URL
			if ([author respondsToSelector:@selector(avatarThumb)]) {
				AWEURLModel *avatarThumb = [author valueForKey:@"avatarThumb"];
				if (avatarThumb && avatarThumb.originURLList.count > 0) {
					avatarURL = avatarThumb.originURLList.firstObject;
				}
			}
		}

		NSMutableString *messageContent = [NSMutableString string];
		if (signature.length > 0) {
			[messageContent appendFormat:@"%@", signature];
		}

		NSString *title = nickname.length > 0 ? nickname : @"关注确认";

		[DYYYBottomAlertView showAlertWithTitle:title
						message:messageContent
					      avatarURL:avatarURL
				       cancelButtonText:@"取消"
				      confirmButtonText:@"关注"
					   cancelAction:nil
					    closeAction:nil
					  confirmAction:^{
					    %orig(gesture);
					  }];
	} else {
		%orig;
	}
}

%end

%hook AWENormalModeTabBarGeneralPlusButton
+ (id)button {
	BOOL isHiddenJia = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYisHiddenJia"];
	if (isHiddenJia) {
		return nil;
	}
	return %orig;
}
%end

//纯净模式
%hook AWEFeedContainerContentView
- (void)setAlpha:(CGFloat)alpha {
	// 纯净模式功能
        static dispatch_source_t timer = nil;
        static int attempts = 0;
        static BOOL pureModeSet = NO;
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYisEnablePure"]) {
                %orig(0.0);
                if (pureModeSet) {
                        return;
                }
                if (!timer) {
                        timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
                        dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC, 0);
                        dispatch_source_set_event_handler(timer, ^{
                                UIWindow *keyWindow = [DYYYUtils getActiveWindow];
                                if (keyWindow && keyWindow.rootViewController) {
                                        UIViewController *feedVC = findViewControllerOfClass(keyWindow.rootViewController, NSClassFromString(@"AWEFeedTableViewController"));
                                        if (feedVC) {
                                                [feedVC setValue:@YES forKey:@"pureMode"];
                                                pureModeSet = YES;
                                                dispatch_source_cancel(timer);
                                                timer = nil;
                                                attempts = 0;
                                                return;
                                        }
                                }
                                attempts++;
                                if (attempts >= 10) {
                                        dispatch_source_cancel(timer);
                                        timer = nil;
                                        attempts = 0;
                                }
                        });
                        dispatch_resume(timer);
                }
                return;
        } else {
                if (timer) {
                        dispatch_source_cancel(timer);
                        timer = nil;
                }
                attempts = 0;
                pureModeSet = NO;
        }
	// 原来的透明度设置逻辑，保持不变
	NSString *transparentValue = [[NSUserDefaults standardUserDefaults] objectForKey:@"DYYYtopbartransparent"];
	if (transparentValue && transparentValue.length > 0) {
		CGFloat alphaValue = [transparentValue floatValue];
		if (alphaValue >= 0.0 && alphaValue <= 1.0) {
			CGFloat finalAlpha = (alphaValue < 0.011) ? 0.011 : alphaValue;
			%orig(finalAlpha);
		} else {
			%orig(1.0);
		}
	} else {
		%orig(1.0);
	}
}
%end

//顶栏透明度
%hook AWEFeedTopBarContainer
- (void)layoutSubviews {
	%orig;
	applyTopBarTransparency(self);
}
- (void)didMoveToSuperview {
	%orig;
	applyTopBarTransparency(self);
}
- (void)setAlpha:(CGFloat)alpha {
	NSString *transparentValue = [[NSUserDefaults standardUserDefaults] objectForKey:@"DYYYtopbartransparent"];
	if (transparentValue && transparentValue.length > 0) {
		CGFloat alphaValue = [transparentValue floatValue];
		if (alphaValue >= 0.0 && alphaValue <= 1.0) {
			CGFloat finalAlpha = (alphaValue < 0.011) ? 0.011 : alphaValue;
			%orig(finalAlpha);
		} else {
			%orig(1.0);
		}
	} else {
		%orig(1.0);
	}
}
%end

// 设置修改顶栏标题
%hook AWEHPTopTabItemTextContentView

- (void)layoutSubviews {
	%orig;

	NSString *topTitleConfig = [[NSUserDefaults standardUserDefaults] objectForKey:@"DYYYModifyTopTabText"];
	if (topTitleConfig.length == 0)
		return;

	NSArray *titlePairs = [topTitleConfig componentsSeparatedByString:@"#"];

	NSString *accessibilityLabel = nil;
	if ([self.superview respondsToSelector:@selector(accessibilityLabel)]) {
		accessibilityLabel = self.superview.accessibilityLabel;
	}
	if (accessibilityLabel.length == 0)
		return;

	for (NSString *pair in titlePairs) {
		NSArray *components = [pair componentsSeparatedByString:@"="];
		if (components.count != 2)
			continue;

		NSString *originalTitle = components[0];
		NSString *newTitle = components[1];

		if ([accessibilityLabel isEqualToString:originalTitle]) {
			if ([self respondsToSelector:@selector(setContentText:)]) {
				[self setContentText:newTitle];
			} else {
				[self setValue:newTitle forKey:@"contentText"];
			}
			break;
		}
	}
}

%end

//弹幕
%hook AWEDanmakuContentLabel
- (void)setTextColor:(UIColor *)textColor {
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYEnableDanmuColor"]) {
		NSString *danmuColor = [[NSUserDefaults standardUserDefaults] objectForKey:@"DYYYdanmuColor"];

		if ([danmuColor.lowercaseString isEqualToString:@"random"] || [danmuColor.lowercaseString isEqualToString:@"#random"]) {
			textColor = [UIColor colorWithRed:(arc4random_uniform(256)) / 255.0
						    green:(arc4random_uniform(256)) / 255.0
						     blue:(arc4random_uniform(256)) / 255.0
						    alpha:CGColorGetAlpha(textColor.CGColor)];
			self.layer.shadowOffset = CGSizeZero;
			self.layer.shadowOpacity = 0.0;
		} else if ([danmuColor hasPrefix:@"#"]) {
			textColor = [self colorFromHexString:danmuColor baseColor:textColor];
			self.layer.shadowOffset = CGSizeZero;
			self.layer.shadowOpacity = 0.0;
		} else {
			textColor = [self colorFromHexString:@"#FFFFFF" baseColor:textColor];
		}
	}

	%orig(textColor);
}

%new
- (UIColor *)colorFromHexString:(NSString *)hexString baseColor:(UIColor *)baseColor {
	if ([hexString hasPrefix:@"#"]) {
		hexString = [hexString substringFromIndex:1];
	}
	if ([hexString length] != 6) {
		return [baseColor colorWithAlphaComponent:1];
	}
	unsigned int red, green, blue;
	[[NSScanner scannerWithString:[hexString substringWithRange:NSMakeRange(0, 2)]] scanHexInt:&red];
	[[NSScanner scannerWithString:[hexString substringWithRange:NSMakeRange(2, 2)]] scanHexInt:&green];
	[[NSScanner scannerWithString:[hexString substringWithRange:NSMakeRange(4, 2)]] scanHexInt:&blue];

	if (red < 128 && green < 128 && blue < 128) {
		return [UIColor whiteColor];
	}

	return [UIColor colorWithRed:(red / 255.0) green:(green / 255.0) blue:(blue / 255.0) alpha:CGColorGetAlpha(baseColor.CGColor)];
}
%end


%hook AWEDanmakuItemTextInfo
- (void)setDanmakuTextColor:(id)arg1 {

	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYEnableDanmuColor"]) {
		NSString *danmuColor = [[NSUserDefaults standardUserDefaults] objectForKey:@"DYYYdanmuColor"];

		if ([danmuColor.lowercaseString isEqualToString:@"random"] || [danmuColor.lowercaseString isEqualToString:@"#random"]) {
			arg1 = [UIColor colorWithRed:(arc4random_uniform(256)) / 255.0 green:(arc4random_uniform(256)) / 255.0 blue:(arc4random_uniform(256)) / 255.0 alpha:1.0];
		} else if ([danmuColor hasPrefix:@"#"]) {
			arg1 = [self colorFromHexStringForTextInfo:danmuColor];
		} else {
			arg1 = [self colorFromHexStringForTextInfo:@"#FFFFFF"];
		}
	}

	%orig(arg1);
}

%new
- (UIColor *)colorFromHexStringForTextInfo:(NSString *)hexString {
	if ([hexString hasPrefix:@"#"]) {
		hexString = [hexString substringFromIndex:1];
	}
	if ([hexString length] != 6) {
		return [UIColor whiteColor];
	}
	unsigned int red, green, blue;
	[[NSScanner scannerWithString:[hexString substringWithRange:NSMakeRange(0, 2)]] scanHexInt:&red];
	[[NSScanner scannerWithString:[hexString substringWithRange:NSMakeRange(2, 2)]] scanHexInt:&green];
	[[NSScanner scannerWithString:[hexString substringWithRange:NSMakeRange(4, 2)]] scanHexInt:&blue];

	if (red < 128 && green < 128 && blue < 128) {
		return [UIColor whiteColor];
	}

	return [UIColor colorWithRed:(red / 255.0) green:(green / 255.0) blue:(blue / 255.0) alpha:1.0];
}
%end

//弹幕透明
%hook XIGDanmakuPlayerView

- (id)initWithFrame:(CGRect)frame {
	id orig = %orig;

	((UIView *)orig).tag = DYYY_IGNORE_GLOBAL_ALPHA_TAG;

	return orig;
}

- (void)setAlpha:(CGFloat)alpha {
	if (DYYYGetBool(@"DYYYCommentShowDanmaku") && alpha == 0.0) {
		return;
	} else {
		%orig(alpha);
	}
}

%end

%hook DDanmakuPlayerView

- (void)setAlpha:(CGFloat)alpha {
	if (DYYYGetBool(@"DYYYCommentShowDanmaku") && alpha == 0.0) {
		return;
	} else {
		%orig(alpha);
	}
}

%end

%hook AWEMarkView

- (void)layoutSubviews {
	%orig;

	UIViewController *vc = [self firstAvailableUIViewController];

	if ([vc isKindOfClass:%c(AWEPlayInteractionViewController)]) {
		if (self.markLabel) {
			self.markLabel.textColor = [UIColor whiteColor];
		}
	}
}

%end

%group DYYYSettingsGesture

%hook UIWindow
- (instancetype)initWithFrame:(CGRect)frame {
	UIWindow *window = %orig(frame);
	if (window) {
		UILongPressGestureRecognizer *doubleFingerLongPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleFingerLongPressGesture:)];
		doubleFingerLongPressGesture.numberOfTouchesRequired = 2;
		[window addGestureRecognizer:doubleFingerLongPressGesture];
	}
	return window;
}

%new
- (void)handleDoubleFingerLongPressGesture:(UILongPressGestureRecognizer *)gesture {
	if (gesture.state == UIGestureRecognizerStateBegan) {
		UIViewController *rootViewController = self.rootViewController;
		if (rootViewController) {
			UIViewController *settingVC = [[DYYYSettingViewController alloc] init];

			if (settingVC) {
				BOOL isIPad = UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad;
				if (@available(iOS 15.0, *)) {
					if (!isIPad) {
						settingVC.modalPresentationStyle = UIModalPresentationPageSheet;
					} else {
						settingVC.modalPresentationStyle = UIModalPresentationFullScreen;
					}
				} else {
					settingVC.modalPresentationStyle = UIModalPresentationFullScreen;
				}

				if (settingVC.modalPresentationStyle == UIModalPresentationFullScreen) {
					UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeSystem];
					[closeButton setTitle:@"关闭" forState:UIControlStateNormal];
					closeButton.translatesAutoresizingMaskIntoConstraints = NO;

					[settingVC.view addSubview:closeButton];

					[NSLayoutConstraint activateConstraints:@[
						[closeButton.trailingAnchor constraintEqualToAnchor:settingVC.view.trailingAnchor constant:-10],
						[closeButton.topAnchor constraintEqualToAnchor:settingVC.view.topAnchor constant:40], [closeButton.widthAnchor constraintEqualToConstant:80],
						[closeButton.heightAnchor constraintEqualToConstant:40]
					]];

					[closeButton addTarget:self action:@selector(closeSettings:) forControlEvents:UIControlEventTouchUpInside];
				}

				UIView *handleBar = [[UIView alloc] init];
				handleBar.backgroundColor = [UIColor whiteColor];
				handleBar.layer.cornerRadius = 2.5;
				handleBar.translatesAutoresizingMaskIntoConstraints = NO;
				[settingVC.view addSubview:handleBar];

				[NSLayoutConstraint activateConstraints:@[
					[handleBar.centerXAnchor constraintEqualToAnchor:settingVC.view.centerXAnchor],
					[handleBar.topAnchor constraintEqualToAnchor:settingVC.view.topAnchor constant:8], [handleBar.widthAnchor constraintEqualToConstant:40],
					[handleBar.heightAnchor constraintEqualToConstant:5]
				]];

				[rootViewController presentViewController:settingVC animated:YES completion:nil];
			}
		}
	}
}

%new
- (void)closeSettings:(UIButton *)button {
	[button.superview.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
}
%end

%end

%hook AWEBaseListViewController
- (void)viewDidLayoutSubviews {
	%orig;
	[self applyBlurEffectIfNeeded];
}

- (void)viewDidAppear:(BOOL)animated {
	%orig;
	[self applyBlurEffectIfNeeded];
}

- (void)viewWillAppear:(BOOL)animated {
	%orig;
	[self applyBlurEffectIfNeeded];
}

%new
- (void)applyBlurEffectIfNeeded {
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYisEnableCommentBlur"] &&
	    [self isKindOfClass:NSClassFromString(@"AWECommentPanelContainerSwiftImpl.CommentContainerInnerViewController")]) {

		self.view.backgroundColor = [UIColor clearColor];
		for (UIView *subview in self.view.subviews) {
			if (![subview isKindOfClass:[UIVisualEffectView class]]) {
				subview.backgroundColor = [UIColor clearColor];
			}
		}

		UIVisualEffectView *existingBlurView = nil;
		for (UIView *subview in self.view.subviews) {
			if ([subview isKindOfClass:[UIVisualEffectView class]] && subview.tag == 999) {
				existingBlurView = (UIVisualEffectView *)subview;
				break;
			}
		}

		BOOL isDarkMode = [DYYYUtils isDarkMode];

		UIBlurEffectStyle blurStyle = isDarkMode ? UIBlurEffectStyleDark : UIBlurEffectStyleLight;

		// 动态获取用户设置的透明度
		float userTransparency = [[[NSUserDefaults standardUserDefaults] objectForKey:@"DYYYCommentBlurTransparent"] floatValue];
		if (userTransparency <= 0 || userTransparency > 1) {
			userTransparency = 0.5; // 默认值0.5（半透明）
		}

		if (!existingBlurView) {
			UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:blurStyle];
			UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
			blurEffectView.frame = self.view.bounds;
			blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
			blurEffectView.alpha = userTransparency; // 设置为用户自定义透明度
			blurEffectView.tag = 999;

			UIView *overlayView = [[UIView alloc] initWithFrame:self.view.bounds];
			CGFloat alpha = isDarkMode ? 0.2 : 0.1;
			overlayView.backgroundColor = [UIColor colorWithWhite:(isDarkMode ? 0 : 1) alpha:alpha];
			overlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
			[blurEffectView.contentView addSubview:overlayView];

			[self.view insertSubview:blurEffectView atIndex:0];
		} else {
			UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:blurStyle];
			[existingBlurView setEffect:blurEffect];

			existingBlurView.alpha = userTransparency; // 动态更新已有视图的透明度

			for (UIView *subview in existingBlurView.contentView.subviews) {
				if (subview.tag != 999) {
					CGFloat alpha = isDarkMode ? 0.2 : 0.1;
					subview.backgroundColor = [UIColor colorWithWhite:(isDarkMode ? 0 : 1) alpha:alpha];
				}
			}

			[self.view insertSubview:existingBlurView atIndex:0];
		}
	}
}
%end

%hook UIView
// 关键方法,误删！
%new
- (UIViewController *)firstAvailableUIViewController {
	UIResponder *responder = [self nextResponder];
	while (responder != nil) {
		if ([responder isKindOfClass:[UIViewController class]]) {
			return (UIViewController *)responder;
		}
		responder = [responder nextResponder];
	}
	return nil;
}

%end

// 重写全局透明方法
%hook AWEPlayInteractionViewController

- (UIView *)view {
	UIView *originalView = %orig;

	NSString *transparentValue = [[NSUserDefaults standardUserDefaults] stringForKey:@"DYYYGlobalTransparency"];
	if (transparentValue.length > 0) {
		CGFloat alphaValue = transparentValue.floatValue;
		if (alphaValue >= 0.0 && alphaValue <= 1.0) {
			for (UIView *subview in originalView.subviews) {
				if (subview.tag != DYYY_IGNORE_GLOBAL_ALPHA_TAG) {
					if (subview.alpha > 0) {
						subview.alpha = alphaValue;
					}
				}
			}
		}
	}

	return originalView;
}

%end

%hook AWEAwemeDetailNaviBarContainerView

- (void)layoutSubviews {
	%orig;

	NSString *transparentValue = [[NSUserDefaults standardUserDefaults] stringForKey:@"DYYYGlobalTransparency"];
	if (!transparentValue.length) return;
	CGFloat alphaValue = transparentValue.floatValue;
	if (alphaValue < 0.0 || alphaValue > 1.0) return;
	if ([NSStringFromClass([self.superview class]) isEqualToString:NSStringFromClass([self class])]) return;
	for (UIView *subview in self.subviews) {
		if (subview.tag == DYYY_IGNORE_GLOBAL_ALPHA_TAG) continue;
		if (subview.superview == self && subview.alpha > 0) {
				subview.alpha = alphaValue;
		}
	}
}

%end

%hook AFDViewedBottomView
- (void)layoutSubviews {
    %orig;
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYisEnableFullScreen"]) {

        self.backgroundColor = [UIColor clearColor];
        
        self.effectView.hidden = YES;
    }
}
%end

//收藏二次确认
%hook AWEFeedVideoButton
- (id)touchUpInsideBlock {
	id r = %orig;

	// 只有收藏按钮才显示确认弹窗
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYcollectTips"] && [self.accessibilityLabel isEqualToString:@"收藏"]) {

		dispatch_async(dispatch_get_main_queue(), ^{
		  [DYYYBottomAlertView showAlertWithTitle:@"收藏确认"
						  message:@"是否确认/取消收藏？"
					        avatarURL:nil
				     cancelButtonText:nil
				    confirmButtonText:nil
					     cancelAction:nil
					      closeAction:nil
					    confirmAction:^{
					      if (r && [r isKindOfClass:NSClassFromString(@"NSBlock")]) {
						      ((void (^)(void))r)();
					      }
					    }];
		});

		return nil; // 阻止原始 block 立即执行
	}

	return r;
}
%end

//进度条样式
%hook AWEFeedProgressSlider

// layoutSubviews 保持不变
- (void)layoutSubviews {
	%orig;
	[self applyCustomProgressStyle];
}

%new

- (void)applyCustomProgressStyle {
	NSString *scheduleStyle = [[NSUserDefaults standardUserDefaults] objectForKey:@"DYYYScheduleStyle"];
	UIView *parentView = self.superview;

	if (!parentView)
		return;

	if ([scheduleStyle isEqualToString:@"进度条两侧左右"]) {
		// 尝试获取标签
		UILabel *leftLabel = [parentView viewWithTag:10001];
		UILabel *rightLabel = [parentView viewWithTag:10002];

		if (leftLabel && rightLabel) {
			CGFloat padding = 5.0;
			CGFloat sliderY = self.frame.origin.y;
			CGFloat sliderHeight = self.frame.size.height;
			CGFloat sliderX = leftLabel.frame.origin.x + leftLabel.frame.size.width + padding;
			CGFloat sliderWidth = rightLabel.frame.origin.x - padding - sliderX;

			if (sliderWidth < 0)
				sliderWidth = 0;

			self.frame = CGRectMake(sliderX, sliderY, sliderWidth, sliderHeight);
		} else {
			CGFloat fallbackWidthPercent = 0.80;
			CGFloat parentWidth = parentView.bounds.size.width;
			CGFloat fallbackWidth = parentWidth * fallbackWidthPercent;
			CGFloat fallbackX = (parentWidth - fallbackWidth) / 2.0;
			// 使用 self.frame 获取当前 Y 和 Height (通常由 %orig 设置)
			CGFloat currentY = self.frame.origin.y;
			CGFloat currentHeight = self.frame.size.height;
			// 应用回退 frame
			self.frame = CGRectMake(fallbackX, currentY, fallbackWidth, currentHeight);
		}
	} else {
	}
}

- (void)setAlpha:(CGFloat)alpha {
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYisShowScheduleDisplay"]) {
		if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideVideoProgress"]) {
			%orig(0);
		} else {
			%orig(1.0);
		}
	} else {
		%orig;
	}
}

static CGFloat leftLabelLeftMargin = -1;
static CGFloat rightLabelRightMargin = -1;

- (void)setLimitUpperActionArea:(BOOL)arg1 {
	%orig;

	NSString *durationFormatted = [self.progressSliderDelegate formatTimeFromSeconds:floor(self.progressSliderDelegate.model.videoDuration / 1000)];

	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYisShowScheduleDisplay"]) {
		UIView *parentView = self.superview;
		if (!parentView)
			return;

		[[parentView viewWithTag:10001] removeFromSuperview];
		[[parentView viewWithTag:10002] removeFromSuperview];

		CGRect sliderOriginalFrameInParent = [self convertRect:self.bounds toView:parentView];
		CGRect sliderFrame = self.frame;

		CGFloat verticalOffset = -12.5;
		NSString *offsetValueString = [[NSUserDefaults standardUserDefaults] objectForKey:@"DYYYTimelineVerticalPosition"];
		if (offsetValueString.length > 0) {
			CGFloat configOffset = [offsetValueString floatValue];
			if (configOffset != 0)
				verticalOffset = configOffset;
		}

		NSString *scheduleStyle = [[NSUserDefaults standardUserDefaults] objectForKey:@"DYYYScheduleStyle"];
		BOOL showRemainingTime = [scheduleStyle isEqualToString:@"进度条右侧剩余"];
		BOOL showCompleteTime = [scheduleStyle isEqualToString:@"进度条右侧完整"];
		BOOL showLeftRemainingTime = [scheduleStyle isEqualToString:@"进度条左侧剩余"];
		BOOL showLeftCompleteTime = [scheduleStyle isEqualToString:@"进度条左侧完整"];

		NSString *labelColorHex = [[NSUserDefaults standardUserDefaults] objectForKey:@"DYYYProgressLabelColor"];
		UIColor *labelColor = [UIColor whiteColor];
		if (labelColorHex && labelColorHex.length > 0) {
			SEL colorSelector = NSSelectorFromString(@"colorWithHexString:");
			Class dyyyManagerClass = NSClassFromString(@"DYYYManager");
			if (dyyyManagerClass && [dyyyManagerClass respondsToSelector:colorSelector]) {
				labelColor = [dyyyManagerClass performSelector:colorSelector withObject:labelColorHex];
			}
		}

		CGFloat labelYPosition = sliderOriginalFrameInParent.origin.y + verticalOffset;
		CGFloat labelHeight = 15.0;
		UIFont *labelFont = [UIFont systemFontOfSize:8];

		if (!showRemainingTime && !showCompleteTime) {
			UILabel *leftLabel = [[UILabel alloc] init];
			leftLabel.backgroundColor = [UIColor clearColor];
			leftLabel.textColor = labelColor;
			leftLabel.font = labelFont;
			leftLabel.tag = 10001;
			if (showLeftRemainingTime)
				leftLabel.text = @"00:00";
			else if (showLeftCompleteTime)
				leftLabel.text = [NSString stringWithFormat:@"00:00/%@", durationFormatted];
			else
				leftLabel.text = @"00:00";

			[leftLabel sizeToFit];

			if (leftLabelLeftMargin == -1) {
				leftLabelLeftMargin = sliderFrame.origin.x;
			}

			leftLabel.frame = CGRectMake(leftLabelLeftMargin, labelYPosition, leftLabel.frame.size.width, labelHeight);
			[parentView addSubview:leftLabel];
		}

		if (!showLeftRemainingTime && !showLeftCompleteTime) {
			UILabel *rightLabel = [[UILabel alloc] init];
			rightLabel.backgroundColor = [UIColor clearColor];
			rightLabel.textColor = labelColor;
			rightLabel.font = labelFont;
			rightLabel.tag = 10002;
			if (showRemainingTime)
				rightLabel.text = @"00:00";
			else if (showCompleteTime)
				rightLabel.text = [NSString stringWithFormat:@"00:00/%@", durationFormatted];
			else
				rightLabel.text = durationFormatted;

			[rightLabel sizeToFit];

			if (rightLabelRightMargin == -1) {
				rightLabelRightMargin = sliderFrame.origin.x + sliderFrame.size.width - rightLabel.frame.size.width;
			}

			rightLabel.frame = CGRectMake(rightLabelRightMargin, labelYPosition, rightLabel.frame.size.width, labelHeight);
			[parentView addSubview:rightLabel];
		}

		[self setNeedsLayout];
	} else {
		UIView *parentView = self.superview;
		if (parentView) {
			[[parentView viewWithTag:10001] removeFromSuperview];
			[[parentView viewWithTag:10002] removeFromSuperview];
		}
		[self setNeedsLayout];
	}
}

%end

%hook AWEPlayInteractionProgressController

%new
- (NSString *)formatTimeFromSeconds:(CGFloat)seconds {
	NSInteger hours = (NSInteger)seconds / 3600;
	NSInteger minutes = ((NSInteger)seconds % 3600) / 60;
	NSInteger secs = (NSInteger)seconds % 60;

	if (hours > 0) {
		return [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)hours, (long)minutes, (long)secs];
	} else {
		return [NSString stringWithFormat:@"%02ld:%02ld", (long)minutes, (long)secs];
	}
}

- (void)updateProgressSliderWithTime:(CGFloat)arg1 totalDuration:(CGFloat)arg2 {
	%orig;

	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYisShowScheduleDisplay"]) {
		AWEFeedProgressSlider *progressSlider = self.progressSlider;
		UIView *parentView = progressSlider.superview;
		if (!parentView)
			return;

		UILabel *leftLabel = [parentView viewWithTag:10001];
		UILabel *rightLabel = [parentView viewWithTag:10002];

		NSString *labelColorHex = [[NSUserDefaults standardUserDefaults] objectForKey:@"DYYYProgressLabelColor"];
		UIColor *labelColor = [UIColor whiteColor];
		if (labelColorHex && labelColorHex.length > 0) {
			UIColor *customColor = [DYYYUtils colorWithHexString:labelColorHex];
			if (customColor) {
				labelColor = customColor;
			}
		}
		NSString *scheduleStyle = [[NSUserDefaults standardUserDefaults] objectForKey:@"DYYYScheduleStyle"];
		BOOL showRemainingTime = [scheduleStyle isEqualToString:@"进度条右侧剩余"];
		BOOL showCompleteTime = [scheduleStyle isEqualToString:@"进度条右侧完整"];
		BOOL showLeftRemainingTime = [scheduleStyle isEqualToString:@"进度条左侧剩余"];
		BOOL showLeftCompleteTime = [scheduleStyle isEqualToString:@"进度条左侧完整"];

		// 更新左标签
		if (arg1 >= 0 && leftLabel) {
			NSString *newLeftText = @"";
			if (showLeftRemainingTime) {
				CGFloat remainingTime = arg2 - arg1;
				if (remainingTime < 0)
					remainingTime = 0;
				newLeftText = [self formatTimeFromSeconds:remainingTime];
			} else if (showLeftCompleteTime) {
				newLeftText = [NSString stringWithFormat:@"%@/%@", [self formatTimeFromSeconds:arg1], [self formatTimeFromSeconds:arg2]];
			} else {
				newLeftText = [self formatTimeFromSeconds:arg1];
			}

			if (![leftLabel.text isEqualToString:newLeftText]) {
				leftLabel.text = newLeftText;
				[leftLabel sizeToFit];
				CGRect leftFrame = leftLabel.frame;
				leftFrame.size.height = 15.0;
				leftLabel.frame = leftFrame;
			}
			leftLabel.textColor = labelColor;
		}

		// 更新右标签
		if (arg2 > 0 && rightLabel) {
			NSString *newRightText = @"";
			if (showRemainingTime) {
				CGFloat remainingTime = arg2 - arg1;
				if (remainingTime < 0)
					remainingTime = 0;
				newRightText = [self formatTimeFromSeconds:remainingTime];
			} else if (showCompleteTime) {
				newRightText = [NSString stringWithFormat:@"%@/%@", [self formatTimeFromSeconds:arg1], [self formatTimeFromSeconds:arg2]];
			} else {
				newRightText = [self formatTimeFromSeconds:arg2];
			}

			if (![rightLabel.text isEqualToString:newRightText]) {
				rightLabel.text = newRightText;
				[rightLabel sizeToFit];
				CGRect rightFrame = rightLabel.frame;
				rightFrame.size.height = 15.0;
				rightLabel.frame = rightFrame;
			}
			rightLabel.textColor = labelColor;
		}
	}
}

- (void)setHidden:(BOOL)hidden {
	%orig;
	BOOL hideVideoProgress = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideVideoProgress"];
	BOOL showScheduleDisplay = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYisShowScheduleDisplay"];
	if (hideVideoProgress && showScheduleDisplay && !hidden) {
		self.alpha = 0;
	}
}

%end

%hook AWEFakeProgressSliderView
- (void)layoutSubviews {
	%orig;
	[self applyCustomProgressStyle];
}

%new
- (void)applyCustomProgressStyle {
	NSString *scheduleStyle = [[NSUserDefaults standardUserDefaults] objectForKey:@"DYYYScheduleStyle"];

	if ([scheduleStyle isEqualToString:@"进度条两侧左右"]) {
		for (UIView *subview in self.subviews) {
			if ([subview class] == [UIView class]) {
				subview.hidden = YES;
			}
		}
	}
}
%end

%hook AWENormalModeTabBarTextView

- (void)layoutSubviews {
	%orig;

	NSString *indexTitle = [[NSUserDefaults standardUserDefaults] objectForKey:@"DYYYIndexTitle"];
	NSString *friendsTitle = [[NSUserDefaults standardUserDefaults] objectForKey:@"DYYYFriendsTitle"];
	NSString *msgTitle = [[NSUserDefaults standardUserDefaults] objectForKey:@"DYYYMsgTitle"];
	NSString *selfTitle = [[NSUserDefaults standardUserDefaults] objectForKey:@"DYYYSelfTitle"];

	for (UIView *subview in [self subviews]) {
		if ([subview isKindOfClass:[UILabel class]]) {
			UILabel *label = (UILabel *)subview;
			if ([label.text isEqualToString:@"首页"]) {
				if (indexTitle.length > 0) {
					[label setText:indexTitle];
					[self setNeedsLayout];
				}
			}
			if ([label.text isEqualToString:@"朋友"]) {
				if (friendsTitle.length > 0) {
					[label setText:friendsTitle];
					[self setNeedsLayout];
				}
			}
			if ([label.text isEqualToString:@"消息"]) {
				if (msgTitle.length > 0) {
					[label setText:msgTitle];
					[self setNeedsLayout];
				}
			}
			if ([label.text isEqualToString:@"我"]) {
				if (selfTitle.length > 0) {
					[label setText:selfTitle];
					[self setNeedsLayout];
				}
			}
		}
	}
}
%end

//IP属地
%hook AWEPlayInteractionTimestampElement

- (id)timestampLabel {
	UILabel *label = %orig;
	NSString *labelColorHex = [[NSUserDefaults standardUserDefaults] objectForKey:@"DYYYLabelColor"];
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYEnabsuijiyanse"]) {
		labelColorHex = @"random_rainbow";
	}
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYisEnableArea"]) {
		NSString *originalText = label.text ?: @"";
		NSString *cityCode = self.model.cityCode;

		if (cityCode.length > 0) {
			NSString *cityName = [CityManager.sharedInstance getCityNameWithCode:cityCode];
			NSString *provinceName = [CityManager.sharedInstance getProvinceNameWithCode:cityCode];
			// 使用 GeoNames API
			if (!cityName || cityName.length == 0) {
				NSString *cacheKey = cityCode;

				static NSCache *geoNamesCache = nil;
				static dispatch_once_t onceToken;
				dispatch_once(&onceToken, ^{
				  geoNamesCache = [[NSCache alloc] init];
				  geoNamesCache.name = @"com.dyyy.geonames.cache";
				  geoNamesCache.countLimit = 1000;
				});

				NSDictionary *cachedData = [geoNamesCache objectForKey:cacheKey];

				if (!cachedData) {
					NSString *cachesDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
					NSString *geoNamesCacheDir = [cachesDir stringByAppendingPathComponent:@"DYYYGeoNamesCache"];

					NSFileManager *fileManager = [NSFileManager defaultManager];
					if (![fileManager fileExistsAtPath:geoNamesCacheDir]) {
						[fileManager createDirectoryAtPath:geoNamesCacheDir withIntermediateDirectories:YES attributes:nil error:nil];
					}

					NSString *cacheFilePath = [geoNamesCacheDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist", cacheKey]];

					if ([fileManager fileExistsAtPath:cacheFilePath]) {
						cachedData = [NSDictionary dictionaryWithContentsOfFile:cacheFilePath];
						if (cachedData) {
							[geoNamesCache setObject:cachedData forKey:cacheKey];
						}
					}
				}

				if (cachedData) {
					NSString *countryName = cachedData[@"countryName"];
					NSString *adminName1 = cachedData[@"adminName1"];
					NSString *localName = cachedData[@"name"];
					NSString *displayLocation = @"未知";

					if (countryName.length > 0) {
						if (adminName1.length > 0 && localName.length > 0 && ![countryName isEqualToString:@"中国"] && ![countryName isEqualToString:localName]) {
							// 国外位置：国家 + 州/省 + 地点
							displayLocation = [NSString stringWithFormat:@"%@ %@ %@", countryName, adminName1, localName];
						} else if (localName.length > 0 && ![countryName isEqualToString:localName]) {
							// 只有国家和地点名
							displayLocation = [NSString stringWithFormat:@"%@ %@", countryName, localName];
						} else {
							// 只有国家名
							displayLocation = countryName;
						}
					} else if (localName.length > 0) {
						displayLocation = localName;
					}

					dispatch_async(dispatch_get_main_queue(), ^{
					  NSString *currentLabelText = label.text ?: @"";
					  if ([currentLabelText containsString:@"IP属地："]) {
						  NSRange range = [currentLabelText rangeOfString:@"IP属地："];
						  if (range.location != NSNotFound) {
							  NSString *baseText = [currentLabelText substringToIndex:range.location];
							  if (![currentLabelText containsString:displayLocation]) {
								  label.text = [NSString stringWithFormat:@"%@IP属地：%@", baseText, displayLocation];
							  }
						  }
					  } else {
						  if (currentLabelText.length > 0 && ![displayLocation isEqualToString:@"未知"]) {
							  label.text = [NSString stringWithFormat:@"%@  IP属地：%@", currentLabelText, displayLocation];
						  } else if (![displayLocation isEqualToString:@"未知"]) {
							  label.text = [NSString stringWithFormat:@"IP属地：%@", displayLocation];
						  }
					  }

					  [DYYYUtils applyColorSettingsToLabel:label colorHexString:labelColorHex];
					  ;
					});
				} else {
					[CityManager
					    fetchLocationWithGeonameId:cityCode
						     completionHandler:^(NSDictionary *locationInfo, NSError *error) {
						       if (locationInfo) {
							       NSString *countryName = locationInfo[@"countryName"];
							       NSString *adminName1 = locationInfo[@"adminName1"]; // 州/省级名称
							       NSString *localName = locationInfo[@"name"];	   // 当前地点名称
							       NSString *displayLocation = @"未知";

							       // 根据返回数据构建位置显示文本
							       if (countryName.length > 0) {
								       if (adminName1.length > 0 && localName.length > 0 && ![countryName isEqualToString:@"中国"] &&
									   ![countryName isEqualToString:localName]) {
									       // 国外位置：国家 + 州/省 + 地点
									       displayLocation = [NSString stringWithFormat:@"%@ %@ %@", countryName, adminName1, localName];
								       } else if (localName.length > 0 && ![countryName isEqualToString:localName]) {
									       // 只有国家和地点名
									       displayLocation = [NSString stringWithFormat:@"%@ %@", countryName, localName];
								       } else {
									       // 只有国家名
									       displayLocation = countryName;
								       }
							       } else if (localName.length > 0) {
								       displayLocation = localName;
							       }

							       // 修改：仅当位置不为"未知"时才缓存
							       if (![displayLocation isEqualToString:@"未知"]) {
								       [geoNamesCache setObject:locationInfo forKey:cacheKey];

								       NSString *cachesDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
								       NSString *geoNamesCacheDir = [cachesDir stringByAppendingPathComponent:@"DYYYGeoNamesCache"];
								       NSString *cacheFilePath = [geoNamesCacheDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist", cacheKey]];

								       [locationInfo writeToFile:cacheFilePath atomically:YES];
							       }

							       dispatch_async(dispatch_get_main_queue(), ^{
								 NSString *currentLabelText = label.text ?: @"";

								 if ([currentLabelText containsString:@"IP属地："]) {
									 NSRange range = [currentLabelText rangeOfString:@"IP属地："];
									 if (range.location != NSNotFound) {
										 NSString *baseText = [currentLabelText substringToIndex:range.location];
										 if (![currentLabelText containsString:displayLocation]) {
											 label.text = [NSString stringWithFormat:@"%@IP属地：%@", baseText, displayLocation];
										 }
									 }
								 } else {
									 if (currentLabelText.length > 0 && ![displayLocation isEqualToString:@"未知"]) {
										 label.text = [NSString stringWithFormat:@"%@  IP属地：%@", currentLabelText, displayLocation];
									 } else if (![displayLocation isEqualToString:@"未知"]) {
										 label.text = [NSString stringWithFormat:@"IP属地：%@", displayLocation];
									 }
								 }

								 [DYYYUtils applyColorSettingsToLabel:label colorHexString:labelColorHex];
								 ;
							       });
						       }
						     }];
				}
			} else if (![originalText containsString:cityName]) {
				BOOL isDirectCity = [provinceName isEqualToString:cityName] ||
						    ([cityCode hasPrefix:@"99"] || [cityCode hasPrefix:@"99"] || [cityCode hasPrefix:@"99"] || [cityCode hasPrefix:@"99"]);
				if (!self.model.ipAttribution) {
					if (isDirectCity) {
						label.text = [NSString stringWithFormat:@"%@  IP属地：%@", originalText, cityName];
					} else {
						label.text = [NSString stringWithFormat:@"%@  IP属地：%@ %@", originalText, provinceName, cityName];
					}
				} else {
					BOOL containsProvince = [originalText containsString:provinceName];
					BOOL containsCity = [originalText containsString:cityName];
					if (containsProvince && !isDirectCity && !containsCity) {
						label.text = [NSString stringWithFormat:@"%@ %@", originalText, cityName];
					} else if (isDirectCity && !containsCity) {
						label.text = [NSString stringWithFormat:@"%@  IP属地：%@", originalText, cityName];
					}
				}
			}
		}
	}
	// 应用IP属地标签上移
	NSString *ipScaleValue = [[NSUserDefaults standardUserDefaults] objectForKey:@"DYYYNicknameScale"];
	if (ipScaleValue.length > 0) {
		UIFont *originalFont = label.font;
		CGRect originalFrame = label.frame;
		CGFloat offset = [[NSUserDefaults standardUserDefaults] floatForKey:@"DYYYIPLabelVerticalOffset"];
		if (offset > 0) {
			CGAffineTransform translationTransform = CGAffineTransformMakeTranslation(0, -offset);
			label.transform = translationTransform;
		} else {
			CGAffineTransform translationTransform = CGAffineTransformMakeTranslation(0, -3);
			label.transform = translationTransform;
		}

		label.font = originalFont;
	}
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYEnabsuijiyanse"]) {
		UIColor *color1 = [UIColor colorWithRed:(CGFloat)arc4random_uniform(256) / 255.0
						  green:(CGFloat)arc4random_uniform(256) / 255.0
						   blue:(CGFloat)arc4random_uniform(256) / 255.0
						  alpha:1.0];
		UIColor *color2 = [UIColor colorWithRed:(CGFloat)arc4random_uniform(256) / 255.0
						  green:(CGFloat)arc4random_uniform(256) / 255.0
						   blue:(CGFloat)arc4random_uniform(256) / 255.0
						  alpha:1.0];
		UIColor *color3 = [UIColor colorWithRed:(CGFloat)arc4random_uniform(256) / 255.0
						  green:(CGFloat)arc4random_uniform(256) / 255.0
						   blue:(CGFloat)arc4random_uniform(256) / 255.0
						  alpha:1.0];

		NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:label.text];
		CFIndex length = [attributedText length];
		for (CFIndex i = 0; i < length; i++) {
			CGFloat progress = (CGFloat)i / (length == 0 ? 1 : length - 1);

			UIColor *startColor;
			UIColor *endColor;
			CGFloat subProgress;

			if (progress < 0.5) {
				startColor = color1;
				endColor = color2;
				subProgress = progress * 2;
			} else {
				startColor = color2;
				endColor = color3;
				subProgress = (progress - 0.5) * 2;
			}

			CGFloat startRed, startGreen, startBlue, startAlpha;
			CGFloat endRed, endGreen, endBlue, endAlpha;
			[startColor getRed:&startRed green:&startGreen blue:&startBlue alpha:&startAlpha];
			[endColor getRed:&endRed green:&endGreen blue:&endBlue alpha:&endAlpha];

			CGFloat red = startRed + (endRed - startRed) * subProgress;
			CGFloat green = startGreen + (endGreen - startGreen) * subProgress;
			CGFloat blue = startBlue + (endBlue - startBlue) * subProgress;
			CGFloat alpha = startAlpha + (endAlpha - startAlpha) * subProgress;

			UIColor *currentColor = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
			[attributedText addAttribute:NSForegroundColorAttributeName value:currentColor range:NSMakeRange(i, 1)];
		}

		label.attributedText = attributedText;
	} else {
		NSString *labelColor = [[NSUserDefaults standardUserDefaults] objectForKey:@"DYYYLabelColor"];
		if (labelColor.length > 0) {
			label.textColor = [DYYYUtils colorWithHexString:labelColor];
		}
	}
	return label;
}

+ (BOOL)shouldActiveWithData:(id)arg1 context:(id)arg2 {
	return [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYisEnableArea"];
}

%end

%hook AWEPlayInteractionDescriptionScrollView

- (void)layoutSubviews {
	%orig;

	self.transform = CGAffineTransformIdentity;

	NSString *descriptionOffsetValue = [[NSUserDefaults standardUserDefaults] objectForKey:@"DYYYDescriptionVerticalOffset"];
	CGFloat verticalOffset = 0;
	if (descriptionOffsetValue.length > 0) {
		verticalOffset = [descriptionOffsetValue floatValue];
	}

	UIView *parentView = self.superview;
	UIView *grandParentView = nil;

	if (parentView) {
		grandParentView = parentView.superview;
	}

	if (grandParentView && verticalOffset != 0) {
		CGAffineTransform translationTransform = CGAffineTransformMakeTranslation(0, verticalOffset);
		grandParentView.transform = translationTransform;
	}
}

%end

// 对新版文案的偏移（33.0以上）
%hook AWEPlayInteractionDescriptionLabel

static char kLongPressGestureKey;
static NSString *const kDYYYLongPressCopyEnabledKey = @"DYYYLongPressCopyTextEnabled";

- (void)didMoveToWindow {
    %orig;
    
    BOOL longPressCopyEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:kDYYYLongPressCopyEnabledKey];
	
    if (![[NSUserDefaults standardUserDefaults] objectForKey:kDYYYLongPressCopyEnabledKey]) {
        longPressCopyEnabled = NO;
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kDYYYLongPressCopyEnabledKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    UIGestureRecognizer *existingGesture = objc_getAssociatedObject(self, &kLongPressGestureKey);
    if (existingGesture && !longPressCopyEnabled) {
        [self removeGestureRecognizer:existingGesture];
        objc_setAssociatedObject(self, &kLongPressGestureKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        return;
    }
    
    if (longPressCopyEnabled && !objc_getAssociatedObject(self, &kLongPressGestureKey)) {
        UILongPressGestureRecognizer *highPriorityLongPress = [[UILongPressGestureRecognizer alloc] 
            initWithTarget:self action:@selector(handleHighPriorityLongPress:)];
        highPriorityLongPress.minimumPressDuration = 0.3;
        
        [self addGestureRecognizer:highPriorityLongPress];
        
        UIView *currentView = self;
        while (currentView.superview) {
            currentView = currentView.superview;
            
            for (UIGestureRecognizer *recognizer in currentView.gestureRecognizers) {
                if ([recognizer isKindOfClass:[UILongPressGestureRecognizer class]] ||
                    [recognizer isKindOfClass:[UIPinchGestureRecognizer class]]) {
                    [recognizer requireGestureRecognizerToFail:highPriorityLongPress];
                }
            }
        }
        
        objc_setAssociatedObject(self, &kLongPressGestureKey, highPriorityLongPress, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

%new
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ([gestureRecognizer.view isEqual:self] && [gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]]) {
        return NO;
    }
    return YES;
}

%new
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ([gestureRecognizer.view isEqual:self] && [gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]]) {
        return YES;
    }
    return NO;
}

%new
- (void)handleHighPriorityLongPress:(UILongPressGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        
        NSString *description = self.text;
        
        if (description.length > 0) {
            [[UIPasteboard generalPasteboard] setString:description];
            [DYYYToast showSuccessToastWithMessage:@"视频文案已复制"];
        }
    }
}

- (void)layoutSubviews {
    %orig;
    self.transform = CGAffineTransformIdentity;

    NSString *descriptionOffsetValue = [[NSUserDefaults standardUserDefaults] objectForKey:@"DYYYDescriptionVerticalOffset"];
    CGFloat verticalOffset = 0;
    if (descriptionOffsetValue.length > 0) {
        verticalOffset = [descriptionOffsetValue floatValue];
    }

    UIView *parentView = self.superview;
    UIView *grandParentView = nil;

    if (parentView) {
        grandParentView = parentView.superview;
    }

    if (grandParentView && verticalOffset != 0) {
        CGAffineTransform translationTransform = CGAffineTransformMakeTranslation(0, verticalOffset);
        grandParentView.transform = translationTransform;
    }
}

%end

%hook AWEUserNameLabel

- (void)layoutSubviews {
	%orig;

	self.transform = CGAffineTransformIdentity;

	// 添加垂直偏移支持
	NSString *verticalOffsetValue = [[NSUserDefaults standardUserDefaults] objectForKey:@"DYYYNicknameVerticalOffset"];
	CGFloat verticalOffset = 0;
	if (verticalOffsetValue.length > 0) {
		verticalOffset = [verticalOffsetValue floatValue];
	}

	UIView *parentView = self.superview;
	UIView *grandParentView = nil;

	if (parentView) {
		grandParentView = parentView.superview;
	}

	// 检查祖父视图是否为 AWEBaseElementView 类型
	if (grandParentView && [grandParentView.superview isKindOfClass:%c(AWEBaseElementView)]) {
		CGRect scaledFrame = grandParentView.frame;
		CGFloat translationX = -scaledFrame.origin.x;

		CGAffineTransform translationTransform = CGAffineTransformMakeTranslation(translationX, verticalOffset);
		grandParentView.transform = translationTransform;
	}
}

%end

%hook AWEFeedVideoButton

- (void)setImage:(id)arg1 {
	NSString *nameString = nil;

	if ([self respondsToSelector:@selector(imageNameString)]) {
		nameString = [self performSelector:@selector(imageNameString)];
	}

	if (!nameString) {
		%orig;
		return;
	}

	NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
	NSString *dyyyFolderPath = [documentsPath stringByAppendingPathComponent:@"DYYY"];

	[[NSFileManager defaultManager] createDirectoryAtPath:dyyyFolderPath withIntermediateDirectories:YES attributes:nil error:nil];

	NSDictionary *iconMapping = @{
		@"icon_home_like_after" : @"like_after.png",
		@"icon_home_like_before" : @"like_before.png",
		@"icon_home_comment" : @"comment.png",
		@"icon_home_unfavorite" : @"unfavorite.png",
		@"icon_home_favorite" : @"favorite.png",
		@"iconHomeShareRight" : @"share.png"
	};

	NSString *customFileName = nil;
	if ([nameString containsString:@"_comment"]) {
		customFileName = @"comment.png";
	} else if ([nameString containsString:@"_like"]) {
		customFileName = @"like_before.png";
	} else if ([nameString containsString:@"_collect"]) {
		customFileName = @"unfavorite.png";
	} else if ([nameString containsString:@"_share"]) {
		customFileName = @"share.png";
	}

	for (NSString *prefix in iconMapping.allKeys) {
		if ([nameString hasPrefix:prefix]) {
			customFileName = iconMapping[prefix];
			break;
		}
	}

	if (customFileName) {
		NSString *customImagePath = [dyyyFolderPath stringByAppendingPathComponent:customFileName];

		if ([[NSFileManager defaultManager] fileExistsAtPath:customImagePath]) {
			UIImage *customImage = [UIImage imageWithContentsOfFile:customImagePath];
			if (customImage) {
				CGFloat targetWidth = 44.0;
				CGFloat targetHeight = 44.0;
				CGSize originalSize = customImage.size;

				CGFloat scale = MIN(targetWidth / originalSize.width, targetHeight / originalSize.height);
				CGFloat newWidth = originalSize.width * scale;
				CGFloat newHeight = originalSize.height * scale;

				UIGraphicsBeginImageContextWithOptions(CGSizeMake(newWidth, newHeight), NO, 0.0);
				[customImage drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
				UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
				UIGraphicsEndImageContext();

				if (resizedImage) {
					%orig(resizedImage);
					return;
				}
			}
		}
	}

	%orig;
}

%end

// 获取资源的地址
%hook AWEURLModel
%new - (NSURL *)getDYYYSrcURLDownload {
	NSURL *bestURL;
	for (NSString *url in self.originURLList) {
		if ([url containsString:@"video_mp4"] || [url containsString:@".jpeg"] || [url containsString:@".mp3"]) {
			bestURL = [NSURL URLWithString:url];
		}
	}

	if (bestURL == nil) {
		bestURL = [NSURL URLWithString:[self.originURLList firstObject]];
	}

	return bestURL;
}
%end

// 禁用点击首页刷新
%hook AWENormalModeTabBarGeneralButton

- (BOOL)enableRefresh {
	if ([self.accessibilityLabel isEqualToString:@"首页"]) {
		if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYDisableHomeRefresh"]) {
			return NO;
		}
	}
	return %orig;
}

%end

// 屏蔽版本更新
%hook AWEVersionUpdateManager

- (void)startVersionUpdateWorkflow:(id)arg1 completion:(id)arg2 {
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYNoUpdates"]) {
		if (arg2) {
			void (^completionBlock)(void) = arg2;
			completionBlock();
		}
	} else {
		%orig;
	}
}

- (id)workflow {
	return [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYNoUpdates"] ? nil : %orig;
}

- (id)badgeModule {
	return [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYNoUpdates"] ? nil : %orig;
}

%end

// 应用内推送毛玻璃效果
%hook AWEInnerNotificationWindow

- (id)initWithFrame:(CGRect)frame {
	id orig = %orig;
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYEnableNotificationTransparency"]) {
		[self setupBlurEffectForNotificationView];
	}
	return orig;
}

- (void)layoutSubviews {
	%orig;
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYEnableNotificationTransparency"]) {
		[self setupBlurEffectForNotificationView];
	}
}

- (void)didMoveToWindow {
	%orig;
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYEnableNotificationTransparency"]) {
		[self setupBlurEffectForNotificationView];
	}
}

- (void)didAddSubview:(UIView *)subview {
	%orig;
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYEnableNotificationTransparency"] && [NSStringFromClass([subview class]) containsString:@"AWEInnerNotificationContainerView"]) {
		[self setupBlurEffectForNotificationView];
	}
}

%new
- (void)setupBlurEffectForNotificationView {
	for (UIView *subview in self.subviews) {
		if ([NSStringFromClass([subview class]) containsString:@"AWEInnerNotificationContainerView"]) {
			[self applyBlurEffectToView:subview];
			break;
		}
	}
}

%new
- (void)applyBlurEffectToView:(UIView *)containerView {
	if (!containerView) {
		return;
	}

	containerView.backgroundColor = [UIColor clearColor];

	float userRadius = [[[NSUserDefaults standardUserDefaults] objectForKey:@"DYYYNotificationCornerRadius"] floatValue];
	if (!userRadius || userRadius < 0 || userRadius > 50) {
		userRadius = 12;
	}

	containerView.layer.cornerRadius = userRadius;
	containerView.layer.masksToBounds = YES;

	for (UIView *subview in containerView.subviews) {
		if ([subview isKindOfClass:[UIVisualEffectView class]] && subview.tag == 999) {
			[subview removeFromSuperview];
		}
	}

	BOOL isDarkMode = [DYYYUtils isDarkMode];
	UIBlurEffectStyle blurStyle = isDarkMode ? UIBlurEffectStyleDark : UIBlurEffectStyleLight;
	UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:blurStyle];
	UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];

	blurView.frame = containerView.bounds;
	blurView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	blurView.tag = 999;
	blurView.layer.cornerRadius = userRadius;
	blurView.layer.masksToBounds = YES;

	float userTransparency = [[[NSUserDefaults standardUserDefaults] objectForKey:@"DYYYCommentBlurTransparent"] floatValue];
	if (userTransparency <= 0 || userTransparency > 1) {
		userTransparency = 0.5;
	}

	blurView.alpha = userTransparency;

	[containerView insertSubview:blurView atIndex:0];

	[self clearBackgroundRecursivelyInView:containerView];

	[self setLabelsColorWhiteInView:containerView];
}

%new
- (void)setLabelsColorWhiteInView:(UIView *)view {
	for (UIView *subview in view.subviews) {
		if ([subview isKindOfClass:[UILabel class]]) {
			UILabel *label = (UILabel *)subview;
			NSString *text = label.text;

			if (![text isEqualToString:@"回复"] && ![text isEqualToString:@"查看"] && ![text isEqualToString:@"续火花"]) {
				label.textColor = [UIColor whiteColor];
			}
		}
		[self setLabelsColorWhiteInView:subview];
	}
}

%new
- (void)clearBackgroundRecursivelyInView:(UIView *)view {
	for (UIView *subview in view.subviews) {
		if ([subview isKindOfClass:[UIVisualEffectView class]] && subview.tag == 999 && [subview isKindOfClass:[UIButton class]]) {
			continue;
		}
		subview.backgroundColor = [UIColor clearColor];
		subview.opaque = NO;
		[self clearBackgroundRecursivelyInView:subview];
	}
}

%end

// 为 AWEUserActionSheetView 添加毛玻璃效果
%hook AWEUserActionSheetView

- (void)layoutSubviews {
	%orig;
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYisEnableSheetBlur"]) {
		[self applyBlurEffectAndWhiteText];
	}
}

%new
- (void)applyBlurEffectAndWhiteText {
	// 应用毛玻璃效果到容器视图
	if (self.containerView) {
		self.containerView.backgroundColor = [UIColor clearColor];

		for (UIView *subview in self.containerView.subviews) {
			if ([subview isKindOfClass:[UIVisualEffectView class]] && subview.tag == 9999) {
				[subview removeFromSuperview];
			}
		}

		// 动态获取用户设置的透明度
		float userTransparency = [[[NSUserDefaults standardUserDefaults] objectForKey:@"DYYYSheetBlurTransparent"] floatValue];
		if (userTransparency <= 0 || userTransparency > 1) {
			userTransparency = 0.9; // 默认值0.9
		}

		UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
		UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
		blurEffectView.frame = self.containerView.bounds;
		blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		blurEffectView.alpha = userTransparency; // 设置为用户自定义透明度
		blurEffectView.tag = 9999;

		[self.containerView insertSubview:blurEffectView atIndex:0];

		[self setTextColorWhiteRecursivelyInView:self.containerView];
	}
}

%new
- (void)setTextColorWhiteRecursivelyInView:(UIView *)view {
	for (UIView *subview in view.subviews) {
		if (![subview isKindOfClass:[UIVisualEffectView class]]) {
			subview.backgroundColor = [UIColor clearColor];
		}

		if ([subview isKindOfClass:[UILabel class]]) {
			UILabel *label = (UILabel *)subview;
			label.textColor = [UIColor whiteColor];
		}

		if ([subview isKindOfClass:[UIButton class]]) {
			UIButton *button = (UIButton *)subview;
			[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		}

		[self setTextColorWhiteRecursivelyInView:subview];
	}
}
%end

%hook _TtC33AWECommentLongPressPanelSwiftImpl32CommentLongPressPanelCopyElement

- (void)elementTapped {
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYCommentCopyText"]) {
		AWECommentLongPressPanelContext *commentPageContext = [self commentPageContext];
		AWECommentModel *selectdComment = [commentPageContext selectdComment];
		if (!selectdComment) {
			AWECommentLongPressPanelParam *params = [commentPageContext params];
			selectdComment = [params selectdComment];
		}
		NSString *descText = [selectdComment content];
		[[UIPasteboard generalPasteboard] setString:descText];
		[DYYYToast showSuccessToastWithMessage:@"评论已复制"];
	}
}
%end

// 启用自动勾选原图
%hook AWEIMPhotoPickerFunctionModel

- (void)setUseShadowIcon:(BOOL)arg1 {
	BOOL enabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYisAutoSelectOriginalPhoto"];
	if (enabled) {
		%orig(YES);
	} else {
		%orig(arg1);
	}
}

- (BOOL)isSelected {
	BOOL enabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYisAutoSelectOriginalPhoto"];
	if (enabled) {
		return YES;
	}
	return %orig;
}

%end

// 屏蔽直播PCDN
%hook HTSLiveStreamPcdnManager

+ (void)start {
	BOOL disablePCDN = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYDisableLivePCDN"];
	if (!disablePCDN) {
		%orig;
	}
}

+ (void)configAndStartLiveIO {
	BOOL disablePCDN = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYDisableLivePCDN"];
	if (!disablePCDN) {
		%orig;
	}
}

%end

// 直播默认最高清晰度功能
%hook HTSLiveStreamQualityFragment

- (void)setupStreamQuality:(id)arg1 {
	%orig;

	BOOL enableHighestQuality = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYEnableLiveHighestQuality"];
	if (enableHighestQuality) {
		NSArray *qualities = self.streamQualityArray;
		if (!qualities || qualities.count == 0) {
			qualities = [self getQualities];
		}

		if (!qualities || qualities.count == 0) {
			return;
		}
		// 选择索引0作为最高清晰度
		[self setResolutionWithIndex:0 isManual:YES beginChange:nil completion:nil];
	}
}

%end

// 强制启用新版抖音长按 UI（现代风）
%hook AWELongPressPanelDataManager
+ (BOOL)enableModernLongPressPanelConfigWithSceneIdentifier:(id)arg1 {
	return DYYYGetBool(@"DYYYisEnableModern") || DYYYGetBool(@"DYYYisEnableModernLight") || DYYYGetBool(@"DYYYModernPanelFollowSystem");
}
%end

%hook AWELongPressPanelABSettings
+ (NSUInteger)modernLongPressPanelStyleMode {
	if (DYYYGetBool(@"DYYYModernPanelFollowSystem")) {
		BOOL isDarkMode = [DYYYUtils isDarkMode];
		return isDarkMode ? 1 : 2;
	} else if (DYYYGetBool(@"DYYYisEnableModernLight")) {
		return 2;
	} else if (DYYYGetBool(@"DYYYisEnableModern")) {
		return 1;
	}
	return 0;
}
%end

%hook AWEModernLongPressPanelUIConfig
+ (NSUInteger)modernLongPressPanelStyleMode {
	if (DYYYGetBool(@"DYYYModernPanelFollowSystem")) {
		BOOL isDarkMode = [DYYYUtils isDarkMode];
		return isDarkMode ? 1 : 2;
	} else if (DYYYGetBool(@"DYYYisEnableModernLight")) {
		return 2;
	} else if (DYYYGetBool(@"DYYYisEnableModern")) {
		return 1;
	}
	return 0;
}
%end

// 禁用个人资料自动进入橱窗
%hook AWEUserTabListModel

- (NSInteger)profileLandingTab {
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYDefaultEnterWorks"]) {
		return 0;
	} else {
		return %orig;
	}
}

%end

%group AutoPlay

//取消自动翻页
%hook DUXToast

+ (void)showText:(NSString *)text {
    if (text && [text isEqualToString:@"已取消自动翻页"]) {
        return;
    }
    %orig;
}

%end

%hook UIViewController

- (void)viewDidAppear:(BOOL)animated {
	%orig;
	if ([self isKindOfClass:%c(AWESearchViewController)] || [self isKindOfClass:%c(IESLiveInnerFeedViewController)] || [self isKindOfClass:%c(AWEAwemeDetailTableViewController)]) {
		UITabBarController *tabBarController = self.tabBarController;
		if ([tabBarController isKindOfClass:%c(AWENormalModeTabBarController)]) {
			tabBarController.tabBar.hidden = YES;
		}
	}
}

%end

%hook AWENormalModeTabBarController

- (void)viewDidLoad {
    %orig;
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(handleApplicationWillEnterForeground:) 
                                                 name:UIApplicationWillEnterForegroundNotification 
                                               object:nil];
}

%new
- (void)handleApplicationWillEnterForeground:(NSNotification *)notification {
    UIViewController *topVC = topVC;
    if ([topVC isKindOfClass:%c(UINavigationController)]) {
        UINavigationController *navVC = (UINavigationController *)topVC;
        topVC = navVC.topViewController;
    }
    
    if ([topVC isKindOfClass:%c(AWESearchViewController)] || 
        [topVC isKindOfClass:%c(IESLiveInnerFeedViewController)] || 
        [topVC isKindOfClass:%c(AWEAwemeDetailTableViewController)]) {
        self.awe_tabBar.hidden = YES;
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    %orig;
}

%end

%hook AWEFeedGuideManager

- (bool)enableAutoplay {
	BOOL featureEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYisEnableAutoPlay"];
	if (!featureEnabled) {
		return %orig;
	}
	return YES;
}

%end

%hook AWEFeedIPhoneAutoPlayManager

- (BOOL)isAutoPlayOpen {
	return YES;
}

%end

%hook AWEFeedModuleService

- (BOOL)getFeedIphoneAutoPlayState {
	return YES;
}
%end

%hook AWEFeedIPhoneAutoPlayManager

- (BOOL)getFeedIphoneAutoPlayState {
	BOOL r = %orig;
	return YES;
}
%end

%end

//侧边长按倍速
%hook AWEPlayInteractionSpeedController

static BOOL isCustomSpeedActive = NO;

- (CGFloat)longPressFastSpeedValue {
	float longPressSpeed = [[NSUserDefaults standardUserDefaults] floatForKey:@"DYYYLongPressSpeed"];
	if (longPressSpeed == 0) {
		longPressSpeed = 2.0;
	}
	return longPressSpeed;
}

- (void)changeSpeed:(double)speed {
	float longPressSpeed = [[NSUserDefaults standardUserDefaults] floatForKey:@"DYYYLongPressSpeed"];

	if (longPressSpeed == 0) {
		longPressSpeed = 2.0;
	}

	if (speed == longPressSpeed) {
		// 传入的速度是自定义倍速
		if (isCustomSpeedActive) {
			isCustomSpeedActive = NO;
			%orig(1.0);
		} else {
			isCustomSpeedActive = YES;
			%orig(longPressSpeed);
		}
	} else if (speed == 2.0) {
		// 传入的是默认倍速2.0
		if (!isCustomSpeedActive) {
			isCustomSpeedActive = YES;
			%orig(longPressSpeed);
		} else {
			%orig(speed);
		}
	} else if (speed == 1.0) {
		isCustomSpeedActive = NO;
		%orig(1.0);
	} else {
		isCustomSpeedActive = (speed == longPressSpeed);
		%orig(speed);
	}
}
%end

%hook UILabel

- (void)setText:(NSString *)text {
	UIView *superview = self.superview;

	if ([superview isKindOfClass:%c(AFDFastSpeedView)] && text) {
		float longPressSpeed = [[NSUserDefaults standardUserDefaults] floatForKey:@"DYYYLongPressSpeed"];
		if (longPressSpeed == 0) {
			longPressSpeed = 2.0;
		}

		NSString *speedString = [NSString stringWithFormat:@"%.2f", longPressSpeed];
		if ([speedString hasSuffix:@".00"]) {
			speedString = [speedString substringToIndex:speedString.length - 3];
		} else if ([speedString hasSuffix:@"0"] && [speedString containsString:@"."]) {
			speedString = [speedString substringToIndex:speedString.length - 1];
		}

		if ([text containsString:@"2"]) {
			text = [text stringByReplacingOccurrencesOfString:@"2" withString:speedString];
		}
	}

	%orig(text);
}
%end

//聊天页表情包
static AWEIMReusableCommonCell *currentCell;

%hook AWEIMCustomMenuComponent
- (void)msg_showMenuForBubbleFrameInScreen:(CGRect)bubbleFrame tapLocationInScreen:(CGPoint)tapLocation menuItemList:(id)menuItems moreEmoticon:(BOOL)moreEmoticon onCell:(id)cell extra:(id)extra {
	if (![[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYForceDownloadIMEmotion"]) {
		%orig(bubbleFrame, tapLocation, menuItems, moreEmoticon, cell, extra);
		return;
	}
	NSArray *originalMenuItems = menuItems;

	NSMutableArray *newMenuItems = [originalMenuItems mutableCopy];
	currentCell = (AWEIMReusableCommonCell *)cell;

	AWEIMCustomMenuModel *newMenuItem1 = [%c(AWEIMCustomMenuModel) new];
	newMenuItem1.title = @"保存表情";
	newMenuItem1.imageName = @"im_emoticon_interactive_tab_new";
	newMenuItem1.willPerformMenuActionSelectorBlock = ^(id arg1) {
	  AWEIMMessageComponentContext *context = (AWEIMMessageComponentContext *)currentCell.currentContext;
	  if ([context.message isKindOfClass:%c(AWEIMGiphyMessage)]) {
		  AWEIMGiphyMessage *giphyMessage = (AWEIMGiphyMessage *)context.message;
		  if (giphyMessage.giphyURL && giphyMessage.giphyURL.originURLList.count > 0) {
			  NSURL *url = [NSURL URLWithString:giphyMessage.giphyURL.originURLList.firstObject];
			   [DYYYManager downloadMedia:url
                                           mediaType:MediaTypeHeic
                                               audio:nil
                                          completion:^(BOOL success){
                                          }];
		  }
	  }
	};
	newMenuItem1.trackerName = @"保存表情";
	AWEIMMessageComponentContext *context = (AWEIMMessageComponentContext *)currentCell.currentContext;
	if ([context.message isKindOfClass:%c(AWEIMGiphyMessage)]) {
		[newMenuItems addObject:newMenuItem1];
	}
	%orig(bubbleFrame, tapLocation, newMenuItems, moreEmoticon, cell, extra);
}

%end

// 隐藏评论音乐
%hook AWECommentGuideLunaAnchorView
- (void)layoutSubviews {
	%orig;

	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideCommentViews"]) {
		[self setHidden:YES];
	}

	if([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYMusicCopyText"]) {
    	UILabel *label = nil;
		if ([self respondsToSelector:@selector(preTitleLabel)]) {
			label = [self valueForKey:@"preTitleLabel"];
		}
		if (label && [label isKindOfClass:[UILabel class]]) {
			label.text = @"";
		}
	}
}

- (void)p_didClickSong {
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYMusicCopyText"]) {
		// 通过 KVC 拿到内部的 songButton
		UIButton *btn = nil;
		if ([self respondsToSelector:@selector(songButton)]) {
			btn = (UIButton *)[self valueForKey:@"songButton"];
		}

		// 获取歌曲名并复制到剪贴板
		if (btn && [btn isKindOfClass:[UIButton class]]) {
			NSString *song = btn.currentTitle;
			if (song.length) {
				[UIPasteboard generalPasteboard].string = song;
				[DYYYToast showSuccessToastWithMessage:@"歌曲名已复制"];
			}
		}
	} else {
		%orig;
	}
}

%end

//评论区表情保存
%group EnableStickerSaveMenu
static __weak YYAnimatedImageView *targetStickerView = nil;

%hook _TtCV28AWECommentPanelListSwiftImpl6NEWAPI27CommentCellStickerComponent

- (void)handleLongPressWithGes:(UILongPressGestureRecognizer *)gesture {
	if (gesture.state == UIGestureRecognizerStateBegan) {
		if ([gesture.view isKindOfClass:%c(YYAnimatedImageView)]) {
			targetStickerView = (YYAnimatedImageView *)gesture.view;
			NSLog(@"DYYY 长按表情：%@", targetStickerView);
		} else {
			targetStickerView = nil;
		}
	}

	%orig;
}

%end

%hook UIMenu

+ (instancetype)menuWithTitle:(NSString *)title image:(UIImage *)image identifier:(UIMenuIdentifier)identifier options:(UIMenuOptions)options children:(NSArray<UIMenuElement *> *)children {
	BOOL hasAddStickerOption = NO;
	BOOL hasSaveLocalOption = NO;

	for (UIMenuElement *element in children) {
		NSString *elementTitle = nil;

		if ([element isKindOfClass:%c(UIAction)]) {
			elementTitle = [(UIAction *)element title];
		} else if ([element isKindOfClass:%c(UICommand)]) {
			elementTitle = [(UICommand *)element title];
		}

		if ([elementTitle isEqualToString:@"添加到表情"]) {
			hasAddStickerOption = YES;
		} else if ([elementTitle isEqualToString:@"保存到相册"]) {
			hasSaveLocalOption = YES;
		}
	}

	if (hasAddStickerOption && !hasSaveLocalOption) {
		NSMutableArray *newChildren = [children mutableCopy];

		UIAction *saveAction = [%c(UIAction) actionWithTitle:@"保存到相册"
									 image:nil
								    identifier:nil
								       handler:^(__kindof UIAction *_Nonnull action) {
									 // 使用全局变量 targetStickerView 保存当前长按的表情
										if (targetStickerView) {
										 [DYYYManager saveAnimatedSticker:targetStickerView];
									 } else {
										 [DYYYUtils showToast:@"无法获取表情视图"];
									 }
								       }];

		[newChildren addObject:saveAction];
		return %orig(title, image, identifier, options, newChildren);
	}

	return %orig;
}

%end
%end

//隐藏AI搜索
%hook AWESearchKeyboardVoiceSearchEntranceView 
- (id)initWithFrame:(CGRect)frame {
    id orig = %orig;
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHidekeyboardai"]) {
        [(UIView *)orig setHidden:YES];
        [(UIView *)orig removeFromSuperview];
    }
    return orig;
}
- (void)didMoveToWindow {
    %orig;
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHidekeyboardai"]) {
        [self setHidden:YES];
        [self removeFromSuperview];
    }
}
- (void)setHidden:(BOOL)hidden {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHidekeyboardai"]) {
        %orig(YES);
        [self removeFromSuperview];
    } else {
        %orig(hidden);
    } 
}
- (void)willMoveToSuperview:(UIView *)newSuperview {
    %orig;
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHidekeyboardai"] && newSuperview) {
        [self setHidden:YES];
        [self removeFromSuperview];
    }
}
%end 
%hook UIView 
- (void)addSubview:(UIView *)view {
    %orig;
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHidekeyboardai"] &&
       [view isKindOfClass:NSClassFromString(@"AWESearchKeyboardVoiceSearchEntranceView")]) {
        [view setHidden:YES];
        [self removeFromSuperview];
    }
}
%end
%hook UIImageView 
- (void)layoutSubviews {
    %orig; // 调用原始方法 
    BOOL shouldHide = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHidekeyboardai"];
    if (shouldHide && CGSizeEqualToSize(self.bounds.size, CGSizeMake(36, 36))) {
        // 检查是否在AWESearchViewController中
        UIViewController *vc = [self firstAvailableUIViewController];
        if ([NSStringFromClass([vc class]) isEqualToString:@"AWESearchViewController"]) {
            self.hidden = YES;
        }
    }
}
%end

// 去除隐藏大家都在搜后的留白
%hook AWESearchAnchorListModel

- (BOOL)hideWords {
	return [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideCommentViews"];
}

%end

// Swift 类组 - 这些会在 %ctor 中动态初始化
%group CommentHeaderGeneralGroup
%hook AWECommentPanelHeaderSwiftImpl_CommentHeaderGeneralView
- (void)layoutSubviews {
	%orig;

	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideCommentViews"]) {
		[self setHidden:YES];
	}
}
%end
%end
%group CommentHeaderGoodsGroup
%hook AWECommentPanelHeaderSwiftImpl_CommentHeaderGoodsView
- (void)layoutSubviews {
	%orig;

	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideCommentViews"]) {
		[self setHidden:YES];
	}
}
%end
%end
%group CommentHeaderTemplateGroup
%hook AWECommentPanelHeaderSwiftImpl_CommentHeaderTemplateAnchorView
- (void)layoutSubviews {
	%orig;

	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideCommentViews"]) {
		[self setHidden:YES];
	}
}
%end
%end
%group CommentBottomTipsVCGroup
%hook AWECommentPanelListSwiftImpl_CommentBottomTipsContainerViewController
- (void)viewWillAppear:(BOOL)animated {
    %orig(animated);
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideCommentTips"]) {
        ((UIViewController *)self).view.hidden = YES;
    }
}
%end
%end
// Swift 类初始化
%ctor {

	// 动态获取 Swift 类并初始化对应的组
	Class commentHeaderGeneralClass = objc_getClass("AWECommentPanelHeaderSwiftImpl.CommentHeaderGeneralView");
	if (commentHeaderGeneralClass) {
		%init(CommentHeaderGeneralGroup, AWECommentPanelHeaderSwiftImpl_CommentHeaderGeneralView = commentHeaderGeneralClass);
	}

	Class commentHeaderGoodsClass = objc_getClass("AWECommentPanelHeaderSwiftImpl.CommentHeaderGoodsView");
	if (commentHeaderGoodsClass) {
		%init(CommentHeaderGoodsGroup, AWECommentPanelHeaderSwiftImpl_CommentHeaderGoodsView = commentHeaderGoodsClass);
	}

	Class commentHeaderTemplateClass = objc_getClass("AWECommentPanelHeaderSwiftImpl.CommentHeaderTemplateAnchorView");
	if (commentHeaderTemplateClass) {
		%init(CommentHeaderTemplateGroup, AWECommentPanelHeaderSwiftImpl_CommentHeaderTemplateAnchorView = commentHeaderTemplateClass);
	}
       Class tipsVCClass = objc_getClass("AWECommentPanelListSwiftImpl.CommentBottomTipsContainerViewController");
        if (tipsVCClass) {
        %init(CommentBottomTipsVCGroup,AWECommentPanelListSwiftImpl_CommentBottomTipsContainerViewController = tipsVCClass);
    }
}

%ctor {
      // 骰子图像 URL 数组
    diceImageURLs = @[
        @"https://p26-sign.douyinpic.com/obj/im-resource/1687261843554-ts-e9aab0e5ad90312e706e67?lk3s=91c5b7cb&x-expires=1776769200&x-signature=baB%2FIZcAdhLwmwypQAVayoGDCGw%3D&from=2445653963&s=im_111&se=false&sc=image&biz_tag=aweme_im",
        @"https://p3-sign.douyinpic.com/obj/im-resource/1687261849121-ts-e9aab0e5ad90322e706e67?lk3s=91c5b7cb&x-expires=1776783600&x-signature=9OjeBKFsrwsSvDbJ7zgYW438GkA%3D&from=2445653963&s=im_111&se=false&sc=image&biz_tag=aweme_im",
        @"https://p3-sign.douyinpic.com/obj/im-resource/1687261857819-ts-e9aab0e5ad90332e706e67?lk3s=91c5b7cb&x-expires=1776769200&x-signature=kai68kuaaX98V4kt0OlBpEAF1vM%3D&from=2445653963&s=im_111&se=false&sc=image&biz_tag=aweme_im",
        @"https://p11-sign.douyinpic.com/obj/im-resource/1687261865141-ts-e9aab0e5ad90342e706e67?lk3s=91c5b7cb&x-expires=1776769200&x-signature=LcVn%2Bw22XDlo1feFpbhdBe1pscM%3D&from=2445653963&s=im_111&se=false&sc=image&biz_tag=aweme_im",
        @"https://p3-sign.douyinpic.com/obj/im-resource/1687261870616-ts-e9aab0e5ad90352e706e67?lk3s=91c5b7cb&x-expires=1776769200&x-signature=hYNyyQw5Rx1JMM%2BZH2GHfRVlQbU%3D&from=2445653963&s=im_111&se=false&sc=image&biz_tag=aweme_im",
        @"https://p3-sign.douyinpic.com/obj/im-resource/1687261876911-ts-e9aab0e5ad90362e706e67?lk3s=91c5b7cb&x-expires=1776783600&x-signature=e4jdM5oZ9Bssn9mTRdXpa1nZzE4%3D&from=2445653963&s=im_111&se=false&sc=image&biz_tag=aweme_im"
    ];
       //猜拳图像 URL 数组
    rpsImageURLs = @[
        @"https://p3-sign.douyinpic.com/obj/im-resource/1687263871618-ts-e79fb3e5a4b42e706e67?lk3s=91c5b7cb&x-expires=1776787200&x-signature=S61ZxCxdTJpkHvc8PZSDBqp5dzU%3D&from=2445653963&s=im_111&se=false&sc=image&biz_tag=aweme_im&l=2025042200290891348EC85D4A86315B8E",     // 石头
        @"https://p3-sign.douyinpic.com/obj/im-resource/1687263865408-ts-e5b8832e706e67?lk3s=91c5b7cb&x-expires=1776787200&x-signature=N4WWMJbmxo9HOkRxN9%2BX3Tst68U%3D&from=2445653963&s=im_111&se=false&sc=image&biz_tag=aweme_im&l=2025042200290891348EC85D4A86315B8E",    // 布
        @"https://p3-sign.douyinpic.com/obj/im-resource/1687263855295-ts-e589aae588802e706e67?lk3s=91c5b7cb&x-expires=1776787200&x-signature=%2Fk04PfR1HEAODUdzI4wWJdjEhPo%3D&from=2445653963&s=im_111&se=false&sc=image&biz_tag=aweme_im&l=2025042200290891348EC85D4A86315B8E"  // 剪刀
    ];
    //原有参数
	%init(DYYYSettingsGesture);
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYUserAgreementAccepted"]) {
		%init;
		BOOL isAutoPlayEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYisEnableAutoPlay"];
		if (isAutoPlayEnabled) {
			%init(AutoPlay);
		}
	}
}

// 隐藏键盘ai
static void hideParentViewsSubviews(UIView *view) {
	if (!view)
		return;
	// 获取第一层父视图
	UIView *parentView = [view superview];
	if (!parentView)
		return;
	// 获取第二层父视图
	UIView *grandParentView = [parentView superview];
	if (!grandParentView)
		return;
	// 获取第三层父视图
	UIView *greatGrandParentView = [grandParentView superview];
	if (!greatGrandParentView)
		return;
	// 隐藏所有子视图
	for (UIView *subview in greatGrandParentView.subviews) {
		subview.hidden = YES;
	}
}
// 递归查找目标视图
static void findTargetViewInView(UIView *view) {
	if ([view isKindOfClass:NSClassFromString(@"AWESearchKeyboardVoiceSearchEntranceView")]) {
		hideParentViewsSubviews(view);
		return;
	}
	for (UIView *subview in view.subviews) {
		findTargetViewInView(subview);
	}
}

%ctor {
       if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYForceDownloadEmotion"]) {
			%init(EnableStickerSaveMenu);
    }
	// 注册键盘通知
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYUserAgreementAccepted"]) {
		[[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillShowNotification
								  object:nil
								   queue:[NSOperationQueue mainQueue]
							      usingBlock:^(NSNotification *notification) {
								// 检查开关状态
								if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHidekeyboardai"]) {
									for (UIWindow *window in [UIApplication sharedApplication].windows) {
										findTargetViewInView(window);
									}
								}
							      }];
	}
}
