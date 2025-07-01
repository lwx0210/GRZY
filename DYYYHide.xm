#import "AwemeHeaders.h"

%hook AWEFeedLiveMarkView
- (void)setHidden:(BOOL)hidden {
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideAvatarButton"]) {
		hidden = YES;
	}

	%orig(hidden);
}
%end

// 隐藏直播间文字贴纸
%hook IESLiveStickerView
- (void)layoutSubviews {
	%orig;
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideStickerView"]) {
		[self removeFromSuperview];
	}
}
%end

// 预约直播
%hook IESLivePreAnnouncementPanelViewNew
- (void)layoutSubviews {
	%orig;
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideStickerView"]) {
		[self removeFromSuperview];
	}
}
%end

// 隐藏进场特效
%hook IESLiveDynamicUserEnterView
- (void)layoutSubviews {
	%orig;
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideLivePopup"]) {
		[self removeFromSuperview];
	}
}
%end

%hook IESLiveGameCPExplainCardContainerImpl
- (void)layoutSubviews {
	%orig;
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideLiveGoodsMsg"]) {
		[self removeFromSuperview];
	}
}
%end

%hook AWEPOILivePurchaseAtmosphereView
- (void)layoutSubviews {
	%orig;
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideLiveGoodsMsg"] && self.superview) {
		[self.superview removeFromSuperview];
	}
}
%end

%hook IESLiveActivityBannnerView
- (void)layoutSubviews {
	%orig;
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideLiveGoodsMsg"]) {
		[self removeFromSuperview];
	}
}
%end

%hook IESLiveBottomRightCardView
- (void)layoutSubviews {
	%orig;
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideLiveGoodsMsg"]) {
		[self removeFromSuperview];
	}
}
%end

%hook IESLiveDynamicRankListEntranceView
- (void)layoutSubviews {
	%orig;
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideLiveDetail"]) {
		[self removeFromSuperview];
	}
}
%end

%hook IESLiveMatrixEntranceView
- (void)layoutSubviews {
	%orig;
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideLiveDetail"]) {
		[self removeFromSuperview];
	}
}
%end

%hook IESLiveShortTouchActionView
- (void)layoutSubviews {
	%orig;
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideTouchView"]) {
		[self removeFromSuperview];
	}
}
%end

%hook IESLiveLotteryAnimationViewNew
- (void)layoutSubviews {
	%orig;
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideTouchView"]) {
		[self removeFromSuperview];
	}
}
%end

%hook IESLiveConfigurableShortTouchEntranceView
- (void)layoutSubviews {
	%orig;
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideTouchView"]) {
		[self removeFromSuperview];
	}
}
%end

%hook IESLiveRedEnvelopeAniLynxView
- (void)layoutSubviews {
	%orig;
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideTouchView"]) {
		[self removeFromSuperview];
	}
}
%end

// 禁用自动进入直播间
%hook AWELiveGuideElement

- (BOOL)enableAutoEnterRoom {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYDisableAutoEnterLive"]) {
        return NO;
    }
    return %orig;
}

- (BOOL)enableNewAutoEnter {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYDisableAutoEnterLive"]) {
        return NO;
    }
    return %orig;
}

%end

//拍摄图标
%hook AWENormalModeTabBarGeneralPlusButton
- (void)setImage:(UIImage *)image forState:(UIControlState)state {

	if ([self.accessibilityLabel isEqualToString:@"拍摄"]) {

		NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
		NSString *dyyyFolderPath = [documentsPath stringByAppendingPathComponent:@"DYYY"];

		NSString *customImagePath = [dyyyFolderPath stringByAppendingPathComponent:@"tab_plus.png"];

		if ([[NSFileManager defaultManager] fileExistsAtPath:customImagePath]) {
			UIImage *customImage = [UIImage imageWithContentsOfFile:customImagePath];
			if (customImage) {

				%orig(customImage, state);
				return;
			}
		}
	}

	%orig;
}
%end

//修改id
%hook AWEUserHomeAccessibilityViewV2

- (void)layoutSubviews {
    %orig;

    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYEnableDisguise"]) {
        return;
    }
    
        [self findAndModifyDouyinLabelInView:self];
        [self modifyNicknameInView:self];
    
    
}
%new
- (void)findAndModifyDouyinLabelInView:(UIView *)view {
    for (UIView *subview in view.subviews) {
        if ([subview isKindOfClass:[UILabel class]]) {
            UILabel *label = (UILabel *)subview;
            if ([label.text containsString:@"抖音号"]) {
                NSString *dyid = [[NSUserDefaults standardUserDefaults] objectForKey:@"DYYYDisguiseid"];
                if (dyid.length > 0) {
                    label.text = [NSString stringWithFormat:@"抖音号：%@", dyid];                    
                }
            }
        } else {

            [self findAndModifyDouyinLabelInView:subview];
        }
    }
}
- (void)findAndModify:(UIView *)view {
    for (UIView *subview in view.subviews) {
        if ([subview isKindOfClass:[UILabel class]]) {
            UILabel *label = (UILabel *)subview;
            if ([label.text containsString:@"新访客"]) {
                NSString *dyid = [[NSUserDefaults standardUserDefaults] objectForKey:@"DYYYDisguisefk"];
                if (dyid.length > 0) {
                    label.text = [NSString stringWithFormat:@"新访客：%@", dyid];                    
                }
            }
        } else {

            [self findAndModify:subview];
        }
    }
}
%new
- (void)modifyNicknameInView:(UIView *)view {
    for (UIView *subview in view.subviews) {        
        if ([subview isKindOfClass:NSClassFromString(@"AWEProfileBillboardLabel")]) {
            UILabel *label = (UILabel *)subview;
            NSString *newName = [[NSUserDefaults standardUserDefaults] objectForKey:@"DYYYDisguisenc"];
            if (newName.length > 0) {
                label.text = newName;                
            }
        } else {

            [self modifyNicknameInView:subview];
        }
    }
}

%end

//隐藏去商城看看
%hook AWEFeedTabJumpGuideView

- (void)layoutSubviews {
    %orig; 

    if (DYYYGetBool(@"DYYYHideJumpGuide")) {
        [self removeFromSuperview];
    }
}

%end

// 隐藏文案箭头
%hook AWEPlayInteractionDescriptionLabel
- (void)layoutSubviews {
    %orig;
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideDescriptionArrow"]) {
        for (UIView *subview in [self subviews]) {
            if ([subview isKindOfClass:[UIImageView class]]) {
                [(UIImageView *)subview setHidden:YES];
            }
        }
    }
}
%end

// 强制启用保存他人头像
%hook AFDProfileAvatarFunctionManager
- (BOOL)shouldShowSaveAvatarItem {
	BOOL shouldEnable = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYEnableSaveAvatar"];
	if (shouldEnable) {
		return YES;
	}
	return %orig;
}
%end

// 隐藏头像加号和透明
%hook LOTAnimationView
- (void)layoutSubviews {
	%orig;

	// 检查是否需要隐藏加号
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideLOTAnimationView"]) {
		[self removeFromSuperview];
		return;
	}

	// 应用透明度设置
	NSString *transparencyValue = [[NSUserDefaults standardUserDefaults] objectForKey:@"DYYYAvatarViewTransparency"];
	if (transparencyValue && transparencyValue.length > 0) {
		CGFloat alphaValue = [transparencyValue floatValue];
		if (alphaValue >= 0.0 && alphaValue <= 1.0) {
			self.tag = DYYY_IGNORE_GLOBAL_ALPHA_TAG;
			self.alpha = alphaValue;
		}
	}
}
%end

//隐藏底部热点框
%hook AWENewHotSpotBottomBarView
- (void)layoutSubviews {
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideHotspot"]) {
		if ([self respondsToSelector:@selector(removeFromSuperview)]) {
			[self removeFromSuperview];
		}
		self.hidden = YES;
		return;
	}
	%orig;
}
%end

// 隐藏章节进度条
%hook AWEDemaciaChapterProgressSlider

- (void)layoutSubviews {
	%orig;

	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideChapterProgress"]) {
		[self removeFromSuperview];
	}
}

%end

