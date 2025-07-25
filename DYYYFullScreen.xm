#import "AwemeHeaders.h"
#import "DYYYManager.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "DYYYUtils.h"

// 底栏高度
static CGFloat tabHeight = 0;

static CGFloat customTabBarHeight() {
        NSString *value = [[NSUserDefaults standardUserDefaults] objectForKey:@"DYYYTabBarHeight"];
        if (value.length > 0) {
                CGFloat h = [value floatValue];
                return h > 0 ? h : 0;
        }
        return 0;
}

static void DYYYAddCustomViewToParent(UIView *parentView, float transparency) {
	if (!parentView)
		return;

	parentView.backgroundColor = [UIColor clearColor];

	UIVisualEffectView *existingBlurView = nil;
	for (UIView *subview in parentView.subviews) {
		if ([subview isKindOfClass:[UIVisualEffectView class]] && subview.tag == 999) {
			existingBlurView = (UIVisualEffectView *)subview;
			break;
		}
	}

	BOOL isDarkMode = [DYYYUtils isDarkMode];
	UIBlurEffectStyle blurStyle = isDarkMode ? UIBlurEffectStyleDark : UIBlurEffectStyleLight;

	if (transparency <= 0 || transparency > 1) {
		transparency = 0.5;
	}

	if (!existingBlurView) {
		UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:blurStyle];
		UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
		blurEffectView.frame = parentView.bounds;
		blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		blurEffectView.alpha = transparency;
		blurEffectView.tag = 999;

		UIView *overlayView = [[UIView alloc] initWithFrame:parentView.bounds];
		CGFloat alpha = isDarkMode ? 0.2 : 0.1;
		overlayView.backgroundColor = [UIColor colorWithWhite:(isDarkMode ? 0 : 1) alpha:alpha];
		overlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[blurEffectView.contentView addSubview:overlayView];

		[parentView insertSubview:blurEffectView atIndex:0];
	} else {
		UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:blurStyle];
		[existingBlurView setEffect:blurEffect];
		existingBlurView.alpha = transparency;

		for (UIView *subview in existingBlurView.contentView.subviews) {
			CGFloat alpha = isDarkMode ? 0.2 : 0.1;
			subview.backgroundColor = [UIColor colorWithWhite:(isDarkMode ? 0 : 1) alpha:alpha];
		}

		[parentView insertSubview:existingBlurView atIndex:0];
	}
}

