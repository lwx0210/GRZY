/***
* 202506131200
* pxx917144686
**/

#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "AwemeHeaders.h"
#import "DYYYManager.h"

@interface IESLiveWalletMyCoinViewController : UIViewController
@end

@interface AWEPayTransferAccountsReceiveViewController : UIViewController
@end

@interface AWEPayTransferAccountsSendViewController : UIViewController
@end

@interface CJPayWithDrawResultViewController : UIViewController
@end

@interface CJPayRechargeBalanceViewController : UIViewController
@end

@interface CJPayBalanceModel : NSObject
@property (nonatomic, strong) NSNumber *balance;
@end

@interface IESLiveWalletMyCoinModel : NSObject
@property (nonatomic, strong) NSNumber *coinCount;
@end

@interface AWEPayTransferMoneyView : UIView
- (void)updateWithViewModel:(id)viewModel;
@end

// 钱包数据定义
#define DYYY_WALLET_ENABLED_KEY @"DYYYEnableWalletCustom"
#define DYYY_WALLET_BALANCE_KEY @"DYYYCustomWalletBalance"
#define DYYY_WALLET_COIN_KEY @"DYYYCustomWalletCoin"
#define DYYY_DOUYIN_CASH_KEY @"DYYYCustomDouyinCash"

// 静态缓存
static BOOL walletStatsEnabled = NO;
static NSString *customWalletBalance = nil;
static NSString *customWalletCoin = nil;
static NSString *customDouyinCash = nil;

// 缓存的NSNumber值
static NSNumber *cachedWalletBalanceNumber = nil;
static NSNumber *cachedWalletCoinNumber = nil;
static NSNumber *cachedDouyinCashNumber = nil;

// 函数声明
static void loadCustomWalletStats(void);
static void updateWalletModelData(id model);
static void showWalletEditAlert(UIViewController *viewController);
static void findAndRefreshWalletViews(UIView *rootView);

// 加载钱包设置数据
static void loadCustomWalletStats() {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    walletStatsEnabled = [defaults boolForKey:DYYY_WALLET_ENABLED_KEY];
    
    if (walletStatsEnabled) {
        customWalletBalance = [defaults objectForKey:DYYY_WALLET_BALANCE_KEY];
        customWalletCoin = [defaults objectForKey:DYYY_WALLET_COIN_KEY];
        customDouyinCash = [defaults objectForKey:DYYY_DOUYIN_CASH_KEY];
        
        cachedWalletBalanceNumber = customWalletBalance ? @([customWalletBalance doubleValue]) : nil;
        cachedWalletCoinNumber = customWalletCoin ? @([customWalletCoin integerValue]) : nil;
        cachedDouyinCashNumber = customDouyinCash ? @([customDouyinCash doubleValue]) : nil;
    }
}

// 递归枚举视图
static void enumerateViewsRecursively(UIView *view, void(^block)(UIView *view)) {
    if (!view) return;
    
    // 对当前视图执行操作
    block(view);
    
    // 递归处理所有子视图
    for (UIView *subview in view.subviews) {
        enumerateViewsRecursively(subview, block);
    }
}

// 更新钱包模型数据
static void updateWalletModelData(id model) {
    if (!walletStatsEnabled || !model) return;
    
    // 余额
    if (cachedWalletBalanceNumber) {
        NSArray *balanceKeys = @[@"balance", @"walletBalance", @"accountBalance", @"totalBalance"];
        for (NSString *key in balanceKeys) {
            if ([model respondsToSelector:NSSelectorFromString(key)]) {
                [model setValue:cachedWalletBalanceNumber forKey:key];
            }
        }
    }
    
    // 硬币
    if (cachedWalletCoinNumber) {
        NSArray *coinKeys = @[@"coin", @"coinCount", @"coins", @"totalCoin"];
        for (NSString *key in coinKeys) {
            if ([model respondsToSelector:NSSelectorFromString(key)]) {
                [model setValue:cachedWalletCoinNumber forKey:key];
            }
        }
    }
    
    // 抖音现金
    if (cachedDouyinCashNumber) {
        NSArray *cashKeys = @[@"cash", @"cashAmount", @"douyinCash", @"totalCash"];
        for (NSString *key in cashKeys) {
            if ([model respondsToSelector:NSSelectorFromString(key)]) {
                [model setValue:cachedDouyinCashNumber forKey:key];
            }
        }
    }
}