// 首页头像隐藏和透明
%hook AWEAdAvatarView
- (void)layoutSubviews {
	%orig;

	// 检查是否需要隐藏头像
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideAvatarButton"]) {
		[self removeFromSuperview];
		return;
	}

	// 应用透明度设置
	NSString *transparencyValue = [[NSUserDefaults standardUserDefaults] objectForKey:@"DYYYAvatarViewTransparency"];
	if (transparencyValue && transparencyValue.length > 0) {
		CGFloat alphaValue = [transparencyValue floatValue];
		if (alphaValue >= 0.0 && alphaValue <= 1.0) {
			self.alpha = alphaValue;
		}
	}
}
%end

// 隐藏直播间商品信息
%hook IESECLivePluginLayoutView
- (void)layoutSubviews {
	%orig;
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideLiveGoodsMsg"]) {
		[self removeFromSuperview];
	}
}
%end

// 隐藏直播间点赞动画
%hook HTSLiveDiggView
- (void)setIconImageView:(UIImageView *)arg1 {
	if (DYYYGetBool(@"DYYYHideLiveLikeAnimation")) {
		%orig(nil);
	} else {
		%orig(arg1);
	}
}
%end

// 移除同城吃喝玩乐提示框
%hook AWENearbySkyLightCapsuleView
- (void)layoutSubviews {
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideNearbyCapsuleView"]) {
		if ([self respondsToSelector:@selector(removeFromSuperview)]) {
			[self removeFromSuperview];
		}
		self.hidden = YES;
		return;
	}
	%orig;
}
%end

// 移除共创头像列表
%hook AWEPlayInteractionCoCreatorNewInfoView
- (void)layoutSubviews {
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideGongChuang"]) {
		if ([self respondsToSelector:@selector(removeFromSuperview)]) {
			[self removeFromSuperview];
		}
		self.hidden = YES;
		return;
	}
	%orig;
}
%end

// 隐藏右下音乐和取消静音按钮
%hook AFDCancelMuteAwemeView
- (void)layoutSubviews {
	%orig;

	UIView *superview = self.superview;

	if ([superview isKindOfClass:NSClassFromString(@"AWEBaseElementView")]) {
		if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideCancelMute"]) {
			self.hidden = YES;
		}
	}
}
%end

//隐藏展开渐变
%hook AWEPlayInteractionElementMaskView
- (void)layoutSubviews {
	%orig;

	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideGradient"]) {
		[self removeFromSuperview];
		return;
	}
}
%end

%hook AWEGradientView
- (void)layoutSubviews {
	%orig;
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideGradient"]) {
		UIView *parent = self.superview;
		if ([parent.accessibilityLabel isEqualToString:@"暂停，按钮"] || [parent.accessibilityLabel isEqualToString:@"播放，按钮"] ||
		    [parent.accessibilityLabel isEqualToString:@"“切换视角，按钮"]) {
			[self removeFromSuperview];
		}
		return;
	}
}
%end

%hook AWEHotSpotBlurView
- (void)layoutSubviews {
	%orig;

	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideGradient"]) {
		[self removeFromSuperview];
		return;
	}
}
%end

%hook AWEHotSearchInnerBottomView
- (void)layoutSubviews {
	%orig;

	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideHotSearch"]) {
		[self removeFromSuperview];
		return;
	}
}
%end

// 热点状态栏
%hook AWEAwemeHotSpotTableViewController
- (BOOL)prefersStatusBarHidden {
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYisHideStatusbar"]) {
		return YES;
	} else {
		if (class_getInstanceMethod([self class], @selector(prefersStatusBarHidden)) !=
		    class_getInstanceMethod([%c(AWEAwemeHotSpotTableViewController) class], @selector(prefersStatusBarHidden))) {
			return %orig;
		}
		return NO;
	}
}
%end

// 隐藏弹幕按钮
%hook AWEPlayDanmakuInputContainView

- (void)layoutSubviews {
	%orig;

	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideDanmuButton"]) {
		self.hidden = YES;
	}
}

%end

// 隐藏作者店铺
%hook AWEECommerceEntryView

- (void)layoutSubviews {
	%orig;

	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideHisShop"]) {
		UIView *parentView = self.superview;
		if (parentView) {
			parentView.hidden = YES;
		} else {
			self.hidden = YES;
		}
	}
}

%end

// 隐藏评论搜索
%hook AWECommentSearchAnchorView
- (void)layoutSubviews {
	%orig;

	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideCommentViews"]) {
		[self setHidden:YES];
	}
}

%end

// 隐藏评论区定位
%hook AWEPOIEntryAnchorView

- (void)p_addViews {
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideCommentViews"]) {
		return;
	}
	%orig;
}

%end

// 隐藏观看历史搜索
%hook AWEDiscoverFeedEntranceView
- (id)init {
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideInteractionSearch"]) {
		return nil;
	}
	return %orig;
}
%end

// 隐藏校园提示
%hook AWETemplateTagsCommonView

- (void)layoutSubviews {
	%orig;

	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideTemplateTags"]) {
		UIView *parentView = self.superview;
		if (parentView) {
			parentView.hidden = YES;
		} else {
			self.hidden = YES;
		}
	}
}

%end

//隐藏评论搜索
%hook UIImageView
- (void)layoutSubviews {
	%orig;
	if([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideCommentDiscover"]) {
		if (!self.accessibilityLabel) {
			UIView *parentView = self.superview;

			if (parentView && [parentView class] == [UIView class] && [parentView.accessibilityLabel isEqualToString:@"搜索"]) {
				self.hidden = YES;
			}

			else if (parentView && [NSStringFromClass([parentView class]) isEqualToString:@"AWESearchEntryHalfScreenElement"] && [parentView.accessibilityLabel isEqualToString:@"搜索"]) {
				self.hidden = YES;
			}
		}
	}
}
%end

// 隐藏挑战贴纸
%hook AWEFeedStickerContainerView

- (BOOL)isHidden {
	BOOL origHidden = %orig;
	BOOL hideRecommend = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideChallengeStickers"];
	return origHidden || hideRecommend;
}

- (void)setHidden:(BOOL)hidden {
	BOOL forceHide = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideChallengeStickers"];
	%orig(forceHide ? YES : hidden);
}

%end

//挑战贴纸
%hook ACCGestureResponsibleStickerView
- (void)layoutSubviews {
	%orig;

	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideChallengeStickers"]) {
		[self removeFromSuperview];
		return;
	}
}
%end

// 去除"我的"加入挑战横幅
%hook AWEPostWorkViewController
- (BOOL)isDouGuideTipViewShow {
	BOOL r = %orig;
	NSLog(@"Original value: %@", @(r));
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideChallengeStickers"]) {
		NSLog(@"Force return YES");
		return YES;
	}
	return r;
}
%end

// 隐藏消息页顶栏头像气泡
%hook AFDSkylightCellBubble
- (void)layoutSubviews {
	%orig;

	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYisHiddenAvatarBubble"]) {
		[self removeFromSuperview];
		return;
	}
}
%end

// 隐藏消息页开启通知提示
%hook AWEIMMessageTabOptPushBannerView

- (instancetype)initWithFrame:(CGRect)frame {
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHidePushBanner"]) {
		return %orig(CGRectMake(frame.origin.x, frame.origin.y, 0, 0));
	}
	return %orig;
}

%end

//隐藏我的页面左上角添加朋友
%hook AWEProfileNavigationButton
- (void)setupUI {

	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideButton"]) {
		return;
	}
	%orig;
}
%end

// 默认隐藏清屏横线
%hook AWELoadingAndVolumeView
- (void)setHidden:(BOOL)hidden {
    %orig(YES);
}
%end

// 隐藏每日精选
%hook AWETemplateTagsCommonView
- (id)initWithFrame:(CGRect)frame {
    self = %orig;
    if ([NSUserDefaults.standardUserDefaults boolForKey:@"DYYYHideMrjingxuan"]) {
        self.hidden = YES;
    }
    return self;
}
%end

// 隐藏朋友"关注/不关注"按钮
%hook AWEFeedUnfollowFamiliarFollowAndDislikeView
- (void)showUnfollowFamiliarView {
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideFamiliar"]) {
		self.hidden = YES;
		return;
	}
	%orig;
}
%end

// 隐藏朋友日常按钮
%hook AWEFamiliarNavView
- (void)layoutSubviews {

	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideFamiliar"]) {
		self.hidden = YES; 
	}

	%orig;
}
%end