%hook UIView
- (void)layoutSubviews {
	%orig;

	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYisEnableFullScreen"]) {
		if (self.frame.size.height == tabHeight && tabHeight > 0) {
			UIViewController *vc = [self firstAvailableUIViewController];
			if ([vc isKindOfClass:NSClassFromString(@"AWEMixVideoPanelDetailTableViewController")] || [vc isKindOfClass:NSClassFromString(@"AWECommentInputViewController")]) {
				self.backgroundColor = [UIColor clearColor];
			}
		}
	}

	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYisEnableCommentBlur"]) {
		for (UIView *subview in self.subviews) {
			if ([subview isKindOfClass:NSClassFromString(@"AWECommentInputViewSwiftImpl.CommentInputViewMiddleContainer")]) {
				BOOL containsDanmu = NO;

				for (UIView *innerSubview in subview.subviews) {
					if ([innerSubview isKindOfClass:[UILabel class]] && [((UILabel *)innerSubview).text containsString:@"弹幕"]) {
						containsDanmu = YES;
						break;
					}
				}
				if (containsDanmu) {
					UIView *parentView = subview.superview;
					for (UIView *innerSubview in parentView.subviews) {
						if ([innerSubview isKindOfClass:[UIView class]]) {
							// NSLog(@"[innerSubview] %@", innerSubview);
							[innerSubview.subviews[0] removeFromSuperview];

							UIView *whiteBackgroundView = [[UIView alloc] initWithFrame:innerSubview.bounds];
							whiteBackgroundView.backgroundColor = [UIColor whiteColor];
							whiteBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
							[innerSubview addSubview:whiteBackgroundView];
							break;
						}
					}
				}
			}
		}

		NSString *className = NSStringFromClass([self class]);
		if ([className isEqualToString:@"AWECommentInputViewSwiftImpl.CommentInputContainerView"]) {
			for (UIView *subview in self.subviews) {
				if ([subview isKindOfClass:[UIView class]] && subview.backgroundColor) {
					CGFloat red = 0, green = 0, blue = 0, alpha = 0;
					[subview.backgroundColor getRed:&red green:&green blue:&blue alpha:&alpha];

					if ((red == 22 / 255.0 && green == 22 / 255.0 && blue == 22 / 255.0) || (red == 1.0 && green == 1.0 && blue == 1.0)) {
						float userTransparency = [[[NSUserDefaults standardUserDefaults] objectForKey:@"DYYYCommentBlurTransparent"] floatValue];
						if (userTransparency <= 0 || userTransparency > 1) {
							userTransparency = 0.95;
						}
						DYYYAddCustomViewToParent(subview, userTransparency);
					}
				}
			}
		}
	}

	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYisEnableCommentBarBlur"]) {
		for (UIView *subview in self.subviews) {
			if ([subview isKindOfClass:NSClassFromString(@"AWECommentInputViewSwiftImpl.CommentInputViewMiddleContainer")]) {
				BOOL containsDanmu = NO;
				for (UIView *innerSubviewCheck in subview.subviews) {
					if ([innerSubviewCheck isKindOfClass:[UILabel class]] && [((UILabel *)innerSubviewCheck).text containsString:@"弹幕"]) {
						containsDanmu = YES;
						break;
					}
				}
				if (!containsDanmu) {
					for (UIView *innerSubview in subview.subviews) {
						if ([innerSubview isKindOfClass:[UIView class]]) {
							float userTransparency = [[[NSUserDefaults standardUserDefaults] objectForKey:@"DYYYCommentBlurTransparent"] floatValue];
							if (userTransparency <= 0 || userTransparency > 1) {
								userTransparency = 0.95;
							}
							DYYYAddCustomViewToParent(innerSubview, userTransparency);
							break;
						}
					}
				}
			}
		}
	}

	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYisEnableFullScreen"] || [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYisEnableCommentBlur"]) {
		UIViewController *vc = [self firstAvailableUIViewController];
		if ([vc isKindOfClass:%c(AWEPlayInteractionViewController)]) {
			BOOL shouldHideSubview = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYisEnableFullScreen"] ||
						 [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYisEnableCommentBlur"];

			if (shouldHideSubview) {
				for (UIView *subview in self.subviews) {
					if ([subview isKindOfClass:[UIView class]] && subview.backgroundColor && CGColorEqualToColor(subview.backgroundColor.CGColor, [UIColor blackColor].CGColor)) {
						subview.hidden = YES;
					}
				}
			}
		}
	}
}

- (void)setFrame:(CGRect)frame {
	if (![NSThread isMainThread]) {
		dispatch_async(dispatch_get_main_queue(), ^{
		  [self setFrame:frame];
		});
		return;
	}

	BOOL enableBlur = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYisEnableCommentBlur"];
	BOOL enableFS = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYisEnableFullScreen"];
	BOOL hideAvatar = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYisHiddenAvatarList"];

	Class SkylightListViewClass = NSClassFromString(@"AWEIMSkylightListView");
	if (hideAvatar && SkylightListViewClass && [self isKindOfClass:SkylightListViewClass]) {
		frame = CGRectZero;
		%orig(frame);
		return;
	}

	UIViewController *vc = [self firstAvailableUIViewController];
	Class DetailVCClass = NSClassFromString(@"AWEMixVideoPanelDetailTableViewController");
	Class PlayVCClass1 = NSClassFromString(@"AWEAwemePlayVideoViewController");
	Class PlayVCClass2 = NSClassFromString(@"AWEDPlayerFeedPlayerViewController");

	BOOL isDetailVC = (DetailVCClass && [vc isKindOfClass:DetailVCClass]);
	BOOL isPlayVC = ((PlayVCClass1 && [vc isKindOfClass:PlayVCClass1]) || (PlayVCClass2 && [vc isKindOfClass:PlayVCClass2]));

	if (isPlayVC && enableBlur) {
		if (frame.origin.x != 0) {
			return;
		}
	}

	if (isPlayVC && enableFS) {
		if (frame.origin.x != 0 && frame.origin.y != 0) {
			%orig(frame);
			return;
		}
		CGRect superF = self.superview.frame;
		if (CGRectGetHeight(superF) > 0 && CGRectGetHeight(frame) > 0 && CGRectGetHeight(frame) < CGRectGetHeight(superF)) {
			CGFloat diff = CGRectGetHeight(superF) - CGRectGetHeight(frame);
			if (fabs(diff - tabHeight) < 1.0) {
				frame.size.height = CGRectGetHeight(superF);
			}
		}
		%orig(frame);
		return;
	}

	%orig(frame);
}