// 编辑钱包数据UI界面
@interface DYYYWalletEditViewController : UIViewController <UITextFieldDelegate, UIGestureRecognizerDelegate>
@property (nonatomic, strong) NSMutableDictionary *currentValues;
@end

@implementation DYYYWalletEditViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        _currentValues = [NSMutableDictionary dictionary];
        self.modalPresentationStyle = UIModalPresentationOverFullScreen;
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置半透明背景
    self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
    
    // 创建卡片容器
    UIView *cardView = [[UIView alloc] init];
    cardView.backgroundColor = [UIColor systemBackgroundColor];
    cardView.layer.cornerRadius = 20;
    cardView.clipsToBounds = YES;
    cardView.translatesAutoresizingMaskIntoConstraints = NO;
    cardView.alpha = 0; // 初始透明，用于动画
    cardView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.8, 0.8); // 初始缩小，用于动画
    cardView.tag = 100;
    [self.view addSubview:cardView];
    
    // 卡片尺寸和位置约束
    [NSLayoutConstraint activateConstraints:@[
        [cardView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [cardView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
        [cardView.widthAnchor constraintEqualToAnchor:self.view.widthAnchor multiplier:0.85],
        [cardView.heightAnchor constraintEqualToConstant:380]
    ]];
    
    // 添加标题
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"自定义钱包数据";
    titleLabel.font = [UIFont systemFontOfSize:20 weight:UIFontWeightBold];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [cardView addSubview:titleLabel];
    
    // 添加分割线
    UIView *divider = [[UIView alloc] init];
    divider.backgroundColor = [UIColor systemGray3Color];
    divider.translatesAutoresizingMaskIntoConstraints = NO;
    [cardView addSubview:divider];
    
    // 创建表单容器
    UIStackView *formContainer = [[UIStackView alloc] init];
    formContainer.axis = UILayoutConstraintAxisVertical;
    formContainer.spacing = 22;
    formContainer.distribution = UIStackViewDistributionFill;
    formContainer.alignment = UIStackViewAlignmentFill;
    formContainer.translatesAutoresizingMaskIntoConstraints = NO;
    [cardView addSubview:formContainer];
    
    // 添加各项输入控件
    NSArray *itemTitles = @[@"钱包余额", @"抖币数量", @"抖音现金"];
    NSArray *itemIcons = @[@"creditcard.fill", @"dollarsign.circle.fill", @"banknote.fill"];
    NSArray *itemColors = @[
        [UIColor systemGreenColor],
        [UIColor systemYellowColor], 
        [UIColor systemRedColor]
    ];
    NSArray *itemKeys = @[
        DYYY_WALLET_BALANCE_KEY,
        DYYY_WALLET_COIN_KEY,
        DYYY_DOUYIN_CASH_KEY
    ];
    NSArray *placeholders = @[@"输入余额", @"输入抖币", @"输入现金"];
    
    for (int i = 0; i < itemTitles.count; i++) {
        [self addInputRow:formContainer 
                    title:itemTitles[i] 
                     icon:itemIcons[i] 
                    color:itemColors[i] 
                      tag:200 + i 
                      key:itemKeys[i]
              placeholder:placeholders[i]];
    }
    
    // 添加按钮容器
    UIStackView *buttonContainer = [[UIStackView alloc] init];
    buttonContainer.axis = UILayoutConstraintAxisHorizontal;
    buttonContainer.spacing = 12;
    buttonContainer.distribution = UIStackViewDistributionFillEqually;
    buttonContainer.translatesAutoresizingMaskIntoConstraints = NO;
    [cardView addSubview:buttonContainer];
    
    // 创建取消按钮
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    cancelButton.backgroundColor = [UIColor systemGray5Color];
    cancelButton.layer.cornerRadius = 12;
    [cancelButton setTitleColor:[UIColor labelColor] forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    [buttonContainer addArrangedSubview:cancelButton];
    
    // 创建确认按钮
    UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [saveButton setTitle:@"保存" forState:UIControlStateNormal];
    saveButton.backgroundColor = [UIColor systemBlueColor];
    saveButton.layer.cornerRadius = 12;
    [saveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [saveButton addTarget:self action:@selector(saveAction) forControlEvents:UIControlEventTouchUpInside];
    [buttonContainer addArrangedSubview:saveButton];
    
    // 为所有按钮设置高度
    for (UIButton *button in buttonContainer.arrangedSubviews) {
        button.translatesAutoresizingMaskIntoConstraints = NO;
        [button.heightAnchor constraintEqualToConstant:50].active = YES;
    }
    
    // 布局约束
    [NSLayoutConstraint activateConstraints:@[
        // 标题约束
        [titleLabel.topAnchor constraintEqualToAnchor:cardView.topAnchor constant:20],
        [titleLabel.leadingAnchor constraintEqualToAnchor:cardView.leadingAnchor constant:20],
        [titleLabel.trailingAnchor constraintEqualToAnchor:cardView.trailingAnchor constant:-20],
        
        // 分割线约束
        [divider.topAnchor constraintEqualToAnchor:titleLabel.bottomAnchor constant:15],
        [divider.leadingAnchor constraintEqualToAnchor:cardView.leadingAnchor constant:0],
        [divider.trailingAnchor constraintEqualToAnchor:cardView.trailingAnchor constant:0],
        [divider.heightAnchor constraintEqualToConstant:0.5],
        
        // 表单约束
        [formContainer.topAnchor constraintEqualToAnchor:divider.bottomAnchor constant:20],
        [formContainer.leadingAnchor constraintEqualToAnchor:cardView.leadingAnchor constant:20],
        [formContainer.trailingAnchor constraintEqualToAnchor:cardView.trailingAnchor constant:-20],
        
        // 按钮容器约束
        [buttonContainer.topAnchor constraintEqualToAnchor:formContainer.bottomAnchor constant:25],
        [buttonContainer.leadingAnchor constraintEqualToAnchor:cardView.leadingAnchor constant:20],
        [buttonContainer.trailingAnchor constraintEqualToAnchor:cardView.trailingAnchor constant:-20],
        [buttonContainer.bottomAnchor constraintEqualToAnchor:cardView.bottomAnchor constant:-20],
    ]];
    
    // 加载现有数据
    [self loadExistingData];
    
    // 添加轻点背景关闭弹窗的手势
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] 
                                          initWithTarget:self 
                                          action:@selector(handleBackgroundTap:)];
    tapGesture.delegate = self;
    [self.view addGestureRecognizer:tapGesture];
    
    // 注册键盘通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)addInputRow:(UIStackView *)container title:(NSString *)title icon:(NSString *)iconName color:(UIColor *)color tag:(NSInteger)tag key:(NSString *)key placeholder:(NSString *)placeholder {
    // 创建容器
    UIView *rowView = [[UIView alloc] init];
    rowView.translatesAutoresizingMaskIntoConstraints = NO;
    [rowView.heightAnchor constraintEqualToConstant:70].active = YES;
    [container addArrangedSubview:rowView];
    
    // 创建图标 (在左侧)
    UIImageView *iconView = [[UIImageView alloc] init];
    if (@available(iOS 13.0, *)) {
        iconView.image = [UIImage systemImageNamed:iconName];
    } else {
        // 兼容iOS 13以下版本的替代图标
        iconView.image = [UIImage imageNamed:iconName];
    }
    iconView.tintColor = color;
    iconView.contentMode = UIViewContentModeScaleAspectFit;
    iconView.translatesAutoresizingMaskIntoConstraints = NO;
    [rowView addSubview:iconView];
    
    // 创建标题标签
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = title;
    titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [rowView addSubview:titleLabel];
    
    // 创建数值预览标签
    UILabel *valueLabel = [[UILabel alloc] init];
    valueLabel.font = [UIFont monospacedDigitSystemFontOfSize:16 weight:UIFontWeightMedium];
    valueLabel.textAlignment = NSTextAlignmentRight;
    valueLabel.translatesAutoresizingMaskIntoConstraints = NO;
    valueLabel.tag = tag + 100; // 预览标签tag = 输入框tag + 100
    valueLabel.textColor = color;
    [rowView addSubview:valueLabel];
    
    // 创建输入框
    UITextField *textField = [[UITextField alloc] init];
    textField.placeholder = placeholder;
    
    // 设置输入框键盘类型 - 抖币使用数字，其他使用小数键盘
    if ([key isEqualToString:DYYY_WALLET_COIN_KEY]) {
        textField.keyboardType = UIKeyboardTypeNumberPad;
    } else {
        textField.keyboardType = UIKeyboardTypeDecimalPad;
    }
    
    textField.textAlignment = NSTextAlignmentCenter;
    textField.borderStyle = UITextBorderStyleRoundedRect;
    textField.tag = tag;
    textField.delegate = self;
    textField.translatesAutoresizingMaskIntoConstraints = NO;
    [textField addTarget:self action:@selector(textFieldValueChanged:) forControlEvents:UIControlEventEditingChanged];
    [rowView addSubview:textField];
    
    // 创建滑块
    UISlider *slider = [[UISlider alloc] init];
    slider.minimumValue = 0;
    
    // 根据不同数据类型设置不同的最大值
    if ([key isEqualToString:DYYY_WALLET_COIN_KEY]) {
        slider.maximumValue = 1000000; // 抖币上限100万
    } else if ([key isEqualToString:DYYY_WALLET_BALANCE_KEY]) {
        slider.maximumValue = 100000; // 余额上限10万
    } else {
        slider.maximumValue = 100000; // 现金上限10万
    }
    
    slider.minimumTrackTintColor = color;
    slider.tag = tag + 200; // 滑块tag = 输入框tag + 200
    slider.translatesAutoresizingMaskIntoConstraints = NO;
    [slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [rowView addSubview:slider];
    
    // 保存关联的键
    objc_setAssociatedObject(textField, "keyName", key, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(slider, "keyName", key, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    // 布局约束
    [NSLayoutConstraint activateConstraints:@[
        // 图标约束
        [iconView.leadingAnchor constraintEqualToAnchor:rowView.leadingAnchor constant:2],
        [iconView.topAnchor constraintEqualToAnchor:rowView.topAnchor constant:8],
        [iconView.widthAnchor constraintEqualToConstant:22],
        [iconView.heightAnchor constraintEqualToConstant:22],
        
        // 标题约束
        [titleLabel.leadingAnchor constraintEqualToAnchor:iconView.trailingAnchor constant:8],
        [titleLabel.centerYAnchor constraintEqualToAnchor:iconView.centerYAnchor],
        
        // 数值预览标签约束
        [valueLabel.trailingAnchor constraintEqualToAnchor:rowView.trailingAnchor],
        [valueLabel.centerYAnchor constraintEqualToAnchor:iconView.centerYAnchor],
        [valueLabel.leadingAnchor constraintEqualToAnchor:titleLabel.trailingAnchor constant:10],
        
        // 输入框约束
        [textField.topAnchor constraintEqualToAnchor:iconView.bottomAnchor constant:8],
        [textField.leadingAnchor constraintEqualToAnchor:rowView.leadingAnchor],
        [textField.widthAnchor constraintEqualToConstant:100],
        [textField.heightAnchor constraintEqualToConstant:35],
        
        // 滑块约束
        [slider.leadingAnchor constraintEqualToAnchor:textField.trailingAnchor constant:10],
        [slider.trailingAnchor constraintEqualToAnchor:rowView.trailingAnchor],
        [slider.centerYAnchor constraintEqualToAnchor:textField.centerYAnchor],
    ]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    UIView *cardView = [self.view viewWithTag:100];
    
    // 设置卡片的初始状态为缩小并透明
    cardView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.8, 0.8);
    cardView.alpha = 0;
    self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
    
    // 执行弹出动画
    [UIView animateWithDuration:0.3 
                          delay:0 
                        options:UIViewAnimationOptionCurveEaseOut 
                     animations:^{
        cardView.transform = CGAffineTransformIdentity;
        cardView.alpha = 1;
        self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
    } completion:nil];
}

// 加载现有数据
- (void)loadExistingData {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *keys = @[
        DYYY_WALLET_BALANCE_KEY,
        DYYY_WALLET_COIN_KEY,
        DYYY_DOUYIN_CASH_KEY
    ];
    
    for (int i = 0; i < keys.count; i++) {
        NSString *key = keys[i];
        NSString *value = [defaults objectForKey:key];
        
        if (value) {
            [_currentValues setObject:value forKey:key];
            
            // 更新UI
            UITextField *textField = [self.view viewWithTag:200 + i];
            UILabel *valueLabel = [self.view viewWithTag:300 + i];
            UISlider *slider = [self.view viewWithTag:400 + i];
            
            textField.text = value;
            
            // 格式化显示
            if ([key isEqualToString:DYYY_WALLET_BALANCE_KEY] || [key isEqualToString:DYYY_DOUYIN_CASH_KEY]) {
                valueLabel.text = [self formatCurrencyString:value];
            } else {
                valueLabel.text = [self formatNumberString:value];
            }
            
            // 设置滑块值，但不超过滑块最大值
            float sliderValue = [value floatValue];
            if (sliderValue > slider.maximumValue) {
                sliderValue = slider.maximumValue;
            }
            slider.value = sliderValue;
        }
    }
}

// 处理滑块值变化
- (void)sliderValueChanged:(UISlider *)slider {
    NSInteger correspondingTextFieldTag = slider.tag - 200;
    NSInteger correspondingValueLabelTag = slider.tag - 100;
    
    UITextField *textField = [self.view viewWithTag:correspondingTextFieldTag];
    UILabel *valueLabel = [self.view viewWithTag:correspondingValueLabelTag];
    
    NSString *key = objc_getAssociatedObject(slider, "keyName");
    NSString *stringValue;
    
    // 根据不同类型格式化数值
    if ([key isEqualToString:DYYY_WALLET_COIN_KEY]) {
        // 硬币只能是整数
        NSInteger intValue = roundf(slider.value);
        stringValue = [NSString stringWithFormat:@"%ld", (long)intValue];
        valueLabel.text = [self formatNumberString:stringValue];
    } else {
        // 余额和现金需要显示到小数点后两位
        float floatValue = slider.value;
        stringValue = [NSString stringWithFormat:@"%.2f", floatValue];
        valueLabel.text = [self formatCurrencyString:stringValue];
    }
    
    // 更新输入框
    textField.text = stringValue;
    
    // 保存当前值到临时字典
    if (key) {
        [_currentValues setObject:stringValue forKey:key];
    }
    
    // 添加轻微振动反馈
    if (@available(iOS 10.0, *)) {
        UIImpactFeedbackGenerator *generator = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleLight];
        [generator prepare];
        [generator impactOccurred];
    }
}

// 处理输入框值变化
- (void)textFieldValueChanged:(UITextField *)textField {
    NSInteger correspondingSliderTag = textField.tag + 200;
    NSInteger correspondingValueLabelTag = textField.tag + 100;
    
    UISlider *slider = [self.view viewWithTag:correspondingSliderTag];
    UILabel *valueLabel = [self.view viewWithTag:correspondingValueLabelTag];
    
    // 获取输入文本并转换为数字
    NSString *text = textField.text;
    float floatValue = [text floatValue];
    
    // 限制在滑块范围内
    if (floatValue > slider.maximumValue) {
        floatValue = slider.maximumValue;
    }
    
    // 更新滑块
    slider.value = floatValue;
    
    // 根据不同类型格式化显示
    NSString *key = objc_getAssociatedObject(textField, "keyName");
    if ([key isEqualToString:DYYY_WALLET_BALANCE_KEY] || [key isEqualToString:DYYY_DOUYIN_CASH_KEY]) {
        valueLabel.text = [self formatCurrencyString:text];
    } else {
        valueLabel.text = [self formatNumberString:text];
    }
    
    // 保存当前值到临时字典
    if (key) {
        [_currentValues setObject:text forKey:key];
    }
}

// 格式化数字字符串（添加千位分隔符）
- (NSString *)formatNumberString:(NSString *)numberString {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    formatter.groupingSeparator = @",";
    formatter.groupingSize = 3;
    
    NSNumber *number = @([numberString longLongValue]);
    return [formatter stringFromNumber:number];
}

// 格式化货币字符串（添加币种符号和小数位）
- (NSString *)formatCurrencyString:(NSString *)currencyString {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterCurrencyStyle;
    formatter.currencySymbol = @"¥";
    formatter.groupingSeparator = @",";
    formatter.groupingSize = 3;
    formatter.minimumFractionDigits = 2;
    formatter.maximumFractionDigits = 2;
    
    NSNumber *number = @([currencyString doubleValue]);
    return [formatter stringFromNumber:number];
}

// 取消按钮动作
- (void)cancelAction {
    [self dismissWithAnimation:YES completion:nil];
}

// 保存按钮动作
- (void)saveAction {
    // 保存数据到UserDefaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    for (NSString *key in _currentValues) {
        NSString *value = _currentValues[key];
        if (value.length > 0) {
            [defaults setObject:value forKey:key];
        } else {
            [defaults removeObjectForKey:key];
        }
    }
    
    // 启用钱包数据自定义
    [defaults setBool:YES forKey:DYYY_WALLET_ENABLED_KEY];
    [defaults synchronize];
    
    // 重新加载数据
    loadCustomWalletStats();
    
    // 发送通知
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DYYYWalletStatsChanged" 
                                                      object:nil 
                                                    userInfo:@{
        @"action": @"update",
        @"timestamp": @([[NSDate date] timeIntervalSince1970])
    }];
    
    // 添加成功振动反馈
    if (@available(iOS 10.0, *)) {
        UINotificationFeedbackGenerator *generator = [[UINotificationFeedbackGenerator alloc] init];
        [generator prepare];
        [generator notificationOccurred:UINotificationFeedbackTypeSuccess];
    }
    
    // 关闭弹窗
    [self dismissWithAnimation:YES completion:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            UIViewController *topVC = [DYYYManager getActiveTopController];
            if (topVC) {
                // 强制刷新钱包相关页面
                findAndRefreshWalletViews(topVC.view);
            }
        });
    }];
}