%hook UIView 
- (void)addSubview:(UIView *)view {
    %orig;
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideAiSearch"] &&
       [view isKindOfClass:NSClassFromString(@"AWESearchKeyboardVoiceSearchEntranceView")]) {
        [view setHidden:YES];
        [self removeFromSuperview];
    }
}
%end

//隐藏加入挑战及左侧返回
%hook UIButton

- (void)setTitle:(NSString *)title forState:(UIControlState)state {
	%orig;

	if ([title isEqualToString:@"加入挑战"]) {
		dispatch_async(dispatch_get_main_queue(), ^{
		  if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideChallengeStickers"]) {
			  UIResponder *responder = self;
			  BOOL isInPlayInteractionViewController = NO;

			  while ((responder = [responder nextResponder])) {
				  if ([responder isKindOfClass:%c(AWEPlayInteractionViewController)]) {
					  isInPlayInteractionViewController = YES;
					  break;
				  }
			  }

			  if (isInPlayInteractionViewController) {
				  UIView *parentView = self.superview;
				  if (parentView) {
					  UIView *grandParentView = parentView.superview;
					  if (grandParentView) {
						  grandParentView.hidden = YES;
					  } else {
						  parentView.hidden = YES;
					  }
				  } else {
					  self.hidden = YES;
				  }
			  }
		  }
		});
	}
}

- (void)layoutSubviews {
	%orig;

	NSString *accessibilityLabel = self.accessibilityLabel;

	if ([accessibilityLabel isEqualToString:@"拍照搜同款"] || [accessibilityLabel isEqualToString:@"扫一扫"]) {
		if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideScancode"]) {
			[self removeFromSuperview];
			return;
		}
	}

	if ([accessibilityLabel isEqualToString:@"返回"]) {
		if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideBack"]) {
			UIView *parent = self.superview;
			// 父视图是AWEBaseElementView(排除用户主页返回按钮) 按钮类是AWENoxusHighlightButton(排除横屏返回按钮)
			if ([parent isKindOfClass:%c(AWEBaseElementView)] && ![self isKindOfClass:%c(AWENoxusHighlightButton)]) {
				[self removeFromSuperview];
			}
			return;
		}
	}
}

%end

// 隐藏评论区免费去看短剧
%hook AWEShowPlayletCommentHeaderView
- (void)layoutSubviews {
	%orig;

	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideCommentViews"]) {
		[self setHidden:YES];
	}
}

%end

// 隐藏合集和声明
%hook AWEAntiAddictedNoticeBarView
- (void)layoutSubviews {
	%orig;

	// 获取 tipsLabel 属性
	UILabel *tipsLabel = [self valueForKey:@"tipsLabel"];

	if (tipsLabel && [tipsLabel isKindOfClass:%c(UILabel)]) {
		NSString *labelText = tipsLabel.text;

		if (labelText) {
			// 明确判断是合集还是作者声明
			if ([labelText containsString:@"合集"]) {
				// 如果是合集，只检查合集的开关
				if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideTemplateVideo"]) {
					[self removeFromSuperview];
				} else if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYisEnableFullScreen"]) {
					self.backgroundColor = [UIColor clearColor];
				}
			} else {
				// 如果不是合集（即作者声明），只检查声明的开关
				if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideAntiAddictedNotice"]) {
					[self removeFromSuperview];
				}
			}
		}
	}
}
- (void)setBackgroundColor:(UIColor *)backgroundColor {
	// 禁用背景色设置
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideGradient"]) {
		%orig(UIColor.clearColor);
	} else {
		%orig(backgroundColor);
	}
}
%end

//遮罩效果
%hook AWELiveAutoEnterStyleAView

- (void)layoutSubviews {
	%orig;

	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHidenLiveView"]) {
		[self removeFromSuperview];
		return;
	}
}

%end

// 隐藏分享给朋友提示
%hook AWEPlayInteractionStrongifyShareContentView

- (void)layoutSubviews {
	%orig;

	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideShareContentView"]) {
		UIView *parentView = self.superview;
		if (parentView) {
			parentView.hidden = YES;
		} else {
			self.hidden = YES;
		}
	}
}

%end

// 移除下面推荐框黑条
%hook AWEPlayInteractionRelatedVideoView
- (void)layoutSubviews {
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideBottomRelated"]) {
		if ([self respondsToSelector:@selector(removeFromSuperview)]) {
			[self removeFromSuperview];
		}
		self.hidden = YES;
		return;
	}
	%orig;
}
%end

%hook AWEIMFeedVideoQuickReplayInputViewController

- (void)viewDidLayoutSubviews {
    %orig;

    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideReply"]) {
        [self.view removeFromSuperview];
    }
}

%end


%hook AWEHPSearchBubbleEntranceView
- (void)layoutSubviews {
	%orig;

	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideSearchBubble"]) {
		[self removeFromSuperview];
		return;
	}
}

%end

%hook AWEFeedRelatedSearchTipView
- (void)layoutSubviews {
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideBottomRelated"]) {
		if ([self respondsToSelector:@selector(removeFromSuperview)]) {
			[self removeFromSuperview];
		}
		self.hidden = YES;
		return;
	}
	%orig;
}
%end

%hook AWENormalModeTabBarBadgeContainerView

- (void)layoutSubviews {
	%orig;
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYisHiddenBottomDot"]) {
		for (UIView *subview in [self subviews]) {
			if ([subview isKindOfClass:NSClassFromString(@"DUXBadge")]) {
				[subview setHidden:YES];
			}
		}
	}
}

%end

//侧栏红点
%hook AWELeftSideBarEntranceView
- (void)layoutSubviews {
    %orig;
    
    UIResponder *responder = self;
    UIViewController *parentVC = nil;
    while ((responder = [responder nextResponder])) {
        if ([responder isKindOfClass:%c(AWEFeedContainerViewController)]) {
            parentVC = (UIViewController *)responder;
            break;
        }
    }
    
    if (parentVC && [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYisHiddenLeftSideBar"]) {
        for (UIView *subview in self.subviews) {
            if ([subview isKindOfClass:%c(DUXBaseImageView)]) {
                subview.hidden = YES;
            }
        }
    }
}

%end

%hook AWEFeedVideoButton

- (void)layoutSubviews {
	%orig;

	NSString *accessibilityLabel = self.accessibilityLabel;

	if ([accessibilityLabel isEqualToString:@"点赞"]) {
		if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideLikeButton"]) {
			[self removeFromSuperview];
			return;
		}

		// 隐藏点赞数值标签
		if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideLikeLabel"]) {
			for (UIView *subview in self.subviews) {
				if ([subview isKindOfClass:[UILabel class]]) {
					subview.hidden = YES;
				}
			}
		}
	} else if ([accessibilityLabel isEqualToString:@"评论"]) {
		if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideCommentButton"]) {
			[self removeFromSuperview];
			return;
		}

		// 隐藏评论数值标签
		if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideCommentLabel"]) {
			for (UIView *subview in self.subviews) {
				if ([subview isKindOfClass:[UILabel class]]) {
					subview.hidden = YES;
				}
			}
		}
	} else if ([accessibilityLabel isEqualToString:@"分享"]) {
		if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideShareButton"]) {
			[self removeFromSuperview];
			return;
		}

		// 隐藏分享数值标签
		if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideShareLabel"]) {
			for (UIView *subview in self.subviews) {
				if ([subview isKindOfClass:[UILabel class]]) {
					subview.hidden = YES;
				}
			}
		}
	} else if ([accessibilityLabel isEqualToString:@"收藏"]) {
		if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideCollectButton"]) {
			[self removeFromSuperview];
			return;
		}

		// 隐藏收藏数值标签
		if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideCollectLabel"]) {
			for (UIView *subview in self.subviews) {
				if ([subview isKindOfClass:[UILabel class]]) {
					subview.hidden = YES;
				}
			}
		}
	}
}

%end

%hook AWEMusicCoverButton

- (void)layoutSubviews {
	%orig;

	NSString *accessibilityLabel = self.accessibilityLabel;

	if ([accessibilityLabel isEqualToString:@"音乐详情"]) {
		if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideMusicButton"]) {
			[self removeFromSuperview];
			return;
		}
	}
}

%end

%hook AWEPlayInteractionListenFeedView
- (void)layoutSubviews {
	%orig;

	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideMusicButton"]) {
		[self removeFromSuperview];
		return;
	}
}
%end

%hook AWEPlayInteractionFollowPromptView

