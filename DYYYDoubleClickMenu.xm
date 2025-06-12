#import "AwemeHeaders.h"
#import "DYYYManager.h"
#import "DYYYToast.h"

%hook AWEPlayInteractionViewController

- (void)onPlayer:(id)arg0 didDoubleClick:(id)arg1 {
	BOOL isPopupEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYEnableDoubleOpenAlertController"];
	BOOL isDirectCommentEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYEnableDoubleOpenComment"];

	// 直接打开评论区的情况
	if (isDirectCommentEnabled) {
		[self performCommentAction];
		return;
	}

	if (isPopupEnabled) {
		AWEAwemeModel *awemeModel = nil;

		awemeModel = [self performSelector:@selector(awemeModel)];

		AWEVideoModel *videoModel = awemeModel.video;
		AWEMusicModel *musicModel = awemeModel.music;

		// 确定内容类型（视频或图片）
		BOOL isImageContent = (awemeModel.awemeType == 68);
		// 判断是否为新版实况照片
		BOOL isNewLivePhoto = (awemeModel.video && awemeModel.animatedImageVideoInfo != nil);
		NSString *downloadTitle;

		if (isImageContent) {
			AWEImageAlbumImageModel *currentImageModel = nil;
			if (awemeModel.currentImageIndex > 0 && awemeModel.currentImageIndex <= awemeModel.albumImages.count) {
				currentImageModel = awemeModel.albumImages[awemeModel.currentImageIndex - 1];
			} else {
				currentImageModel = awemeModel.albumImages.firstObject;
			}

			if (awemeModel.albumImages.count > 1) {
				downloadTitle = (currentImageModel.clipVideo != nil) ? @"保存当前实况" : @"保存当前图片";
			} else {
				downloadTitle = (currentImageModel.clipVideo != nil) ? @"保存实况" : @"保存图片";
			}
		} else if (isNewLivePhoto) {
			downloadTitle = @"保存实况";
		} else {
			downloadTitle = @"保存视频";
		}

		AWEUserActionSheetView *actionSheet = [[NSClassFromString(@"AWEUserActionSheetView") alloc] init];
		NSMutableArray *actions = [NSMutableArray array];

		// 添加下载选项
		if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYDoubleTapDownload"] || ![[NSUserDefaults standardUserDefaults] objectForKey:@"DYYYDoubleTapDownload"]) {

			AWEUserSheetAction *downloadAction = [NSClassFromString(@"AWEUserSheetAction")
			    actionWithTitle:downloadTitle
				    imgName:nil
				    handler:^{
				      if (isImageContent) {
					      // 图片内容
					      AWEImageAlbumImageModel *currentImageModel = nil;
					      if (awemeModel.currentImageIndex > 0 && awemeModel.currentImageIndex <= awemeModel.albumImages.count) {
						      currentImageModel = awemeModel.albumImages[awemeModel.currentImageIndex - 1];
					      } else {
						      currentImageModel = awemeModel.albumImages.firstObject;
					      }

					      // 查找非.image后缀的URL
					      NSURL *downloadURL = nil;
					      for (NSString *urlString in currentImageModel.urlList) {
						      NSURL *url = [NSURL URLWithString:urlString];
						      NSString *pathExtension = [url.path.lowercaseString pathExtension];
						      if (![pathExtension isEqualToString:@"image"]) {
							      downloadURL = url;
							      break;
						      }
					      }

					      if (currentImageModel.clipVideo != nil) {
						      NSURL *videoURL = [currentImageModel.clipVideo.playURL getDYYYSrcURLDownload];
						      [DYYYManager downloadLivePhoto:downloadURL
									    videoURL:videoURL
									  completion:^{
									  }];
					      } else if (currentImageModel && currentImageModel.urlList.count > 0) {
						      if (downloadURL) {
							      [DYYYManager downloadMedia:downloadURL
									       mediaType:MediaTypeImage
									      completion:^(BOOL success) {
										if (success) {
										} else {
											[DYYYManager showToast:@"图片保存已取消"];
										}
									      }];
						      } else {
							      [DYYYManager showToast:@"没有找到合适格式的图片"];
						      }
					      }
				      } else if (isNewLivePhoto) {
					      // 新版实况照片
					      // 使用封面URL作为图片URL
					      NSURL *imageURL = nil;
					      if (videoModel.coverURL && videoModel.coverURL.originURLList.count > 0) {
						      imageURL = [NSURL URLWithString:videoModel.coverURL.originURLList.firstObject];
					      }

					      // 视频URL从视频模型获取
					      NSURL *videoURL = nil;
					      if (videoModel && videoModel.playURL && videoModel.playURL.originURLList.count > 0) {
						      videoURL = [NSURL URLWithString:videoModel.playURL.originURLList.firstObject];
					      } else if (videoModel && videoModel.h264URL && videoModel.h264URL.originURLList.count > 0) {
						      videoURL = [NSURL URLWithString:videoModel.h264URL.originURLList.firstObject];
					      }

					      // 下载实况照片
					      if (imageURL && videoURL) {
						      [DYYYManager downloadLivePhoto:imageURL
									    videoURL:videoURL
									  completion:^{
									  }];
					      }
				      } else {
					      // 视频内容
					      if (videoModel && videoModel.bitrateModels && videoModel.bitrateModels.count > 0) {
						      // 优先使用bitrateModels中的最高质量版本
						      id highestQualityModel = videoModel.bitrateModels.firstObject;
						      NSArray *urlList = nil;
						      id playAddrObj = [highestQualityModel valueForKey:@"playAddr"];

						      if ([playAddrObj isKindOfClass:%c(AWEURLModel)]) {
							      AWEURLModel *playAddrModel = (AWEURLModel *)playAddrObj;
							      urlList = playAddrModel.originURLList;
						      }

						      if (urlList && urlList.count > 0) {
							      NSURL *url = [NSURL URLWithString:urlList.firstObject];
							      [DYYYManager downloadMedia:url
									       mediaType:MediaTypeVideo
									      completion:^(BOOL success){
									      }];
						      } else {
							      // 备用方法：直接使用h264URL
							      if (videoModel.h264URL && videoModel.h264URL.originURLList.count > 0) {
								      NSURL *url = [NSURL URLWithString:videoModel.h264URL.originURLList.firstObject];
								      [DYYYManager downloadMedia:url
										       mediaType:MediaTypeVideo
										      completion:^(BOOL success){
										      }];
							      }
						      }
					      }
				      }
				    }];
			[actions addObject:downloadAction];

			// 添加保存封面选项
                        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYDoubleSaveCover"]) {
			if (!isImageContent) { // 仅视频内容显示保存封面选项
				AWEUserSheetAction *saveCoverAction = [NSClassFromString(@"AWEUserSheetAction")
				    actionWithTitle:@"保存封面"
					    imgName:nil
					    handler:^{
					      AWEVideoModel *videoModel = awemeModel.video;
					      if (videoModel && videoModel.coverURL && videoModel.coverURL.originURLList.count > 0) {
						      NSURL *coverURL = [NSURL URLWithString:videoModel.coverURL.originURLList.firstObject];
						      [DYYYManager downloadMedia:coverURL
								       mediaType:MediaTypeImage
								      completion:^(BOOL success) {
									if (success) {
									} else {
										[DYYYManager showToast:@"封面保存已取消"];
									}
								      }];
					      }
					    }];
				[actions addObject:saveCoverAction];
			}
                     }

	                // 如果是图集，添加下载所有图片选项
			if (isImageContent && awemeModel.albumImages.count > 1) {
				// 检查是否有实况照片
				BOOL hasLivePhoto = NO;
				for (AWEImageAlbumImageModel *imageModel in awemeModel.albumImages) {
					if (imageModel.clipVideo != nil) {
						hasLivePhoto = YES;
						break;
					}
				}

				NSString *actionTitle = hasLivePhoto ? @"保存所有实况" : @"保存所有图片";

				AWEUserSheetAction *downloadAllAction = [NSClassFromString(@"AWEUserSheetAction")
				    actionWithTitle:actionTitle
					    imgName:nil
					    handler:^{
					      NSMutableArray *imageURLs = [NSMutableArray array];
					      NSMutableArray *livePhotos = [NSMutableArray array];

					      for (AWEImageAlbumImageModel *imageModel in awemeModel.albumImages) {
						      if (imageModel.urlList.count > 0) {
							      // 查找非.image后缀的URL
							      NSURL *downloadURL = nil;
							      for (NSString *urlString in imageModel.urlList) {
								      NSURL *url = [NSURL URLWithString:urlString];
								      NSString *pathExtension = [url.path.lowercaseString pathExtension];
								      if (![pathExtension isEqualToString:@"image"]) {
									      downloadURL = url;
									      break;
								      }
							      }

							      if (!downloadURL && imageModel.urlList.count > 0) {
								      downloadURL = [NSURL URLWithString:imageModel.urlList.firstObject];
							      }

							      // 检查是否是实况照片
							      if (imageModel.clipVideo != nil) {
								      NSURL *videoURL = [imageModel.clipVideo.playURL getDYYYSrcURLDownload];
								      [livePhotos addObject:@{@"imageURL" : downloadURL.absoluteString, @"videoURL" : videoURL.absoluteString}];
							      } else {
								      [imageURLs addObject:downloadURL.absoluteString];
							      }
						      }
					      }

					      // 分别处理普通图片和实况照片
					      if (livePhotos.count > 0) {
						      [DYYYManager downloadAllLivePhotos:livePhotos];
					      }

					      if (imageURLs.count > 0) {
						      [DYYYManager downloadAllImages:imageURLs];
					      }

					      if (livePhotos.count == 0 && imageURLs.count == 0) {
						      [DYYYManager showToast:@"没有找到合适格式的图片"];
					      }
					    }];
				[actions addObject:downloadAllAction];
			}
		}
		// 添加下载音频选项
		if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYDoubleTapDownloadAudio"] || ![[NSUserDefaults standardUserDefaults] objectForKey:@"DYYYDoubleTapDownloadAudio"]) {

			AWEUserSheetAction *downloadAudioAction = [NSClassFromString(@"AWEUserSheetAction")
			    actionWithTitle:@"保存音频"
				    imgName:nil
				    handler:^{
				      if (musicModel && musicModel.playURL && musicModel.playURL.originURLList.count > 0) {
					      NSURL *url = [NSURL URLWithString:musicModel.playURL.originURLList.firstObject];
					      [DYYYManager downloadMedia:url mediaType:MediaTypeAudio completion:nil];
				      }
				    }];
			[actions addObject:downloadAudioAction];
		}

               // 添加制作视频功能	
		if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYDoubleCreateVideo"] || ![[NSUserDefaults standardUserDefaults] objectForKey:@"DYYYDoubleCreateVideo"]) {
			if (isImageContent) {
				AWEUserSheetAction *createVideoAction = [NSClassFromString(@"AWEUserSheetAction")
				    actionWithTitle:@"合成视频"
					    imgName:nil
					    handler:^{
					      // 收集普通图片URL
					      NSMutableArray *imageURLs = [NSMutableArray array];
					      // 收集实况照片信息（图片URL+视频URL）
					      NSMutableArray *livePhotos = [NSMutableArray array];

					      // 获取背景音乐URL
					      NSString *bgmURL = nil;
					      if (musicModel && musicModel.playURL && musicModel.playURL.originURLList.count > 0) {
						      bgmURL = musicModel.playURL.originURLList.firstObject;
					      }

					      // 处理所有图片和实况
					      for (AWEImageAlbumImageModel *imageModel in awemeModel.albumImages) {
						      if (imageModel.urlList.count > 0) {
							      // 查找非.image后缀的URL
							      NSString *bestURL = nil;
							      for (NSString *urlString in imageModel.urlList) {
								      NSURL *url = [NSURL URLWithString:urlString];
								      NSString *pathExtension = [url.path.lowercaseString pathExtension];
								      if (![pathExtension isEqualToString:@"image"]) {
									      bestURL = urlString;
									      break;
								      }
							      }

							      if (!bestURL && imageModel.urlList.count > 0) {
								      bestURL = imageModel.urlList.firstObject;
							      }

							      // 如果是实况照片，需要收集图片和视频URL
							      if (imageModel.clipVideo != nil) {
								      NSURL *videoURL = [imageModel.clipVideo.playURL getDYYYSrcURLDownload];
								      if (videoURL) {
									      [livePhotos addObject:@{@"imageURL" : bestURL, @"videoURL" : videoURL.absoluteString}];
								      }
							      } else {
								      // 普通图片
								      [imageURLs addObject:bestURL];
							      }
						      }
					      }

					      // 调用视频创建API
					      [DYYYManager createVideoFromMedia:imageURLs
						  livePhotos:livePhotos
						  bgmURL:bgmURL
						  progress:^(NSInteger current, NSInteger total, NSString *status) {
						  }
						  completion:^(BOOL success, NSString *message) {
						    if (success) {
						    } else {
							    [DYYYManager showToast:[NSString stringWithFormat:@"视频制作失败: %@", message]];
						    }
						  }];
					    }];
				[actions addObject:createVideoAction];
			}
		}


		// 添加接口保存选项
		if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYDoubleInterfaceDownload"]) {
			NSString *apiKey = [[NSUserDefaults standardUserDefaults] objectForKey:@"DYYYInterfaceDownload"];
			if (apiKey.length > 0) {
				AWEUserSheetAction *apiDownloadAction = [NSClassFromString(@"AWEUserSheetAction") actionWithTitle:@"接口解析"
															  imgName:nil
															  handler:^{
															    NSString *shareLink = [awemeModel valueForKey:@"shareURL"];
															    if (shareLink.length == 0) {
																    [DYYYManager showToast:@"无法获取分享链接"];
																    return;
															    }

															    // 使用封装的方法进行解析下载
															    [DYYYManager parseAndDownloadVideoWithShareLink:shareLink apiKey:apiKey];
															  }];
				[actions addObject:apiDownloadAction];
			}
		}

		// 添加复制文案选项
		if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYDoubleTapCopyDesc"] || ![[NSUserDefaults standardUserDefaults] objectForKey:@"DYYYDoubleTapCopyDesc"]) {

			AWEUserSheetAction *copyTextAction = [NSClassFromString(@"AWEUserSheetAction") actionWithTitle:@"复制文案"
													       imgName:nil
													       handler:^{
														 NSString *descText = [awemeModel valueForKey:@"descriptionString"];
														 [[UIPasteboard generalPasteboard] setString:descText];
														[DYYYToast showSuccessToastWithMessage:@"文案已复制"];

													       }];
			[actions addObject:copyTextAction];
		}

		// 添加打开评论区选项
		if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYDoubleTapComment"] || ![[NSUserDefaults standardUserDefaults] objectForKey:@"DYYYDoubleTapComment"]) {

			AWEUserSheetAction *openCommentAction = [NSClassFromString(@"AWEUserSheetAction") actionWithTitle:@"打开评论"
														  imgName:nil
														  handler:^{
														    [self performCommentAction];
														  }];
			[actions addObject:openCommentAction];
		}

		// 添加分享选项
		if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYDoubleTapshowSharePanel"] || ![[NSUserDefaults standardUserDefaults] objectForKey:@"DYYYDoubleTapshowSharePanel"]) {

			AWEUserSheetAction *showSharePanel = [NSClassFromString(@"AWEUserSheetAction") actionWithTitle:@"分享视频"
													       imgName:nil
													       handler:^{
														 [self showSharePanel]; // 执行分享操作
													       }];
			[actions addObject:showSharePanel];
		}

		// 添加点赞视频选项
		if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYDoubleTapLike"] || ![[NSUserDefaults standardUserDefaults] objectForKey:@"DYYYDoubleTapLike"]) {

			AWEUserSheetAction *likeAction = [NSClassFromString(@"AWEUserSheetAction") actionWithTitle:@"点赞视频"
													   imgName:nil
													   handler:^{
													     [self performLikeAction]; // 执行点赞操作
													   }];
			[actions addObject:likeAction];
		}

		// 添加长按面板
		if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYDoubleTapshowDislikeOnVideo"] || ![[NSUserDefaults standardUserDefaults] objectForKey:@"DYYYDoubleTapshowDislikeOnVideo"]) {

			AWEUserSheetAction *showDislikeOnVideo = [NSClassFromString(@"AWEUserSheetAction") actionWithTitle:@"长按面板"
														   imgName:nil
														   handler:^{
														     [self showDislikeOnVideo]; // 执行长按面板操作
														   }];
			[actions addObject:showDislikeOnVideo];
		}

		// 显示操作表
		[actionSheet setActions:actions];
		[actionSheet show];

		return;
	}

	// 默认行为
	%orig;
}

%end

%ctor {
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYUserAgreementAccepted"]) {
		%init;
	}
}