// 带动画消失
- (void)dismissWithAnimation:(BOOL)animated completion:(void(^)(void))completion {
    if (animated) {
        UIView *cardView = [self.view viewWithTag:100];
        
        [UIView animateWithDuration:0.2 animations:^{
            cardView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.8, 0.8);
            cardView.alpha = 0;
            self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
        } completion:^(BOOL finished) {
            [self dismissViewControllerAnimated:NO completion:^{
                if (completion) completion();
            }];
        }];
    } else {
        [self dismissViewControllerAnimated:NO completion:completion];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *key = objc_getAssociatedObject(textField, "keyName");
    
    // 硬币只能输入整数
    if ([key isEqualToString:DYYY_WALLET_COIN_KEY]) {
        NSCharacterSet *nonDigitSet = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
        if ([string rangeOfCharacterFromSet:nonDigitSet].location != NSNotFound) {
            return NO;
        }
    } 
    // 余额和现金可以输入小数
    else {
        // 检查是否已有小数点
        BOOL hasDecimalPoint = [textField.text rangeOfString:@"."].location != NSNotFound;
        
        // 如果输入的是小数点，并且已经有小数点，拒绝输入
        if ([string isEqualToString:@"."] && hasDecimalPoint) {
            return NO;
        }
        
        // 如果输入的不是小数点，也不是数字，拒绝输入
        if (![string isEqualToString:@"."] && ![[NSCharacterSet decimalDigitCharacterSet] characterIsMember:[string characterAtIndex:0]]) {
            return NO;
        }
        
        // 如果已有小数点，限制小数位数为2位
        if (hasDecimalPoint) {
            NSArray *components = [textField.text componentsSeparatedByString:@"."];
            if (components.count > 1) {
                NSString *decimalPart = components[1];
                if (decimalPart.length >= 2 && range.location > [textField.text rangeOfString:@"."].location) {
                    return NO;
                }
            }
        }
    }
    
    // 限制最大长度
    NSString *newText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if ([key isEqualToString:DYYY_WALLET_COIN_KEY]) {
        // 硬币限制为9位数
        return newText.length <= 9;
    } else {
        // 余额和现金限制为10位数(包括小数点和小数位)
        return newText.length <= 10;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - 键盘处理

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    UIView *cardView = [self.view viewWithTag:100];
    CGRect cardFrame = [cardView convertRect:cardView.bounds toView:self.view];
    
    CGFloat bottomOfCard = cardFrame.origin.y + cardFrame.size.height;
    CGFloat topOfKeyboard = self.view.frame.size.height - keyboardSize.height;
    
    // 如果卡片底部被键盘遮挡
    if (bottomOfCard > topOfKeyboard) {
        CGFloat offsetY = bottomOfCard - topOfKeyboard + 20; // 额外20pt的空间
        
        [UIView animateWithDuration:0.3 animations:^{
            cardView.transform = CGAffineTransformMakeTranslation(0, -offsetY);
        }];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    UIView *cardView = [self.view viewWithTag:100];
    
    [UIView animateWithDuration:0.3 animations:^{
        cardView.transform = CGAffineTransformIdentity;
    }];
}

#pragma mark - 背景点击处理

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    UIView *cardView = [self.view viewWithTag:100];
    CGPoint touchPoint = [touch locationInView:self.view];
    return ![cardView pointInside:[self.view convertPoint:touchPoint toView:cardView] withEvent:nil];
}

- (void)handleBackgroundTap:(UITapGestureRecognizer *)gesture {
    [self.view endEditing:YES];
    [self cancelAction];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

// 显示编辑钱包数据弹窗
static void showWalletEditAlert(UIViewController *viewController) {
    DYYYWalletEditViewController *editVC = [[DYYYWalletEditViewController alloc] init];
    [viewController presentViewController:editVC animated:YES completion:nil];
}

// 查找并刷新钱包视图
static void findAndRefreshWalletViews(UIView *rootView) {
    enumerateViewsRecursively(rootView, ^(UIView *view) {
        if ([view isKindOfClass:NSClassFromString(@"IESLiveWalletBalanceView")] || 
            [view isKindOfClass:NSClassFromString(@"CJPayBalanceView")] || 
            [view isKindOfClass:NSClassFromString(@"AWEPayTransferMoneyView")]) {
            
            // 强制刷新视图
            [view setNeedsLayout];
            [view layoutIfNeeded];
            
            // 添加轻微的动画触发重绘
            [UIView animateWithDuration:0.2 animations:^{
                view.alpha = 0.99;
            } completion:^(BOOL finished) {
                view.alpha = 1.0;
            }];
        }
    });
}

// 钩子实现部分 - 钱包余额模型
%hook CJPayBalanceModel

- (id)init {
    id instance = %orig;
    if (walletStatsEnabled && instance) {
        updateWalletModelData(instance);
    }
    return instance;
}

- (NSNumber *)balance {
    return walletStatsEnabled && cachedWalletBalanceNumber ? cachedWalletBalanceNumber : %orig;
}

- (void)setBalance:(NSNumber *)balance {
    if (walletStatsEnabled && cachedWalletBalanceNumber) {
        %orig(cachedWalletBalanceNumber);
    } else {
        %orig;
    }
}

%end

// 直播钱包硬币模型
%hook IESLiveWalletMyCoinModel

- (id)init {
    id instance = %orig;
    if (walletStatsEnabled && instance) {
        updateWalletModelData(instance);
    }
    return instance;
}

- (NSNumber *)coinCount {
    return walletStatsEnabled && cachedWalletCoinNumber ? cachedWalletCoinNumber : %orig;
}

- (void)setCoinCount:(NSNumber *)count {
    if (walletStatsEnabled && cachedWalletCoinNumber) {
        %orig(cachedWalletCoinNumber);
    } else {
        %orig;
    }
}

%end

// 钱包硬币视图控制器
%hook IESLiveWalletMyCoinViewController

- (void)viewWillAppear:(BOOL)animated {
    %orig;
    
    if (walletStatsEnabled) {
        // 延迟刷新确保UI已完全加载
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            findAndRefreshWalletViews(self.view);
        });
    }
}