- (void)layoutSubviews {
	%orig;

	NSString *accessibilityLabel = self.accessibilityLabel;

	if ([accessibilityLabel isEqualToString:@"关注"]) {
		if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideAvatarButton"]) {
			[self removeFromSuperview];
			return;
		}
		if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideFollowPromptView"]) {
			self.userInteractionEnabled = NO;
			[self removeFromSuperview];
			return;
		}
	}
}

%end

// 隐藏状态栏
%hook AWEFeedRootViewController
- (BOOL)prefersStatusBarHidden {
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYisHideStatusbar"]) {
		return YES;
	} else {
		if (class_getInstanceMethod([self class], @selector(prefersStatusBarHidden)) !=
		    class_getInstanceMethod([%c(AWEFeedRootViewController) class], @selector(prefersStatusBarHidden))) {
			return %orig;
		}
		return NO;
	}
}
%end

// 直播状态栏
%hook IESLiveAudienceViewController
- (BOOL)prefersStatusBarHidden {
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYisHideStatusbar"]) {
		return YES;
	} else {
		if (class_getInstanceMethod([self class], @selector(prefersStatusBarHidden)) !=
		    class_getInstanceMethod([%c(IESLiveAudienceViewController) class], @selector(prefersStatusBarHidden))) {
			return %orig;
		}
		return NO;
	}
}
%end

// 主页状态栏
%hook AWEAwemeDetailTableViewController
- (BOOL)prefersStatusBarHidden {
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYisHideStatusbar"]) {
		return YES;
	} else {
		if (class_getInstanceMethod([self class], @selector(prefersStatusBarHidden)) !=
		    class_getInstanceMethod([%c(AWEAwemeDetailTableViewController) class], @selector(prefersStatusBarHidden))) {
			return %orig;
		}
		return NO;
	}
}
%end

// 图文状态栏
%hook AWEFullPageFeedNewContainerViewController
- (BOOL)prefersStatusBarHidden {
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYisHideStatusbar"]) {
		return YES;
	} else {
		if (class_getInstanceMethod([self class], @selector(prefersStatusBarHidden)) !=
		    class_getInstanceMethod([%c(AWEFullPageFeedNewContainerViewController) class], @selector(prefersStatusBarHidden))) {
			return %orig;
		}
		return NO;
	}
}
%end

%hook AWENormalModeTabBar

- (void)layoutSubviews {
	%orig;

	BOOL hideShop = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideShopButton"];
	BOOL hideMsg = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideMessageButton"];
	BOOL hideFri = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideFriendsButton"];
	BOOL hideMe = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideMyButton"];

	NSMutableArray *visibleButtons = [NSMutableArray array];
	Class generalButtonClass = %c(AWENormalModeTabBarGeneralButton);
	Class plusButtonClass = %c(AWENormalModeTabBarGeneralPlusButton);

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
			[subview removeFromSuperview];
		}
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

    // 处理 AWENormalModeTabBarGeneralButton 子控件的检查逻辑
    for (UIView *subview in self.subviews) {
        if ([subview isKindOfClass:generalButtonClass]) {
            AWENormalModeTabBarGeneralButton *button = (AWENormalModeTabBarGeneralButton *)subview;
            if ([button.accessibilityLabel isEqualToString:@"首页"] && [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYDisableHomeRefresh"] && button.status == 2) {
                if (button.gestureRecognizers && button.gestureRecognizers.count > 0) {
                    button.userInteractionEnabled = NO;
                }
            } else if ([button.accessibilityLabel isEqualToString:@"首页"] && [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYDisableHomeRefresh"] && button.status == 1) {
                if (button.gestureRecognizers && button.gestureRecognizers.count > 0) {
                    button.userInteractionEnabled = YES;
                }
            }
        }
    }

    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYisHiddenBottomBg"] || [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYisEnableFullScreen"]) {
        UIView *backgroundView = nil;
        BOOL hideFriendsButton = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideFriendsButton"];
        BOOL isHomeSelected = NO;
        BOOL isFriendsSelected = NO;
        
        // 查找背景视图
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

// 隐藏同城视频定位
%hook AWEMarkView

- (void)layoutSubviews {
    %orig;
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideLocation"]) {
        self.hidden = YES;
        return;
    }
}

%end


// 隐藏双指缩放虾线
%hook AWELoadingAndVolumeView

- (void)layoutSubviews {
	%orig;

	if ([self respondsToSelector:@selector(removeFromSuperview)]) {
		[self removeFromSuperview];
	}
	self.hidden = YES;
	return;
}

%end

// 隐藏昵称上方
%hook AWEFeedTemplateAnchorView

- (void)layoutSubviews {
	%orig;

	BOOL hideFeedAnchor = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideFeedAnchorContainer"];
	BOOL hideLocation = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideLocation"];

	if (!hideFeedAnchor && !hideLocation)
		return;

	AWECodeGenCommonAnchorBasicInfoModel *anchorInfo = [self valueForKey:@"templateAnchorInfo"];
	if (!anchorInfo || ![anchorInfo respondsToSelector:@selector(name)])
		return;

	NSString *name = [anchorInfo valueForKey:@"name"];
	BOOL isPoi = [name isEqualToString:@"poi_poi"];

	if ((hideFeedAnchor && !isPoi) || (hideLocation && isPoi)) {
		UIView *parentView = self.superview;
		if (parentView) {
			parentView.hidden = YES;
		}
	}
}

%end

%hook AWEPlayInteractionSearchAnchorView

- (void)layoutSubviews {
	%orig;

	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideInteractionSearch"]) {
		[self removeFromSuperview];
		return;
	}
}

%end

%hook AWEAwemeMusicInfoView

- (void)layoutSubviews {
	%orig;

	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideQuqishuiting"]) {
		UIView *parentView = self.superview;
		if (parentView) {
			parentView.hidden = YES;
		} else {
			self.hidden = YES;
		}
	}
}

%end

// 隐藏短剧合集
%hook AWETemplatePlayletView

- (void)layoutSubviews {

	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideTemplatePlaylet"]) {
		if ([self respondsToSelector:@selector(removeFromSuperview)]) {
			[self removeFromSuperview];
		}
		self.hidden = YES;
		return;
	}
	%orig;
}
%end

// 隐藏视频顶部搜索框、隐藏搜索框背景、应用全局透明
%hook AWESearchEntranceView

- (void)layoutSubviews {

	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideSearchEntrance"]) {
		self.hidden = YES;
		return;
	}

	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideSearchEntranceIndicator"]) {
		for (UIView *subviews in self.subviews) {
			if ([subviews isKindOfClass:%c(UIImageView)] && 
				[NSStringFromClass([((UIImageView *)subviews).image class]) isEqualToString:@"_UIResizableImage"]) {
				((UIImageView *)subviews).hidden = YES;
			}
		}
	}

	// NSString *transparentValue = [[NSUserDefaults standardUserDefaults] stringForKey:@"DYYYGlobalTransparency"];
	// if (transparentValue.length > 0) {
	//     CGFloat alphaValue = transparentValue.floatValue;
	//     if (alphaValue >= 0.0 && alphaValue <= 1.0) {
	//         self.alpha = alphaValue;
	//     }
	// }

	%orig;
}

%end

//暂停关键词
%hook AWEFeedPauseRelatedWordComponent

- (id)updateViewWithModel:(id)arg0 {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHidePauseVideoRelatedWord"]) {
        return nil;
    }
    return %orig;
}

- (id)pauseContentWithModel:(id)arg0 {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHidePauseVideoRelatedWord"]) {
        return nil;
    }
    return %orig;
}

- (id)recommendsWords {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHidePauseVideoRelatedWord"]) {
        return nil;
    }
    return %orig;
}

- (void)showRelatedRecommendPanelControllerWithSelectedText:(id)arg0 {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHidePauseVideoRelatedWord"]) {
        return;
    }
    %orig;
}

- (void)setupUI {
    %orig;
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHidePauseVideoRelatedWord"]) {
        if (self.relatedView) {
            self.relatedView.hidden = YES;
        }
    }
}

%end

// 隐藏视频滑条
%hook AWEStoryProgressSlideView