%end

%hook AFDFastSpeedView
- (void)layoutSubviews {
	%orig;
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYisEnableFullScreen"]) {
		for (UIView *subview in self.subviews) {
			if ([subview class] == [UIView class]) {
				[subview setBackgroundColor:[UIColor clearColor]];
			}
		}
	}
}
%end

%hook AWEPlayInteractionViewController
- (void)viewDidLayoutSubviews {
	%orig;

	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYisEnableFullScreen"]) {
		NSString *currentReferString = self.referString;
		CGRect frame = self.view.frame;

		// 根据referString来决定是否减去83点
		if ([currentReferString isEqualToString:@"general_search"]) {
			frame.size.height = self.view.superview.frame.size.height;
		} else if ([currentReferString isEqualToString:@"chat"] || currentReferString == nil) {
			frame.size.height = self.view.superview.frame.size.height;
		} else if ([currentReferString isEqualToString:@"search_result"] || currentReferString == nil) {
			frame.size.height = self.view.superview.frame.size.height;
		} else if ([currentReferString isEqualToString:@"close_friends_moment"] || currentReferString == nil) {
			frame.size.height = self.view.superview.frame.size.height;
		} else if ([currentReferString isEqualToString:@"offline_mode"] || currentReferString == nil) {
			frame.size.height = self.view.superview.frame.size.height;
		} else if ([currentReferString isEqualToString:@"others_homepage"] || currentReferString == nil) {
			frame.size.height = self.view.superview.frame.size.height - 83;
		} else {
			frame.size.height = self.view.superview.frame.size.height - 83;
		}

		self.view.frame = frame;
	}
}

%end

%hook AWEDPlayerFeedPlayerViewController

- (void)viewDidLayoutSubviews {
	%orig;
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYisEnableFullScreen"]) {
		UIView *contentView = self.contentView;
		if (contentView && contentView.superview) {
			CGRect frame = contentView.frame;
			CGFloat parentHeight = contentView.superview.frame.size.height;

			if (frame.size.height == parentHeight - 83) {
				frame.size.height = parentHeight;
				contentView.frame = frame;
			} else if (frame.size.height == parentHeight - 166) {
				frame.size.height = parentHeight - 83;
				contentView.frame = frame;
			}
		}
	}
}

%end

%hook AWEFeedTableView
- (void)layoutSubviews {
	%orig;
	CGFloat customHeight = customTabBarHeight();
	BOOL enableFS = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYisEnableFullScreen"];

	if (enableFS || customHeight > 0) {
		if (self.superview) {
			CGFloat diff = self.superview.frame.size.height - self.frame.size.height;
			if (diff > 0 && diff != tabHeight) {
				tabHeight = diff;
			}
		}

		CGRect frame = self.frame;
		if (enableFS) {
			frame.size.height = self.superview.frame.size.height;
		} else if (customHeight > 0) {
			frame.size.height = self.superview.frame.size.height - customHeight;
		}
		self.frame = frame;
	}
}
%end

%hook AWEPlayInteractionProgressContainerView
- (void)layoutSubviews {
	%orig;
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYisEnableFullScreen"]) {
		for (UIView *subview in self.subviews) {
			if ([subview class] == [UIView class]) {
				[subview setBackgroundColor:[UIColor clearColor]];
			}
		}
	}
}
%end