- (void)viewDidLoad {
    %orig;
    
    if (walletStatsEnabled) {
        // 添加双击编辑手势
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dyyy_handleDoubleTap:)];
        doubleTap.numberOfTapsRequired = 2;
        [self.view addGestureRecognizer:doubleTap];
    }
}

%new
- (void)dyyy_handleDoubleTap:(UITapGestureRecognizer *)gesture {
    // 添加显式类型转换以解决编译问题
    showWalletEditAlert((UIViewController *)self);
}

%end

// 转账接收页面
%hook AWEPayTransferAccountsReceiveViewController

- (void)viewWillAppear:(BOOL)animated {
    %orig;
    
    if (walletStatsEnabled) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            findAndRefreshWalletViews(self.view);
        });
    }
}

- (void)viewDidLoad {
    %orig;
    
    if (walletStatsEnabled) {
        // 添加双击编辑手势
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dyyy_handleDoubleTap:)];
        doubleTap.numberOfTapsRequired = 2;
        [self.view addGestureRecognizer:doubleTap];
    }
}

%new
- (void)dyyy_handleDoubleTap:(UITapGestureRecognizer *)gesture {
    showWalletEditAlert(self);
}

%end

// 转账发送页面
%hook AWEPayTransferAccountsSendViewController

- (void)viewWillAppear:(BOOL)animated {
    %orig;
    
    if (walletStatsEnabled) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            findAndRefreshWalletViews(self.view);
        });
    }
}