- (void)layoutSubviews {
	%orig;

	BOOL shouldHide = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideStoryProgressSlide"];
	if (!shouldHide)
		return;
	__block UIView *targetView = nil;
	[self.subviews enumerateObjectsUsingBlock:^(__kindof UIView *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
	  if ([obj isKindOfClass:NSClassFromString(@"UISlider")] || obj.frame.size.height < 5) {
		  targetView = obj.superview;
		  *stop = YES;
	  }
	}];

	if (targetView) {
		targetView.hidden = YES;
	} else {
	}
}

%end

// 隐藏好友分享私信
%hook AFDNewFastReplyView

- (void)layoutSubviews {
	%orig;

	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHidePrivateMessages"]) {
		UIView *parentView = self.superview;
		if (parentView) {
			parentView.hidden = YES;
		} else {
			self.hidden = YES;
		}
	}
}

%end

%hook AWETemplateHotspotView

- (void)layoutSubviews {
	%orig;

	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideHotspot"]) {
		[self removeFromSuperview];
		return;
	}
}

%end

// 隐藏关注直播
%hook AWEConcernSkylightCapsuleView
- (void)setHidden:(BOOL)hidden {
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideConcernCapsuleView"]) {
		[self removeFromSuperview];
		return;
	}

	%orig(hidden);
}
%end

// 隐藏直播发现
%hook AWEFeedLiveTabRevisitControlView

- (void)layoutSubviews {
	%orig;

	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideLiveDiscovery"]) {
		if ([self respondsToSelector:@selector(removeFromSuperview)]) {
			[self removeFromSuperview];
		}
		self.hidden = YES;
		return;
	}
}
%end

// 隐藏直播点歌
%hook IESLiveKTVSongIndicatorView
- (void)layoutSubviews {
	%orig;
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideKTVSongIndicator"]) {
		self.hidden = YES;
		[self removeFromSuperview];
	}
}
%end

// 隐藏图片滑条
%hook AWEStoryProgressContainerView
- (BOOL)isHidden {
	BOOL originalValue = %orig;
	BOOL customHide = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideDotsIndicator"];
	return originalValue || customHide;
}

- (void)setHidden:(BOOL)hidden {
	BOOL forceHide = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideDotsIndicator"];
	%orig(forceHide ? YES : hidden);
}
%end

// 隐藏昵称右侧
%hook UILabel
- (void)layoutSubviews {
	%orig;

	BOOL hideRightLabel = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideRightLable"];
	if (!hideRightLabel)
		return;

	NSString *accessibilityLabel = self.accessibilityLabel;
	if (!accessibilityLabel || accessibilityLabel.length == 0)
		return;

	NSString *trimmedLabel = [accessibilityLabel stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	BOOL shouldHide = NO;

	if ([trimmedLabel hasSuffix:@"人共创"]) {
		NSString *prefix = [trimmedLabel substringToIndex:trimmedLabel.length - 3];
		NSCharacterSet *nonDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
		shouldHide = ([prefix rangeOfCharacterFromSet:nonDigits].location == NSNotFound);
	}

	if (!shouldHide) {
		shouldHide = [trimmedLabel isEqualToString:@"章节要点"] || [trimmedLabel isEqualToString:@"图集"];
	}

	if (shouldHide) {
		self.hidden = YES;

		// 找到父视图是否为 UIStackView
		UIView *superview = self.superview;
		if ([superview isKindOfClass:[UIStackView class]]) {
			UIStackView *stackView = (UIStackView *)superview;
			// 刷新 UIStackView 的布局
			[stackView layoutIfNeeded];
		}
	}
}
%end

// 隐藏顶栏关注下的提示线
%hook AWEFeedMultiTabSelectedContainerView

- (void)setHidden:(BOOL)hidden {
	BOOL forceHide = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHidentopbarprompt"];

	if (forceHide) {
		%orig(YES);
	} else {
		%orig(hidden);
	}
}

%end

%hook AFDRecommendToFriendEntranceLabel
- (void)layoutSubviews {
	%orig;
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideRecommendTips"]) {
		if (self.accessibilityLabel) {
			[self removeFromSuperview];
		}
	}
}

%end

// 隐藏自己无公开作品的视图
%hook AWEProfileMixItemCollectionViewCell
- (void)layoutSubviews {
    %orig;
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHidePostView"]) {
        if ([self.accessibilityLabel isEqualToString:@"私密作品"]) {
            [self removeFromSuperview];
        }
    }
}
%end

%hook AWEProfileTaskCardStyleListCollectionViewCell
- (BOOL)shouldShowPublishGuide {
  if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHidePostView"]) {
    return NO;
  }
  return %orig;
}
%end

%hook AWEProfileRichEmptyView

- (void)setTitle:(id)title {
  if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHidePostView"]) {
    return;
  }
  %orig(title);
}

- (void)setDetail:(id)detail {
  if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHidePostView"]) {
    return;
  }
  %orig(detail);
}
%end

// 隐藏关注直播顶端
%hook AWENewLiveSkylightViewController

// 隐藏顶部直播视图 - 添加条件判断
- (void)showSkylight:(BOOL)arg0 animated:(BOOL)arg1 actionMethod:(unsigned long long)arg2 {
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHidenLiveView"]) {
		return;
	}
	%orig(arg0, arg1, arg2);
}

- (void)updateIsSkylightShowing:(BOOL)arg0 {
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHidenLiveView"]) {
		%orig(NO);
	} else {
		%orig(arg0);
	}
}

%end

// 隐藏同城顶端
%hook AWENearbyFullScreenViewModel

- (void)setShowSkyLight:(id)arg1 {
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideMenuView"]) {
		arg1 = nil;
	}
	%orig(arg1);
}

- (void)setHaveSkyLight:(id)arg1 {
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideMenuView"]) {
		arg1 = nil;
	}
	%orig(arg1);
}

%end

// 隐藏笔记
%hook AWECorrelationItemTag

- (void)layoutSubviews {
	%orig;
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideItemTag"]) {
		self.frame = CGRectMake(0, 0, 0, 0);
		self.hidden = YES;
	}
}

%end

// 隐藏话题
%hook AWEPlayInteractionTemplateButtonGroup
- (void)layoutSubviews {
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideTemplateGroup"]) {
		if ([self respondsToSelector:@selector(removeFromSuperview)]) {
			[self removeFromSuperview];
		}
		self.hidden = YES;
		return;
	}
	%orig;
}
%end

%hook AWEPlayInteractionViewController

- (void)onVideoPlayerViewDoubleClicked:(id)arg1 {
	BOOL isSwitchOn = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYDouble"];
	if (!isSwitchOn) {
		%orig;
	}
}
%end

// 隐藏右上搜索，但可点击
%hook AWEHPDiscoverFeedEntranceView

- (void)layoutSubviews {
    %orig;

    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideDiscover"]) {
        UIView *firstSubview = self.subviews.firstObject;
        if ([firstSubview isKindOfClass:[UIImageView class]]) {
            ((UIImageView *)firstSubview).image = nil;
        }
    }
}

%end

// 隐藏点击进入直播间
%hook AWELiveFeedStatusLabel
- (void)layoutSubviews {
	%orig;
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideEnterLive"]) {
		UIView *parentView = self.superview;
		UIView *grandparentView = parentView.superview;

		if (grandparentView) {
			grandparentView.hidden = YES;
		} else if (parentView) {
			parentView.hidden = YES;
		} else {
			self.hidden = YES;
		}
	}
}
%end

// 去除消息群直播提示
%hook AWEIMCellLiveStatusContainerView

- (void)p_initUI {
	if (![[NSUserDefaults standardUserDefaults] objectForKey:@"DYYYGroupLiving"])
		%orig;
}
%end

%hook AWELiveStatusIndicatorView

- (void)layoutSubviews {
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYGroupLiving"]) {
		if ([self respondsToSelector:@selector(removeFromSuperview)]) {
			[self removeFromSuperview];
		}
		self.hidden = YES;
		return;
	}
	%orig;
}
%end

%hook AWELiveSkylightCatchView
- (void)layoutSubviews {

	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHidenLiveCapsuleView"]) {
		if ([self respondsToSelector:@selector(removeFromSuperview)]) {
			[self removeFromSuperview];
		}
		self.hidden = YES;
		return;
	}
	%orig;
}

%end

// 隐藏首页直播胶囊
%hook AWEHPTopTabItemBadgeContentView

- (void)layoutSubviews {
	%orig;
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideLiveCapsuleView"]) {
		self.frame = CGRectMake(0, 0, 0, 0);
		self.hidden = YES;
	}
}

%end