//缩放
%hook AWEElementStackView
static CGFloat stream_frame_y = 0;
static CGFloat right_tx = 0;
static CGFloat left_tx = 0;
static CGFloat currentScale = 1.0;
- (void)layoutSubviews {
	%orig;
	UIViewController *vc = [self firstAvailableUIViewController];
	if ([vc isKindOfClass:%c(AWECommentInputViewController)]) {
		NSString *transparentValue = [[NSUserDefaults standardUserDefaults] stringForKey:@"DYYYGlobalTransparency"];
		if (transparentValue.length > 0) {
			CGFloat alphaValue = transparentValue.floatValue;
			if (alphaValue >= 0.0 && alphaValue <= 1.0) {
				self.alpha = alphaValue;
			}
		}
	}
	if ([vc isKindOfClass:%c(AWELiveNewPreStreamViewController)]) {
		NSString *transparentValue = [[NSUserDefaults standardUserDefaults] stringForKey:@"DYYYGlobalTransparency"];
		if (transparentValue.length > 0) {
			CGFloat alphaValue = transparentValue.floatValue;
			if (alphaValue >= 0.0 && alphaValue <= 1.0) {
				self.alpha = alphaValue;
			}
		}
	}
	// 处理视频流直播间文案缩放
	UIResponder *nextResponder = [self nextResponder];
	if ([nextResponder isKindOfClass:[UIView class]]) {
		UIView *parentView = (UIView *)nextResponder;
		UIViewController *viewController = [parentView firstAvailableUIViewController];
		if ([viewController isKindOfClass:%c(AWELiveNewPreStreamViewController)]) {
			NSString *vcScaleValue = [[NSUserDefaults standardUserDefaults] objectForKey:@"DYYYNicknameScale"];
			if (vcScaleValue.length > 0) {
				CGFloat scale = [vcScaleValue floatValue];
				self.transform = CGAffineTransformIdentity;
				if (scale > 0 && scale != 1.0) {
					NSArray *subviews = [self.subviews copy];
					CGFloat ty = 0;
					for (UIView *view in subviews) {
						CGFloat viewHeight = view.frame.size.height;
						CGFloat contribution = (viewHeight - viewHeight * scale) / 2;
						ty += contribution;
					}
					CGFloat frameWidth = self.frame.size.width;
					CGFloat tx = (frameWidth - frameWidth * scale) / 2 - frameWidth * (1 - scale);
					CGAffineTransform newTransform = CGAffineTransformMakeScale(scale, scale);
					newTransform = CGAffineTransformTranslate(newTransform, tx / scale, ty / scale);
					self.transform = newTransform;
				}
			}
		}
	}
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYisEnableFullScreen"]) {
		UIResponder *nextResponder = [self nextResponder];
		if ([nextResponder isKindOfClass:[UIView class]]) {
			UIView *parentView = (UIView *)nextResponder;
			UIViewController *viewController = [parentView firstAvailableUIViewController];
			if ([viewController isKindOfClass:%c(AWELiveNewPreStreamViewController)]) {
				CGRect frame = self.frame;
				frame.origin.y -= tabHeight;
				stream_frame_y = frame.origin.y;
				self.frame = frame;
			}
		}
	}

	UIViewController *viewController = [self firstAvailableUIViewController];
        if ([viewController isKindOfClass:%c(AWEPlayInteractionViewController)]) {
                BOOL isRightElement = isRightInteractionStack(self);
                BOOL isLeftElement = isLeftInteractionStack(self);

		// 右侧元素的处理逻辑
		if (isRightElement) {
			NSString *scaleValue = [[NSUserDefaults standardUserDefaults] objectForKey:@"DYYYElementScale"];
			self.transform = CGAffineTransformIdentity;
			if (scaleValue.length > 0) {
				CGFloat scale = [scaleValue floatValue];
				if (currentScale != scale) {
					currentScale = scale;
				}
				if (scale > 0 && scale != 1.0) {
					CGFloat ty = 0;
					for (UIView *view in self.subviews) {
						CGFloat viewHeight = view.frame.size.height;
						CGFloat contribution = (viewHeight - viewHeight * scale) / 2;
						ty += contribution;
					}
					CGFloat frameWidth = self.frame.size.width;
					right_tx = (frameWidth - frameWidth * scale) / 2;
					self.transform = CGAffineTransformMake(scale, 0, 0, scale, right_tx, ty);
				} else {
					self.transform = CGAffineTransformIdentity;
				}
			}
		}
		// 左侧元素的处理逻辑
		else if (isLeftElement) {
			NSString *scaleValue = [[NSUserDefaults standardUserDefaults] objectForKey:@"DYYYNicknameScale"];
			if (scaleValue.length > 0) {
				CGFloat scale = [scaleValue floatValue];
				self.transform = CGAffineTransformIdentity;
				if (scale > 0 && scale != 1.0) {
					NSArray *subviews = [self.subviews copy];
					CGFloat ty = 0;
					for (UIView *view in subviews) {
						CGFloat viewHeight = view.frame.size.height;
						CGFloat contribution = (viewHeight - viewHeight * scale) / 2;
						ty += contribution;
					}
					CGFloat frameWidth = self.frame.size.width;
					CGFloat left_tx = (frameWidth - frameWidth * scale) / 2 - frameWidth * (1 - scale);
					CGAffineTransform newTransform = CGAffineTransformMakeScale(scale, scale);
					newTransform = CGAffineTransformTranslate(newTransform, left_tx / scale, ty / scale);
					self.transform = newTransform;
				}
			}
		}
	}
}
- (NSArray<__kindof UIView *> *)arrangedSubviews {

        UIViewController *viewController = [self firstAvailableUIViewController];
        if ([viewController isKindOfClass:%c(AWEPlayInteractionViewController)]) {
                BOOL isLeftElement = isLeftInteractionStack(self);

		if (isLeftElement) {
			NSString *scaleValue = [[NSUserDefaults standardUserDefaults] objectForKey:@"DYYYNicknameScale"];
			if (scaleValue.length > 0) {
				CGFloat scale = [scaleValue floatValue];
				self.transform = CGAffineTransformIdentity;
				if (scale > 0 && scale != 1.0) {
					NSArray *subviews = [self.subviews copy];
					CGFloat ty = 0;
					for (UIView *view in subviews) {
						CGFloat viewHeight = view.frame.size.height;
						CGFloat contribution = (viewHeight - viewHeight * scale) / 2;
						ty += contribution;
					}
					CGFloat frameWidth = self.frame.size.width;
					CGFloat left_tx = (frameWidth - frameWidth * scale) / 2 - frameWidth * (1 - scale);
					CGAffineTransform newTransform = CGAffineTransformMakeScale(scale, scale);
					newTransform = CGAffineTransformTranslate(newTransform, left_tx / scale, ty / scale);
					self.transform = newTransform;
				}
			}
		}
	}

	NSArray *originalSubviews = %orig;
	return originalSubviews;
}
%end