- (void)viewDidLoad {
    %orig;
    
    if (walletStatsEnabled) {
        // 添加双击编辑手势
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dyyy_handleDoubleTap:)];
        doubleTap.numberOfTapsRequired = 2;
        [self.view addGestureRecognizer:doubleTap];
    }
}

%new
- (void)dyyy_handleDoubleTap:(UITapGestureRecognizer *)gesture {
    showWalletEditAlert(self);
}

%end

// 提现结果页面
%hook CJPayWithDrawResultViewController

- (void)viewWillAppear:(BOOL)animated {
    %orig;
    
    if (walletStatsEnabled) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            findAndRefreshWalletViews(self.view);
        });
    }
}

%end

// 充值余额页面
%hook CJPayRechargeBalanceViewController

- (void)viewWillAppear:(BOOL)animated {
    %orig;
    
    if (walletStatsEnabled) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            findAndRefreshWalletViews(self.view);
        });
    }
}

- (void)viewDidLoad {
    %orig;
    
    if (walletStatsEnabled) {
        // 添加双击编辑手势
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dyyy_handleDoubleTap:)];
        doubleTap.numberOfTapsRequired = 2;
        [self.view addGestureRecognizer:doubleTap];
    }
}

%new
- (void)dyyy_handleDoubleTap:(UITapGestureRecognizer *)gesture {
    showWalletEditAlert(self);
}