// 隐藏群商店
%hook AWEIMFansGroupTopDynamicDomainTemplateView
- (void)layoutSubviews {
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideGroupShop"]) {
		if ([self respondsToSelector:@selector(removeFromSuperview)]) {
			[self removeFromSuperview];
		}
		self.hidden = YES;
		return;
	}
	%orig;
}
%end

// 去除群聊天输入框上方快捷方式
%hook AWEIMInputActionBarInteractor

- (void)p_setupUI {
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideGroupInputActionBar"]) {
		if ([self respondsToSelector:@selector(removeFromSuperview)]) {
			[self removeFromSuperview];
		}
		self.hidden = YES;
		return;
	}
	%orig;
}
%end

// 隐藏相机定位
%hook AWETemplateCommonView
- (void)layoutSubviews {
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideCameraLocation"]) {
		if ([self respondsToSelector:@selector(removeFromSuperview)]) {
			[self removeFromSuperview];
		}
		self.hidden = YES;
		return;
	}
	%orig;
}
%end

// 隐藏侧栏红点
%hook AWEHPTopBarCTAItemView

- (void)showRedDot {
	if (![[NSUserDefaults standardUserDefaults] objectForKey:@"DYYYisHiddenSidebarDot"])
		%orig;
}

- (void)hideCountRedDot {
	if (![[NSUserDefaults standardUserDefaults] objectForKey:@"DYYYisHiddenSidebarDot"])
		%orig;
}

- (void)layoutSubviews {
	%orig;
	for (UIView *subview in self.subviews) {
		if ([subview isKindOfClass:[%c(DUXBadge) class]]) {
			if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYisHiddenSidebarDot"]) {
				subview.hidden = YES;
			}
		}
	}
}
%end

%hook AWELeftSideBarEntranceView

- (void)setRedDot:(id)redDot {
	%orig(nil);
}

- (void)setNumericalRedDot:(id)numericalRedDot {
	%orig(nil);
}

%end

// 隐藏搜同款
%hook ACCStickerContainerView
- (void)layoutSubviews {
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideSearchSame"]) {
		if ([self respondsToSelector:@selector(removeFromSuperview)]) {
			[self removeFromSuperview];
		}
		self.hidden = YES; // 隐藏更彻底
		return;
	}
	%orig;
}
%end

// 隐藏上次看到
%hook DUXPopover
- (void)layoutSubviews {
	%orig;

	if (![[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHidePopover"]) {
		return;
	}

	id rawContent = nil;
	@try {
		rawContent = [self valueForKey:@"content"];
	} @catch (__unused NSException *e) {
		return;
	}

	NSString *text = [rawContent isKindOfClass:NSString.class] ? (NSString *)rawContent : [rawContent description];

	if ([text containsString:@"上次看到"]) {
		[self removeFromSuperview];
	}
}
%end

// 隐藏礼物展馆
%hook BDXWebView
- (void)layoutSubviews {
	%orig;

	BOOL enabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideGiftPavilion"];
	if (!enabled)
		return;

	NSString *title = [self valueForKey:@"title"];

	if ([title containsString:@"任务Banner"] || [title containsString:@"活动Banner"]) {
		[self removeFromSuperview];
	}
}
%end

%hook AWEVideoTypeTagView

- (void)setupUI {
	if (![[NSUserDefaults standardUserDefaults] objectForKey:@"DYYYHideLiveGIF"])
		%orig;
}
%end

// 隐藏双栏入口
%hook AWENormalModeTabBarFeedView
- (void)layoutSubviews {
    %orig;
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideDoubleColumnEntry"]) {
        for (UIView *subview in self.subviews) {
            if (![subview isKindOfClass:[UILabel class]]) {
                subview.hidden = YES;
            }
        }
    }
}
%end

// 隐藏直播广场
%hook IESLiveFeedDrawerEntranceView
- (void)layoutSubviews {
	%orig;

	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideLivePlayground"]) {
		self.hidden = YES;
	}
}

%end

// 隐藏顶栏红点
%hook AWEHPTopTabItemBadgeContentView
- (id)showBadgeWithBadgeStyle:(NSUInteger)style badgeConfig:(id)config count:(NSInteger)count text:(id)text {
	BOOL hideEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideTopBarBadge"];

	if (hideEnabled) {
		// 阻断徽章创建
		return nil; // 返回 nil 阻止视图生成
	} else {
		// 未启用隐藏功能时正常显示
		return %orig(style, config, count, text);
	}
}
%end

// 隐藏直播退出清屏、投屏按钮
%hook IESLiveButton

- (void)layoutSubviews {
	%orig;

	// 处理清屏按钮
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideLiveRoomClear"]) {
		if ([self.accessibilityLabel isEqualToString:@"退出清屏"] && self.superview) {
			[self.superview removeFromSuperview];
		}
	}

	// 投屏按钮
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideLiveRoomMirroring"]) {
		if ([self.accessibilityLabel isEqualToString:@"投屏"] && self.superview) {
			[self.superview removeFromSuperview];
		}
	}
        // 横屏按钮,可点击
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideLiveRoomFullscreen"]) {
		if ([self.accessibilityLabel isEqualToString:@"横屏"] && self.superview) {
			for (UIView *subview in self.subviews) {
			subview.hidden = YES;
			}
		}
	}
}

%end

// 隐藏直播间右上方关闭直播按钮
%hook IESLiveLayoutPlaceholderView
- (void)layoutSubviews {
	%orig;
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideLiveRoomClose"]) {
		self.hidden = YES;
	}
}
%end

// 隐藏直播间流量弹窗
%hook AWELiveFlowAlertView
- (void)layoutSubviews {
	%orig;
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideCellularAlert"]) {
		self.hidden = YES;
	}
}
%end

// 屏蔽青少年模式弹窗
%hook AWETeenModeAlertView
- (BOOL)show {
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideteenmode"]) {
		return NO;
	}
	return %orig;
}
%end

// 屏蔽青少年模式弹窗
%hook AWETeenModeSimpleAlertView
- (BOOL)show {
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideteenmode"]) {
		return NO;
	}
	return %orig;
}
%end


// 聊天视频底部评论框背景透明
%hook AWEIMFeedBottomQuickEmojiInputBar

- (void)layoutSubviews {
	%orig;

	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideChatCommentBg"]) {
		UIView *parentView = self.superview;
		while (parentView) {
			if ([NSStringFromClass([parentView class]) isEqualToString:@"UIView"]) {
				dispatch_async(dispatch_get_main_queue(), ^{
				  parentView.backgroundColor = [UIColor clearColor];
				  parentView.layer.backgroundColor = [UIColor clearColor].CGColor;
				  parentView.opaque = NO;
				});
				break;
			}
			parentView = parentView.superview;
		}
	}
}

%end

// 移除极速版我的片面红包横幅
%hook AWELuckyCatBannerView
- (id)initWithFrame:(CGRect)frame {
	return nil;
}

- (id)init {
	return nil;
}
%end


// 极速版红包激励挂件容器视图类组（移除逻辑）
%group IncentivePendantGroup
%hook AWEIncentiveSwiftImplDOUYINLite_IncentivePendantContainerView
- (void)layoutSubviews {
	%orig;
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHidePendantGroup"]) {
		[self removeFromSuperview]; // 移除视图
	}
}
%end
%end

// Swift 红包类初始化
%ctor {

	// 初始化红包激励挂件容器视图类组
	Class incentivePendantClass = objc_getClass("AWEIncentiveSwiftImplDOUYINLite.IncentivePendantContainerView");
	if (incentivePendantClass) {
		%init(IncentivePendantGroup, AWEIncentiveSwiftImplDOUYINLite_IncentivePendantContainerView = incentivePendantClass);
	}
}

//隐藏搜索/他人主页底部评论框
%hook AWECommentInputBackgroundView
- (void)layoutSubviews {
	%orig;

	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideComment"]) {
		[self removeFromSuperview];
		return;
	}
}
%end