%hook AWEStoryContainerCollectionView
- (void)layoutSubviews {
	%orig;
	if ([self.subviews count] == 2)
		return;

	// 获取 enableEnterProfile 属性来判断是否是主页
	id enableEnterProfile = [self valueForKey:@"enableEnterProfile"];
	BOOL isHome = (enableEnterProfile != nil && [enableEnterProfile boolValue]);

	// 检查是否在作者主页
	BOOL isAuthorProfile = NO;
	UIResponder *responder = self;
	while ((responder = [responder nextResponder])) {
		if ([NSStringFromClass([responder class]) containsString:@"UserHomeViewController"] || [NSStringFromClass([responder class]) containsString:@"ProfileViewController"]) {
			isAuthorProfile = YES;
			break;
		}
	}

	// 如果不是主页也不是作者主页，直接返回
	if (!isHome && !isAuthorProfile)
		return;

	for (UIView *subview in self.subviews) {
		if ([subview isKindOfClass:[UIView class]]) {
			UIView *nextResponder = (UIView *)subview.nextResponder;

			// 处理主页的情况
			if (isHome && [nextResponder isKindOfClass:%c(AWEPlayInteractionViewController)]) {
				UIViewController *awemeBaseViewController = [nextResponder valueForKey:@"awemeBaseViewController"];
				if (![awemeBaseViewController isKindOfClass:%c(AWEFeedCellViewController)]) {
					continue;
				}

				CGRect frame = subview.frame;
				if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYisEnableFullScreen"]) {
					frame.size.height = subview.superview.frame.size.height - tabHeight;
					subview.frame = frame;
				}
			}
			// 处理作者主页的情况
			else if (isAuthorProfile) {
				// 检查是否是作品图片
				BOOL isWorkImage = NO;

				// 可以通过检查子视图、标签或其他特性来确定是否是作品图片
				for (UIView *childView in subview.subviews) {
					if ([NSStringFromClass([childView class]) containsString:@"ImageView"] || [NSStringFromClass([childView class]) containsString:@"ThumbnailView"]) {
						isWorkImage = YES;
						break;
					}
				}

				if (isWorkImage) {
					// 修复作者主页作品图片上移问题
					CGRect frame = subview.frame;
					frame.origin.y += tabHeight;
					subview.frame = frame;
				}
			}
		}
	}
}
%end

%hook AWELandscapeFeedEntryView
- (void)setCenter:(CGPoint)center {
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYisEnableFullScreen"] || [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYisEnableCommentBlur"]) {
		center.y += 50;
	}

	%orig(center);
}

- (void)layoutSubviews {
	%orig;
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYisHiddenEntry"]) {
		[self removeFromSuperview];
	}
}

%end