%end

// 支付视图类的钩子
%hook AWEPayTransferMoneyView

- (void)updateWithViewModel:(id)viewModel {
    %orig;
    
    if (walletStatsEnabled && cachedWalletBalanceNumber) {
        // 在视图更新后修改显示值
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            UILabel *balanceLabel = [self valueForKey:@"balanceLabel"];
            if ([balanceLabel isKindOfClass:[UILabel class]]) {
                NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
                formatter.numberStyle = NSNumberFormatterCurrencyStyle;
                formatter.currencySymbol = @"¥";
                formatter.minimumFractionDigits = 2;
                [balanceLabel setText:[formatter stringFromNumber:cachedWalletBalanceNumber]];
            }
        });
    }
}

%end

// 钩子初始化
%ctor {
    loadCustomWalletStats();
    
    // 设置变更监听
    [[NSNotificationCenter defaultCenter] addObserverForName:@"DYYYWalletStatsChanged" 
                                                      object:nil 
                                                       queue:[NSOperationQueue mainQueue] 
                                                  usingBlock:^(NSNotification *note) {
        NSLog(@"[DYYY] 收到钱包设置变更通知: %@", note.userInfo);
        
        // 重新加载数据
        loadCustomWalletStats();
        
        // 刷新界面
        dispatch_async(dispatch_get_main_queue(), ^{
            UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
            findAndRefreshWalletViews(keyWindow);
        });
    }];
    
    // 注册设置变更通知
    [[NSNotificationCenter defaultCenter] addObserverForName:@"DYYYSettingChanged" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        NSDictionary *userInfo = note.userInfo;
        NSString *key = userInfo[@"key"];
        
        // 处理钱包自定义设置变更
        if ([key hasPrefix:@"DYYYCustomWallet"] || [key isEqualToString:DYYY_WALLET_ENABLED_KEY]) {
            // 刷新钱包视图
            UIViewController *topVC = [DYYYManager getActiveTopController];
            if (topVC) {
                findAndRefreshWalletViews(topVC.view);
            }
        }
    }];
}