//直播间文案调整
%hook IESLiveStackView
- (void)layoutSubviews {
    %orig;

    UIView *superView = self.superview;
    if (![superView isKindOfClass:%c(HTSEventForwardingView)] ||
        ![superView.accessibilityLabel isEqualToString:@"ContentContainerLayer"]) {
        return;
	}

    NSString *transparentValue = [[NSUserDefaults standardUserDefaults] stringForKey:@"DYYYGlobalTransparency"];
    if (transparentValue.length > 0) {
        CGFloat alphaValue = transparentValue.floatValue;
        if (alphaValue >= 0.0 && alphaValue <= 1.0) {
            self.alpha = alphaValue;
        }
    }

    NSString *vcScaleValue = [[NSUserDefaults standardUserDefaults] objectForKey:@"DYYYNicknameScale"];
    if (vcScaleValue.length > 0) {
        CGFloat scale = vcScaleValue.floatValue;
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
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYisEnableFullScreen"]) {
        CGRect frame = self.frame;
        self.frame = frame;
    }
}
%end

//精简侧边
@implementation UIView (Helper)
- (BOOL)containsClassNamed:(NSString *)className {
	if ([[[self class] description] isEqualToString:className]) {
		return YES;
	}
	for (UIView *subview in self.subviews) {
		if ([subview containsClassNamed:className]) {
			return YES;
		}
	}
	return NO;
}

- (UIView *)findViewWithClassName:(NSString *)className {
	if ([[[self class] description] isEqualToString:className]) {
		return self;
	}
	for (UIView *subview in self.subviews) {
		UIView *result = [subview findViewWithClassName:className];
		if (result) {
			return result;
		}
	}
	return nil;
}

- (NSArray<UIView *> *)findAllViewsWithClassName:(NSString *)className {
    NSMutableArray *foundViews = [NSMutableArray array];
    if ([[[self class] description] isEqualToString:className]) {
        [foundViews addObject:self];
    }
    for (UIView *subview in self.subviews) {
        [foundViews addObjectsFromArray:[subview findAllViewsWithClassName:className]];
    }
    return [foundViews copy];
}

@end

static NSMutableDictionary *keepCellsInfo;
static NSMutableDictionary *sectionKeepInfo;

static NSString *const kAWELeftSideBarTopRightLayoutView = @"AWELeftSideBarTopRightLayoutView";
static NSString *const kAWELeftSideBarFunctionContainerView = @"AWELeftSideBarFunctionContainerView";
static NSString *const kAWELeftSideBarWeatherView = @"AWELeftSideBarWeatherView";

static NSString *const kStreamlineSidebarKey = @"DYYYStreamlinethesidebar";

%hook AWELeftSideBarViewController

- (void)viewDidLoad {
	%orig;

	if (![[NSUserDefaults standardUserDefaults] boolForKey:kStreamlineSidebarKey]) {
		return;
	}

        if (!keepCellsInfo) {
                keepCellsInfo = [NSMutableDictionary dictionary];
        }
        if (!sectionKeepInfo) {
                sectionKeepInfo = [NSMutableDictionary dictionary];
        }
}

- (void)viewDidDisappear:(BOOL)animated {
	%orig;

	if (![[NSUserDefaults standardUserDefaults] boolForKey:kStreamlineSidebarKey]) {
		return;
	}

        [keepCellsInfo removeAllObjects];
        [sectionKeepInfo removeAllObjects];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	UICollectionViewCell *cell = %orig;

	if (![[NSUserDefaults standardUserDefaults] boolForKey:kStreamlineSidebarKey]) {
		return cell;
	}

	if (!cell)
		return cell;

	@try {
		BOOL shouldKeep = [cell.contentView containsClassNamed:kAWELeftSideBarTopRightLayoutView] || [cell.contentView containsClassNamed:kAWELeftSideBarFunctionContainerView] ||
				  [cell.contentView containsClassNamed:kAWELeftSideBarWeatherView];

                NSString *key = [NSString stringWithFormat:@"%ld-%ld", (long)indexPath.section, (long)indexPath.row];
                keepCellsInfo[key] = @(shouldKeep);
                if (shouldKeep) {
                        sectionKeepInfo[@(indexPath.section)] = @YES;
                } else if (!sectionKeepInfo[@(indexPath.section)]) {
                        sectionKeepInfo[@(indexPath.section)] = @NO;
                }

		if (!shouldKeep) {
			cell.hidden = YES;
			cell.alpha = 0;
			CGRect frame = cell.frame;
			frame.size.width = 0;
			frame.size.height = 0;
			cell.frame = frame;
		} else if ([cell.contentView containsClassNamed:kAWELeftSideBarFunctionContainerView]) {
			[self adjustContainerViewLayout:cell];
		}
	} @catch (NSException *exception) {
		NSLog(@"Error in cellForItemAtIndexPath: %@", exception);
	}

	return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(id)layout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
	CGSize originalSize = %orig;

	if (![[NSUserDefaults standardUserDefaults] boolForKey:kStreamlineSidebarKey]) {
		return originalSize;
	}

	NSString *key = [NSString stringWithFormat:@"%ld-%ld", (long)indexPath.section, (long)indexPath.row];
	NSNumber *shouldKeep = keepCellsInfo[key];

	if (shouldKeep != nil && ![shouldKeep boolValue]) {
		return CGSizeZero;
	}

	return originalSize;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(id)layout insetForSectionAtIndex:(NSInteger)section {
	UIEdgeInsets originalInsets = %orig;

	if (![[NSUserDefaults standardUserDefaults] boolForKey:kStreamlineSidebarKey]) {
		return originalInsets;
	}

        BOOL hasKeepCells = [sectionKeepInfo[@(section)] boolValue];

        if (!hasKeepCells) {
                return UIEdgeInsetsZero;
        }

	return originalInsets;
}

%new
- (void)adjustContainerViewLayout:(UICollectionViewCell *)containerCell {
	if (![[NSUserDefaults standardUserDefaults] boolForKey:kStreamlineSidebarKey]) {
		return;
	}

	UICollectionView *collectionView = [self collectionView];
	if (!collectionView || !containerCell)
		return;

	UIView *containerView = [containerCell.contentView findViewWithClassName:kAWELeftSideBarFunctionContainerView];
	if (!containerView)
		return;

	CGFloat windowHeight = collectionView.window.bounds.size.height;
	CGFloat currentY = [containerCell convertPoint:containerCell.bounds.origin toView:nil].y;
	CGFloat newHeight = windowHeight - currentY - 20;

	CGRect containerFrame = containerView.frame;
	containerFrame.size.height = newHeight;
	containerView.frame = containerFrame;

	CGRect cellFrame = containerCell.frame;
	cellFrame.size.height = newHeight;
	containerCell.frame = cellFrame;
}

%end

%hook AWESettingsTableViewController
- (void)viewDidLoad {
	%orig;

	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideSettingsAbout"]) {
		[self removeAboutSection];
	}
}

%new
- (void)removeAboutSection {
	// 获取 viewModel 属性
	id viewModel = [self viewModel];
	if (!viewModel) {
		return;
	}

	NSArray *sectionDataArray = [viewModel valueForKey:@"sectionDataArray"];
	if (!sectionDataArray || ![sectionDataArray isKindOfClass:[NSArray class]]) {
		return;
	}

	NSMutableArray *mutableSections = [sectionDataArray mutableCopy];

	// 遍历查找"关于"部分
	for (id sectionModel in [sectionDataArray copy]) {

		Class sectionModelClass = NSClassFromString(@"AWESettingSectionModel");
		if (!sectionModelClass || ![sectionModel isKindOfClass:sectionModelClass]) {
			continue;
		}

		// 获取 sectionHeaderTitle
		NSString *sectionHeaderTitle = [sectionModel valueForKey:@"sectionHeaderTitle"];
		if ([sectionHeaderTitle isEqualToString:@"关于"]) {

			[mutableSections removeObject:sectionModel];
			[viewModel setValue:mutableSections forKey:@"sectionDataArray"];
			break;
		}
	}
}
%end

%hook AWEFeedChannelManager