%hook AWENormalModeTabBar

- (void)layoutSubviews {
	%orig;

	CGFloat h = customTabBarHeight();
	if (h > 0) {
		if ([self respondsToSelector:@selector(setDesiredHeight:)]) {
			((void (*)(id, SEL, double))objc_msgSend)(self, @selector(setDesiredHeight:), h);
		}
		CGRect frame = self.frame;
		if (fabs(frame.size.height - h) > 0.5) {
			frame.size.height = h;
			if (self.superview) {
				frame.origin.y = self.superview.bounds.size.height - h;
			}
			self.frame = frame;
		}
	}

	BOOL hideShop = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideShopButton"];
	BOOL hideMsg = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideMessageButton"];
	BOOL hideFri = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideFriendsButton"];
	BOOL hideMe = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideMyButton"];

	NSMutableArray *visibleButtons = [NSMutableArray array];
	Class generalButtonClass = %c(AWENormalModeTabBarGeneralButton);
	Class plusButtonClass = %c(AWENormalModeTabBarGeneralPlusButton);
	Class tabBarButtonClass = %c(UITabBarButton);

	for (UIView *subview in self.subviews) {
		if (![subview isKindOfClass:generalButtonClass] && ![subview isKindOfClass:plusButtonClass])
			continue;

		NSString *label = subview.accessibilityLabel;
		BOOL shouldHide = NO;

		if ([label isEqualToString:@"商城"]) {
			shouldHide = hideShop;
		} else if ([label containsString:@"消息"]) {
			shouldHide = hideMsg;
		} else if ([label containsString:@"朋友"]) {
			shouldHide = hideFri;
		} else if ([label containsString:@"我"]) {
			shouldHide = hideMe;
		}

		if (!shouldHide) {
			[visibleButtons addObject:subview];
		} else {
			subview.userInteractionEnabled = NO;
			[subview removeFromSuperview];
		}
	}

	for (UIView *subview in self.subviews) {
		if (![subview isKindOfClass:tabBarButtonClass])
			continue;
		subview.userInteractionEnabled = NO;
		[subview removeFromSuperview];
	}

	[visibleButtons sortUsingComparator:^NSComparisonResult(UIView *a, UIView *b) {
	  return [@(a.frame.origin.x) compare:@(b.frame.origin.x)];
	}];

	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		// iPad端布局逻辑
		UIView *targetView = nil;
		CGFloat containerWidth = self.bounds.size.width;
		CGFloat offsetX = 0;

		// 查找目标容器视图
		for (UIView *subview in self.subviews) {
			if ([subview class] == [UIView class] && fabs(subview.frame.size.width - self.bounds.size.width) > 0.1) {
				targetView = subview;
				containerWidth = subview.frame.size.width;
				offsetX = subview.frame.origin.x;
				break;
			}
		}

		// 在目标容器内均匀分布按钮
		CGFloat buttonWidth = containerWidth / visibleButtons.count;
		for (NSInteger i = 0; i < visibleButtons.count; i++) {
			UIView *button = visibleButtons[i];
			button.frame = CGRectMake(offsetX + (i * buttonWidth), button.frame.origin.y, buttonWidth, button.frame.size.height);
		}
	} else {
		// iPhone端布局逻辑
		CGFloat totalWidth = self.bounds.size.width;
		CGFloat buttonWidth = totalWidth / visibleButtons.count;

		for (NSInteger i = 0; i < visibleButtons.count; i++) {
			UIView *button = visibleButtons[i];
			button.frame = CGRectMake(i * buttonWidth, button.frame.origin.y, buttonWidth, button.frame.size.height);
		}
	}
}

- (void)setHidden:(BOOL)hidden {
	%orig(hidden);

	Class generalButtonClass = %c(AWENormalModeTabBarGeneralButton);
	BOOL disableHomeRefresh = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYDisableHomeRefresh"];

	for (UIView *subview in self.subviews) {
		if ([subview isKindOfClass:generalButtonClass]) {
			AWENormalModeTabBarGeneralButton *button = (AWENormalModeTabBarGeneralButton *)subview;
			if ([button.accessibilityLabel isEqualToString:@"首页"] && disableHomeRefresh) {
				button.userInteractionEnabled = (button.status != 2);
			}
		}
	}

	BOOL hideBottomBg = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYisHiddenBottomBg"];

	// 如果开启了隐藏底部背景，则直接隐藏背景视图
	if (hideBottomBg) {
		UIView *backgroundView = nil;
		for (UIView *subview in self.subviews) {
			if ([subview class] == [UIView class]) {
				BOOL hasImageView = NO;
				for (UIView *childView in subview.subviews) {
					if ([childView isKindOfClass:[UIImageView class]]) {
						hasImageView = YES;
						break;
					}
				}
				if (hasImageView) {
					backgroundView = subview;
					backgroundView.hidden = YES;
					break;
				}
			}
		}
	} else {
		// 仅对全屏模式处理背景显示逻辑
		if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYisEnableFullScreen"]) {
			UIView *backgroundView = nil;
			BOOL hideFriendsButton = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideFriendsButton"];
			BOOL isHomeSelected = NO;
			BOOL isFriendsSelected = NO;

			for (UIView *subview in self.subviews) {
				if ([subview class] == [UIView class]) {
					BOOL hasImageView = NO;
					for (UIView *childView in subview.subviews) {
						if ([childView isKindOfClass:[UIImageView class]]) {
							hasImageView = YES;
							break;
						}
					}
					if (hasImageView) {
						backgroundView = subview;
						break;
					}
				}
			}

			// 查找当前选中的按钮
			for (UIView *subview in self.subviews) {
				if ([subview isKindOfClass:generalButtonClass]) {
					AWENormalModeTabBarGeneralButton *button = (AWENormalModeTabBarGeneralButton *)subview;
					// status == 2 表示按钮处于选中状态
					if (button.status == 2) {
						if ([button.accessibilityLabel isEqualToString:@"首页"]) {
							isHomeSelected = YES;
						} else if ([button.accessibilityLabel containsString:@"朋友"]) {
							isFriendsSelected = YES;
						}
					}
				}
			}

			// 根据当前选中的按钮决定是否显示背景
			if (backgroundView) {
				BOOL shouldShowBackground = isHomeSelected || (isFriendsSelected && !hideFriendsButton);
				backgroundView.hidden = shouldShowBackground;
			}
		}
	}

	// 隐藏分隔线
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYisEnableFullScreen"]) {
		for (UIView *subview in self.subviews) {
			if (![subview isKindOfClass:[UIView class]])
				continue;
			if (subview.frame.size.height <= 0.5 && subview.frame.size.width > 300) {
				subview.hidden = YES;
				CGRect frame = subview.frame;
				frame.size.height = 0;
				subview.frame = frame;
				subview.alpha = 0;
			}
		}
	}
}

%end

%hook AWEAwemeDetailTableView

- (void)setFrame:(CGRect)frame {
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYisEnableFullScreen"]) {
		CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;

		CGFloat remainder = fmod(frame.size.height, screenHeight);
		if (remainder != 0) {
			frame.size.height += (screenHeight - remainder);
		}
	}
	%orig(frame);
}

%end

%hook AWEMixVideoPanelMoreView

- (void)setFrame:(CGRect)frame {
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYisEnableFullScreen"]) {
		frame.origin.y -= 83;
	}
	%orig(frame);
}
- (void)layoutSubviews {
	%orig;

	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYisEnableFullScreen"]) {
		self.backgroundColor = [UIColor clearColor];
	}
}

%end

%hook CommentInputContainerView

- (void)layoutSubviews {
	%orig;
	UIViewController *parentVC = nil;
	if ([self respondsToSelector:@selector(viewController)]) {
		id viewController = [self performSelector:@selector(viewController)];
		if ([viewController respondsToSelector:@selector(parentViewController)]) {
			parentVC = [viewController parentViewController];
		}
	}

	if (parentVC && ([parentVC isKindOfClass:%c(AWEAwemeDetailTableViewController)] || [parentVC isKindOfClass:%c(AWEAwemeDetailCellViewController)])) {
		for (UIView *subview in [self subviews]) {
			if ([subview class] == [UIView class]) {
				if ([(UIView *)self frame].size.height == tabHeight) {
					subview.hidden = YES;
				} else {
					subview.hidden = NO;
				}
				break;
			}
		}
	}
}

%end

%ctor {
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYUserAgreementAccepted"]) {
		static dispatch_once_t onceToken;
		dispatch_once(&onceToken, ^{
		  Class wSwiftImpl = objc_getClass("AWECommentInputViewSwiftImpl.CommentInputContainerView");
		  %init(CommentInputContainerView = wSwiftImpl);
		});
	}
}