- (void)reloadChannelWithChannelModels:(id)arg1 currentChannelIDList:(id)arg2 reloadType:(id)arg3 selectedChannelID:(id)arg4 {
	NSArray *channelModels = arg1;
	NSMutableArray *newChannelModels = [NSMutableArray array];
	NSArray *currentChannelIDList = arg2;
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

	NSMutableArray *newCurrentChannelIDList = [NSMutableArray arrayWithArray:currentChannelIDList];

	NSString *hideOtherChannels = [defaults objectForKey:@"DYYYHideOtherChannel"] ?: @"";
	NSArray *hideChannelKeywords = [hideOtherChannels componentsSeparatedByString:@","];

	for (AWEHPTopTabItemModel *tabItemModel in channelModels) {
		NSString *channelID = tabItemModel.channelID;
		NSString *newChannelTitle = tabItemModel.title;
		NSString *oldChannelTitle = tabItemModel.channelTitle;

		if ([channelID isEqualToString:@"homepage_hot_container"]) {
			[newChannelModels addObject:tabItemModel];
			continue;
		}

		BOOL isHideChannel = NO;
		if ([channelID isEqualToString:@"homepage_follow"]) {
			isHideChannel = [defaults boolForKey:@"DYYYHideFollow"];
		} else if ([channelID isEqualToString:@"homepage_mediumvideo"]) {
			isHideChannel = [defaults boolForKey:@"DYYYHideMediumVideo"];
		} else if ([channelID isEqualToString:@"homepage_mall"]) {
			isHideChannel = [defaults boolForKey:@"DYYYHideMall"];
		} else if ([channelID isEqualToString:@"homepage_nearby"]) {
			isHideChannel = [defaults boolForKey:@"DYYYHideNearby"];
		} else if ([channelID isEqualToString:@"homepage_groupon"]) {
			isHideChannel = [defaults boolForKey:@"DYYYHideGroupon"];
		} else if ([channelID isEqualToString:@"homepage_tablive"]) {
			isHideChannel = [defaults boolForKey:@"DYYYHideTabLive"];
		} else if ([channelID isEqualToString:@"homepage_pad_hot"]) {
			isHideChannel = [defaults boolForKey:@"DYYYHidePadHot"];
		} else if ([channelID isEqualToString:@"homepage_hangout"]) {
			isHideChannel = [defaults boolForKey:@"DYYYHideHangout"];
		} else if ([channelID isEqualToString:@"homepage_familiar"]) {
			isHideChannel = [defaults boolForKey:@"DYYYHideFriend"];
		} else if ([channelID isEqualToString:@"homepage_playlet_stream"]) {
			isHideChannel = [defaults boolForKey:@"DYYYHidePlaylet"];
		} else if ([channelID isEqualToString:@"homepage_pad_cinema"]) {
			isHideChannel = [defaults boolForKey:@"DYYYHideCinema"];
		} else if ([channelID isEqualToString:@"homepage_pad_kids_v2"]) {
			isHideChannel = [defaults boolForKey:@"DYYYHideKidsV2"];
		} else if ([channelID isEqualToString:@"homepage_pad_game"]) {
			isHideChannel = [defaults boolForKey:@"DYYYHideGame"];
		}

		if (oldChannelTitle.length > 0 || newChannelTitle.length > 0) {
			for (NSString *keyword in hideChannelKeywords) {
				if (keyword.length > 0 && ([oldChannelTitle containsString:keyword] || [newChannelTitle containsString:keyword])) {
					isHideChannel = YES;
				}
			}
		}

		if (!isHideChannel) {
			[newChannelModels addObject:tabItemModel];
		} else {
			[newCurrentChannelIDList removeObject:channelID];
		}
	}

	%orig(newChannelModels, newCurrentChannelIDList, arg3, arg4);
}

%end

//横屏两侧增强
%hook AWELandscapeFeedViewController
- (void)viewDidLoad {
    %orig;

    // 尝试优先走属性
    gFeedCV = self.collectionView;

    // 保险起见再fallback,遍历 subviews
    if (!gFeedCV) {
        for (UIView *v in self.view.subviews) {
            if ([v isKindOfClass:[UICollectionView class]]) {
                gFeedCV = (UICollectionView *)v;
                break;
            }
        }
    }
}
%end

%hook UICollectionView

// 拦截手指拖动
- (void)handlePan:(UIPanGestureRecognizer *)pan {

	/* 仅处理横屏Feed列表。其余collectionView直接走系统逻辑 */
	if (self != gFeedCV || ![[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYVideoGesture"]) {
		%orig;
		return;
	}

	/* 取触点坐标、手势状态 */
	CGPoint loc = [pan locationInView:self];
	CGFloat w = self.bounds.size.width;
	CGFloat xPct = loc.x / w; // 0.0 ~ 1.0
	UIGestureRecognizerState st = pan.state;

	/* BEGAN：判定左右 20 % 区域 → 进入亮度 / 音量模式 */
	if (st == UIGestureRecognizerStateBegan) {

		gStartY = loc.y;

		if (xPct <= 0.20) { // 左边缘 → 亮度
			gMode = DYEdgeModeBrightness;
			gStartVal = [UIScreen mainScreen].brightness;

		} else if (xPct >= 0.80) { // 右边缘 → 音量
			gMode = DYEdgeModeVolume;
			gStartVal = [[objc_getClass("AVSystemController") sharedAVSystemController] volumeForCategory:@"Audio/Video"];

		} else {
			gMode = DYEdgeModeNone; // 中间区域走原逻辑
		}
	}

	/* 调节阶段：左右边缘时吞掉滚动、修改亮度/音量 */
	if (gMode != DYEdgeModeNone) {

		if (st == UIGestureRecognizerStateChanged) {

			CGFloat delta = (gStartY - loc.y) / self.bounds.size.height; // ↑ 为正
			const CGFloat kScale = 2.0;				     // 灵敏度
			float newVal = gStartVal + delta * kScale;
			newVal = fminf(fmaxf(newVal, 0.0), 1.0); // Clamp 0~1

			if (gMode == DYEdgeModeBrightness) {
				[UIScreen mainScreen].brightness = newVal;
				// 弹系统亮度 HUD
				[[%c(SBHUDController) sharedInstance] presentHUDWithIcon:@"Brightness" level:newVal];

			} else { // DYEdgeModeVolume
				// iOS 18 音量控制 + 系统音量 HUD
				[[objc_getClass("AVSystemController") sharedAVSystemController] setVolumeTo:newVal forCategory:@"Audio/Video"];
			}

			// 吞掉滚动：归零 translation，防止内容位移
			[pan setTranslation:CGPointZero inView:self];
		}

		/* 结束／取消：状态复位 */
		if (st == UIGestureRecognizerStateEnded || st == UIGestureRecognizerStateCancelled || st == UIGestureRecognizerStateFailed) {
			gMode = DYEdgeModeNone;
		}

		return; // 左右边缘：彻底阻断 %orig，避免翻页
	}

	/* 中间区域：直接执行原先翻页逻辑 */
	%orig;
}

%end

//禁用侧滑进入边栏
%hook AWELeftSideBarAddChildTransitionObject

- (void)handleShowSliderPanGesture:(id)gr {
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYDisableSidebarGesture"]) {
		// 禁用侧边栏手势
		return;
	}
	// 如果没有禁用侧边栏手势，则执行原有逻辑
	%orig(gr);
}

%end

%ctor {
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYUserAgreementAccepted"]) {
		%init;
	}
}

// 隐藏键盘ai
static __weak UIView *cachedHideView = nil;
static void hideParentViewsSubviews(UIView *view) {
        if (!view)
                return;
        UIView *parentView = [view superview];
        if (!parentView)
                return;
        UIView *grandParentView = [parentView superview];
        if (!grandParentView)
                return;
        UIView *greatGrandParentView = [grandParentView superview];
        if (!greatGrandParentView)
                return;
        cachedHideView = greatGrandParentView;
        for (UIView *subview in greatGrandParentView.subviews) {
                subview.hidden = YES;
        }
}
// 递归查找目标视图
static void findTargetViewInView(UIView *view) {
        if (cachedHideView)
                return;
        if ([view isKindOfClass:NSClassFromString(@"AWESearchKeyboardVoiceSearchEntranceView")]) {
                hideParentViewsSubviews(view);
                return;
        }
        for (UIView *subview in view.subviews) {
                findTargetViewInView(subview);
                if (cachedHideView)
                        break;
        }
}

%ctor {
	// 注册键盘通知
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYUserAgreementAccepted"]) {
                [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillShowNotification
                                                                  object:nil
                                                                   queue:[NSOperationQueue mainQueue]
                                                              usingBlock:^(NSNotification *notification) {
                        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHidekeyboardai"]) {
                                if (cachedHideView) {
                                        for (UIView *subview in cachedHideView.subviews) {
                                                subview.hidden = YES;
                                        }
                                } else {
                                        for (UIWindow *window in [UIApplication sharedApplication].windows) {
                                                findTargetViewInView(window);
                                                if (cachedHideView)
                                                        break;
                                        }
                                }
                        }
                }];
	}
}
