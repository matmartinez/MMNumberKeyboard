//
//  MMNumberKeyboard.m
//  MMNumberKeyboard
//
//  Created by Matías Martínez on 12/10/15.
//  Copyright © 2015 Matías Martínez. All rights reserved.
//

#import "MMNumberKeyboard.h"
#import "MMKeyboardButton.h"
#import "MMTextInputDelegateProxy.h"

typedef NS_ENUM(NSUInteger, MMNumberKeyboardButton) {
    MMNumberKeyboardButtonNumberMin,
    MMNumberKeyboardButtonNumberMax = MMNumberKeyboardButtonNumberMin + 10, // Ten digits.
    MMNumberKeyboardButtonBackspace,
    MMNumberKeyboardButtonDone,
    MMNumberKeyboardButtonSpecial,
    MMNumberKeyboardButtonDecimalPoint,
    MMNumberKeyboardButtonNone = NSNotFound,
};

@interface MMNumberKeyboard () <UIInputViewAudioFeedback, UITextInputDelegate>

@property (strong, nonatomic) NSDictionary *buttonDictionary;
@property (strong, nonatomic) NSMutableArray *separatorViews;
@property (strong, nonatomic) NSLocale *locale;
@property (strong, nonatomic) MMTextInputDelegateProxy *keyInputProxy;

@property (copy, nonatomic) dispatch_block_t specialKeyHandler;

@end

static __weak id currentFirstResponder;

@implementation UIResponder (FirstResponder)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-repeated-use-of-weak"
+ (id)MM_currentFirstResponder
{
    currentFirstResponder = nil;
    [[UIApplication sharedApplication] sendAction:@selector(MM_findFirstResponder:) to:nil from:nil forEvent:nil];
    return currentFirstResponder;
}
#pragma clang diagnostic pop

- (void)MM_findFirstResponder:(id)sender
{
    currentFirstResponder = self;
}

@end

@implementation MMNumberKeyboard

static const NSInteger MMNumberKeyboardRows = 4;
static const CGFloat MMNumberKeyboardRowHeight = 55.0f;
static const CGFloat MMNumberKeyboardPadBorder = 7.0f;
static const CGFloat MMNumberKeyboardPadSpacing = 8.0f;

#define UIKitLocalizedString(key) [[NSBundle bundleWithIdentifier:@"com.apple.UIKit"] localizedStringForKey:key value:@"" table:nil]

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame inputViewStyle:UIInputViewStyleKeyboard];
    if (self) {
        [self _commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame inputViewStyle:(UIInputViewStyle)inputViewStyle
{
    self = [super initWithFrame:frame inputViewStyle:inputViewStyle];
    if (self) {
        [self _commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame inputViewStyle:(UIInputViewStyle)inputViewStyle locale:(NSLocale *)locale
{
    self = [super initWithFrame:frame inputViewStyle:inputViewStyle];
    if (self) {
        self.locale = locale;
        [self _commonInit];
    }
    return self;
}

- (void)_commonInit
{
    // Configure buttons.
    [self _configureButtonsForCurrentStyle];
    
    // Initialize an array for the separators.
    self.separatorViews = [NSMutableArray array];
    
    // Add default action.
    UIImage *dismissImage = [self.class _keyboardImageNamed:@"MMNumberKeyboardDismissKey.png"];
    
    [self configureSpecialKeyWithImage:dismissImage target:self action:@selector(_dismissKeyboard:)];
    
    // Add default return key title.
    [self setReturnKeyTitle:nil];
    
    // Add default return key style.
    [self setReturnKeyButtonStyle:MMNumberKeyboardButtonStyleDone];
    
    // If an input view contains the .flexibleHeight option, the view will be sized as the default keyboard. This doesn't make much sense in the iPad, as we prefer a more compact keyboard.
    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
        [self setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
    } else {
        [self sizeToFit];
    }
}

- (void)_configureButtonsForCurrentStyle
{
    NSMutableDictionary *buttonDictionary = [NSMutableDictionary dictionary];
    
    const NSInteger numberMin = MMNumberKeyboardButtonNumberMin;
    const NSInteger numberMax = MMNumberKeyboardButtonNumberMax;
    
    const CGFloat buttonFontPointSize = 28.0f;
    UIFont *buttonFont = ({
        UIFont *font = nil;
#if defined(__has_attribute) && __has_attribute(availability)
        if (@available(iOS 8.2, *)) {
            font = [UIFont systemFontOfSize:buttonFontPointSize weight:UIFontWeightLight];
        }
#else
        if ([UIFont respondsToSelector:@selector(systemFontOfSize:weight:)]) {
            font = [UIFont systemFontOfSize:buttonFontPointSize weight:UIFontWeightLight];
        }
#endif
        font ?: [UIFont fontWithName:@"HelveticaNeue-Light" size:buttonFontPointSize];
    });
    
    UIFont *doneButtonFont = [UIFont systemFontOfSize:17.0f];
    
    for (MMNumberKeyboardButton key = numberMin; key < numberMax; key++) {
        UIButton *button = [MMKeyboardButton keyboardButtonWithStyle:MMNumberKeyboardButtonStyleWhite];
        NSString *title = @(key - numberMin).stringValue;
        
        [button setTitle:title forState:UIControlStateNormal];
        [button.titleLabel setFont:buttonFont];
        
        [buttonDictionary setObject:button forKey:@(key)];
    }
    
    UIImage *backspaceImage = [self.class _keyboardImageNamed:@"MMNumberKeyboardDeleteKey.png"];
    
    UIButton *backspaceButton = [MMKeyboardButton keyboardButtonWithStyle:MMNumberKeyboardButtonStyleGray];
    [backspaceButton setImage:[backspaceImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    
    [(MMKeyboardButton *)backspaceButton addTarget:self action:@selector(_backspaceRepeat:) forContinuousPressWithTimeInterval:0.15f];
    
    [buttonDictionary setObject:backspaceButton forKey:@(MMNumberKeyboardButtonBackspace)];
    
    UIButton *specialButton = [MMKeyboardButton keyboardButtonWithStyle:MMNumberKeyboardButtonStyleGray];
    
    [buttonDictionary setObject:specialButton forKey:@(MMNumberKeyboardButtonSpecial)];
    
    UIButton *doneButton = [MMKeyboardButton keyboardButtonWithStyle:MMNumberKeyboardButtonStyleDone];
    [doneButton.titleLabel setFont:doneButtonFont];
    [doneButton setTitle:UIKitLocalizedString(@"Done") forState:UIControlStateNormal];
    
    [buttonDictionary setObject:doneButton forKey:@(MMNumberKeyboardButtonDone)];
    
    UIButton *decimalPointButton = [MMKeyboardButton keyboardButtonWithStyle:MMNumberKeyboardButtonStyleWhite];
    
    NSLocale *locale = self.locale ?: [NSLocale currentLocale];
    NSString *decimalSeparator = [locale objectForKey:NSLocaleDecimalSeparator];
    [decimalPointButton setTitle:decimalSeparator ?: @"." forState:UIControlStateNormal];
    
    [buttonDictionary setObject:decimalPointButton forKey:@(MMNumberKeyboardButtonDecimalPoint)];
    
    for (UIButton *button in buttonDictionary.objectEnumerator) {
        [button setExclusiveTouch:YES];
        [button addTarget:self action:@selector(_buttonInput:) forControlEvents:UIControlEventTouchUpInside];
        [button addTarget:self action:@selector(_buttonPlayClick:) forControlEvents:UIControlEventTouchDown];
        
        [self addSubview:button];
    }
    
    UIPanGestureRecognizer *highlightGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_handleHighlightGestureRecognizer:)];
    [self addGestureRecognizer:highlightGestureRecognizer];
    
    if (self.buttonDictionary) {
        [self.buttonDictionary.allValues makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    
    self.buttonDictionary = buttonDictionary;
}

- (void)_configureButtonsForKeyInputState
{
    const BOOL hasText = self.keyInput.hasText;
    const BOOL enablesReturnKeyAutomatically = self.enablesReturnKeyAutomatically;
    
    MMKeyboardButton *button = self.buttonDictionary[@(MMNumberKeyboardButtonDone)];
    if (button) {
        button.enabled = (!enablesReturnKeyAutomatically) || (enablesReturnKeyAutomatically && hasText);
    }
}

#pragma mark - Input.

- (void)_handleHighlightGestureRecognizer:(UIPanGestureRecognizer *)gestureRecognizer
{
    CGPoint point = [gestureRecognizer locationInView:self];
    
    if (gestureRecognizer.state == UIGestureRecognizerStateChanged || gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        for (UIButton *button in self.buttonDictionary.objectEnumerator) {
            BOOL points = CGRectContainsPoint(button.frame, point) && !button.isHidden;
            
            if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
                [button setHighlighted:points];
            } else {
                [button setHighlighted:NO];
            }
            
            if (gestureRecognizer.state == UIGestureRecognizerStateEnded && points) {
                [button sendActionsForControlEvents:UIControlEventTouchUpInside];
            }
        }
    }
}

- (void)_buttonPlayClick:(UIButton *)button
{
    [[UIDevice currentDevice] playInputClick];
}

- (void)_buttonInput:(UIButton *)button
{
    __block MMNumberKeyboardButton keyboardButton = MMNumberKeyboardButtonNone;
    
    [self.buttonDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        MMNumberKeyboardButton k = [key unsignedIntegerValue];
        if (button == obj) {
            keyboardButton = k;
            *stop = YES;
        }
    }];
    
    if (keyboardButton == MMNumberKeyboardButtonNone) {
        return;
    }
    
    // Get first responder.
    id <UIKeyInput> keyInput = self.keyInput;
    id <MMNumberKeyboardDelegate> delegate = self.delegate;
    
    if (!keyInput) {
        return;
    }
    
    // Handle number.
    const NSInteger numberMin = MMNumberKeyboardButtonNumberMin;
    const NSInteger numberMax = MMNumberKeyboardButtonNumberMax;
    
    if (keyboardButton >= numberMin && keyboardButton < numberMax) {
        NSNumber *number = @(keyboardButton - numberMin);
        NSString *string = number.stringValue;
        
        if ([delegate respondsToSelector:@selector(numberKeyboard:shouldInsertText:)]) {
            BOOL shouldInsert = [delegate numberKeyboard:self shouldInsertText:string];
            if (!shouldInsert) {
                return;
            }
        }
        
        [keyInput insertText:string];
    }
    
    // Handle backspace.
    else if (keyboardButton == MMNumberKeyboardButtonBackspace) {
        BOOL shouldDeleteBackward = YES;
		
        if ([delegate respondsToSelector:@selector(numberKeyboardShouldDeleteBackward:)]) {
            shouldDeleteBackward = [delegate numberKeyboardShouldDeleteBackward:self];
        }
		
        if (shouldDeleteBackward) {
            [keyInput deleteBackward];
        }
    }
    
    // Handle done.
    else if (keyboardButton == MMNumberKeyboardButtonDone) {
        BOOL shouldReturn = YES;
        
        if ([delegate respondsToSelector:@selector(numberKeyboardShouldReturn:)]) {
            shouldReturn = [delegate numberKeyboardShouldReturn:self];
        }
        
        if (shouldReturn) {
            [self _dismissKeyboard:button];
        }
    }
    
    // Handle special key.
    else if (keyboardButton == MMNumberKeyboardButtonSpecial) {
        dispatch_block_t handler = self.specialKeyHandler;
        if (handler) {
            handler();
        }
    }
    
    // Handle .
    else if (keyboardButton == MMNumberKeyboardButtonDecimalPoint) {
        NSString *decimalText = [button titleForState:UIControlStateNormal];
        if ([delegate respondsToSelector:@selector(numberKeyboard:shouldInsertText:)]) {
            BOOL shouldInsert = [delegate numberKeyboard:self shouldInsertText:decimalText];
            if (!shouldInsert) {
                return;
            }
        }
        
        [keyInput insertText:decimalText];
    }
    
    [self _configureButtonsForKeyInputState];
}

- (void)_backspaceRepeat:(UIButton *)button
{
    id <UIKeyInput> keyInput = self.keyInput;
    
    if (![keyInput hasText]) {
        return;
    }
    
    [self _buttonPlayClick:button];
    [self _buttonInput:button];
}

- (id<UIKeyInput>)keyInput
{
    id <UIKeyInput> keyInput = _keyInput;
    
    if (!keyInput) {
        keyInput = [UIResponder MM_currentFirstResponder];
        
        if (![keyInput conformsToProtocol:@protocol(UIKeyInput)]) {
            NSLog(@"Warning: First responder %@ does not conform to the UIKeyInput protocol.", keyInput);
            keyInput = nil;
        }
    }
    
    MMTextInputDelegateProxy *keyInputProxy = _keyInputProxy;
    
    if (keyInput != _keyInput) {
        if ([_keyInput conformsToProtocol:@protocol(UITextInput)]) {
            [(id <UITextInput>)_keyInput setInputDelegate:keyInputProxy.previousTextInputDelegate];
        }
        
        if ([keyInput conformsToProtocol:@protocol(UITextInput)]) {
            keyInputProxy = [MMTextInputDelegateProxy proxyForTextInput:(id <UITextInput>)keyInput delegate:self];
            [(id <UITextInput>)keyInput setInputDelegate:(id)keyInputProxy];
        } else {
            keyInputProxy = nil;
        }
    }
    
    _keyInput = keyInput;
    _keyInputProxy = keyInputProxy;
    
    return keyInput;
}

#pragma mark - <UITextInputDelegate>

- (void)selectionWillChange:(id <UITextInput>)textInput
{
    // Intentionally left unimplemented in conformance with <UITextInputDelegate>.
}

- (void)selectionDidChange:(id <UITextInput>)textInput
{
    // Intentionally left unimplemented in conformance with <UITextInputDelegate>.
}

- (void)textWillChange:(id <UITextInput>)textInput
{
    // Intentionally left unimplemented in conformance with <UITextInputDelegate>.
}

- (void)textDidChange:(id <UITextInput>)textInput
{
    [self _configureButtonsForKeyInputState];
}

#pragma mark - Key input lookup.

- (void)didMoveToWindow
{
    [super didMoveToWindow];
    [self _configureButtonsForKeyInputState];
}

#pragma mark - Default special action.

- (void)_dismissKeyboard:(id)sender
{
    id <UIKeyInput> keyInput = self.keyInput;
    
    if ([keyInput isKindOfClass:[UIResponder class]]) {
        [(UIResponder *)keyInput resignFirstResponder];
    }
}

#pragma mark - Public.

- (void)configureSpecialKeyWithImage:(UIImage *)image actionHandler:(dispatch_block_t)handler
{
    if (image) {
        self.specialKeyHandler = handler;
    } else {
        self.specialKeyHandler = NULL;
    }
    
    UIButton *button = self.buttonDictionary[@(MMNumberKeyboardButtonSpecial)];
    [button setImage:image forState:UIControlStateNormal];
}

- (void)configureSpecialKeyWithImage:(UIImage *)image target:(id)target action:(SEL)action
{
    __weak typeof(self)weakTarget = target;
    __weak typeof(self)weakSelf = self;
    
    [self configureSpecialKeyWithImage:image actionHandler:^{
        __strong __typeof(&*weakTarget)strongTarget = weakTarget;
        __strong __typeof(&*weakSelf)strongSelf = weakSelf;
        
        if (strongTarget) {
            NSMethodSignature *methodSignature = [strongTarget methodSignatureForSelector:action];
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
            [invocation setSelector:action];
            if (methodSignature.numberOfArguments > 2) {
                [invocation setArgument:&strongSelf atIndex:2];
            }
            [invocation invokeWithTarget:strongTarget];
        }
    }];
}

- (void)setAllowsDecimalPoint:(BOOL)allowsDecimalPoint
{
    if (allowsDecimalPoint != _allowsDecimalPoint) {
        _allowsDecimalPoint = allowsDecimalPoint;
        
        [self setNeedsLayout];
    }
}

- (void)setReturnKeyTitle:(NSString *)title
{
    if (!title) {
        title = [self defaultReturnKeyTitle];
    }
    
    if (![title isEqualToString:self.returnKeyTitle]) {
        UIButton *button = self.buttonDictionary[@(MMNumberKeyboardButtonDone)];
        if (button) {
            NSString *returnKeyTitle = (title != nil && title.length > 0) ? title : [self defaultReturnKeyTitle];
            [button setTitle:returnKeyTitle forState:UIControlStateNormal];
        }
    }
}

- (NSString *)returnKeyTitle
{
    UIButton *button = self.buttonDictionary[@(MMNumberKeyboardButtonDone)];
    if (button) {
        NSString *title = [button titleForState:UIControlStateNormal];
        if (title != nil && title.length > 0) {
            return title;
        }
    }
    return [self defaultReturnKeyTitle];
}

- (NSString *)defaultReturnKeyTitle
{
    return UIKitLocalizedString(@"Done");
}

- (void)setReturnKeyButtonStyle:(MMNumberKeyboardButtonStyle)style
{
    if (style != _returnKeyButtonStyle) {
        _returnKeyButtonStyle = style;
        
        MMKeyboardButton *button = self.buttonDictionary[@(MMNumberKeyboardButtonDone)];
        if (button) {
            button.style = style;
        }
    }
}

- (void)setEnablesReturnKeyAutomatically:(BOOL)enablesReturnKeyAutomatically
{
    if (enablesReturnKeyAutomatically != _enablesReturnKeyAutomatically) {
        _enablesReturnKeyAutomatically = enablesReturnKeyAutomatically;
        
        [self _configureButtonsForKeyInputState];
    }
}

- (void)setPreferredStyle:(MMNumberKeyboardStyle)style
{
    if (style != _preferredStyle) {
        _preferredStyle = style;
        
        [self setNeedsLayout];
    }
}

#pragma mark - Layout.

NS_INLINE CGRect MMButtonRectMake(CGRect rect, CGRect contentRect, BOOL usesRoundedCorners){
    rect = CGRectOffset(rect, contentRect.origin.x, contentRect.origin.y);
    
    if (usesRoundedCorners) {
        CGFloat inset = MMNumberKeyboardPadSpacing / 2.0f;
        rect = CGRectInset(rect, inset, inset);
    }
    
    return rect;
};

#if CGFLOAT_IS_DOUBLE
#define MMRound round
#else
#define MMRound roundf
#endif

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect bounds = (CGRect){
        .size = self.bounds.size
    };
    
    UIEdgeInsets insets = UIEdgeInsetsZero;
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 110000
    if (@available(iOS 11.0, *)) {
        insets = self.safeAreaInsets;
    }
#endif
    
    NSDictionary *buttonDictionary = self.buttonDictionary;
    NSMutableArray *separatorViews = self.separatorViews;
    
    // Settings.
    BOOL usesRoundedButtons = NO;
    
    if ([UITraitCollection class]) {
        const BOOL hasMargins = !UIEdgeInsetsEqualToEdgeInsets(insets, UIEdgeInsetsZero);
        const BOOL isIdiomPad = (self.traitCollection.userInterfaceIdiom == UIUserInterfaceIdiomPad);
        const BOOL systemKeyboardUsesRoundedButtons = self._systemUsesRoundedRectButtonsOnAllInterfaceIdioms;
        
        if (hasMargins || isIdiomPad) {
            usesRoundedButtons = YES;
        } else {
            const BOOL prefersPlainButtons = (self.preferredStyle == MMNumberKeyboardStylePlainButtons);
            const BOOL prefersRoundedButtons = (self.preferredStyle == MMNumberKeyboardStyleRoundedButtons);
            
            if (!prefersPlainButtons) {
                usesRoundedButtons = systemKeyboardUsesRoundedButtons || prefersRoundedButtons;
            }
        }
    } else {
        usesRoundedButtons = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
    }
    
    const CGFloat spacing = (usesRoundedButtons) ? MMNumberKeyboardPadBorder : 0.0f;
    const CGFloat maximumWidth = (usesRoundedButtons) ? 400.0f : CGRectGetWidth(bounds);
    const BOOL allowsDecimalPoint = self.allowsDecimalPoint;
    
    const CGFloat width = MIN(maximumWidth, CGRectGetWidth(bounds) - (spacing * 2.0f));
    
    CGRect contentRect = (CGRect){
        .origin.x = MMRound((CGRectGetWidth(bounds) - width) / 2.0f),
        .origin.y = spacing,
        .size.width = width,
        .size.height = CGRectGetHeight(bounds) - (spacing * 2.0f)
    };
    
    contentRect = UIEdgeInsetsInsetRect(contentRect, insets);
    
    // Layout.
    const CGFloat columnWidth = CGRectGetWidth(contentRect) / 4.0f;
    const CGFloat rowHeight = CGRectGetHeight(contentRect) / MMNumberKeyboardRows;
    
    CGSize numberSize = CGSizeMake(columnWidth, rowHeight);
    
    // Layout numbers.
    const NSInteger numberMin = MMNumberKeyboardButtonNumberMin;
    const NSInteger numberMax = MMNumberKeyboardButtonNumberMax;
    
    const NSInteger numbersPerLine = 3;
    
    for (MMNumberKeyboardButton key = numberMin; key < numberMax; key++) {
        UIButton *button = buttonDictionary[@(key)];
        NSInteger digit = key - numberMin;
        
        CGRect rect = (CGRect){ .size = numberSize };
        
        if (digit == 0) {
            rect.origin.y = numberSize.height * 3;
            rect.origin.x = numberSize.width;
            
            if (!allowsDecimalPoint) {
                rect.size.width = numberSize.width * 2.0f;
                [button setContentEdgeInsets:UIEdgeInsetsMake(0, 0, 0, numberSize.width)];
            }
            
        } else {
            NSUInteger idx = (digit - 1);
            
            NSInteger line = idx / numbersPerLine;
            NSInteger pos = idx % numbersPerLine;
            
            rect.origin.y = line * numberSize.height;
            rect.origin.x = pos * numberSize.width;
        }
        
        [button setFrame:MMButtonRectMake(rect, contentRect, usesRoundedButtons)];
    }
    
    // Layout special key.
    UIButton *specialKey = buttonDictionary[@(MMNumberKeyboardButtonSpecial)];
    if (specialKey) {
        CGRect rect = (CGRect){ .size = numberSize };
        rect.origin.y = numberSize.height * 3;
        
        [specialKey setFrame:MMButtonRectMake(rect, contentRect, usesRoundedButtons)];
    }
    
    // Layout decimal point.
    UIButton *decimalPointKey = buttonDictionary[@(MMNumberKeyboardButtonDecimalPoint)];
    if (decimalPointKey) {
        CGRect rect = (CGRect){ .size = numberSize };
        rect.origin.y = numberSize.height * 3;
        rect.origin.x = numberSize.width * 2;
        
        [decimalPointKey setFrame:MMButtonRectMake(rect, contentRect, usesRoundedButtons)];
        
        decimalPointKey.hidden = !allowsDecimalPoint;
    }
    
    // Layout utility column.
    const int utilityButtonKeys[2] = { MMNumberKeyboardButtonBackspace, MMNumberKeyboardButtonDone };
    const CGSize utilitySize = CGSizeMake(columnWidth, rowHeight * 2.0f);
    
    for (NSInteger idx = 0; idx < sizeof(utilityButtonKeys) / sizeof(int); idx++) {
        MMNumberKeyboardButton key = utilityButtonKeys[idx];
        
        UIButton *button = buttonDictionary[@(key)];
        CGRect rect = (CGRect){ .size = utilitySize };
        
        rect.origin.x = columnWidth * 3.0f;
        rect.origin.y = idx * utilitySize.height;
        
        [button setFrame:MMButtonRectMake(rect, contentRect, usesRoundedButtons)];
    }
    
    // Layout separators:
    const BOOL usesSeparators = !usesRoundedButtons;
    
    if (usesSeparators) {
        const NSUInteger totalColumns = 4;
        const NSUInteger totalRows = numbersPerLine + 1;
        const NSUInteger numberOfSeparators = totalColumns + totalRows - 1;
        
        if (separatorViews.count != numberOfSeparators) {
            const NSUInteger delta = (numberOfSeparators - separatorViews.count);
            const BOOL removes = (separatorViews.count > numberOfSeparators);
            if (removes) {
                NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, delta)];
                [[separatorViews objectsAtIndexes:indexes] makeObjectsPerformSelector:@selector(removeFromSuperview)];
                [separatorViews removeObjectsAtIndexes:indexes];
            } else {
                NSUInteger separatorsToInsert = delta;
                while (separatorsToInsert--) {
                    UIView *separator = [[UIView alloc] initWithFrame:CGRectZero];
                    separator.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.1f];
                    
                    [self addSubview:separator];
                    [separatorViews addObject:separator];
                }
            }
        }
        
        const CGFloat separatorDimension = 1.0f / (self.window.screen.scale ?: 1.0f);
        
        [separatorViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            UIView *separator = obj;
            
            CGRect rect = CGRectZero;
            
            if (idx < totalRows) {
                rect.origin.y = idx * rowHeight;
                if (idx % 2) {
                    rect.size.width = CGRectGetWidth(contentRect) - columnWidth;
                } else {
                    rect.size.width = CGRectGetWidth(contentRect);
                }
                rect.size.height = separatorDimension;
            } else {
                NSInteger col = (idx - totalRows);
                
                rect.origin.x = (col + 1) * columnWidth;
                rect.size.width = separatorDimension;
                
                if (col == 1 && !allowsDecimalPoint) {
                    rect.size.height = CGRectGetHeight(contentRect) - rowHeight;
                } else {
                    rect.size.height = CGRectGetHeight(contentRect);
                }
            }
            
            [separator setFrame:MMButtonRectMake(rect, contentRect, usesRoundedButtons)];
        }];
    } else {
        [separatorViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [separatorViews removeAllObjects];
    }
    
    for (MMKeyboardButton *button in buttonDictionary.allValues) {
        button.usesRoundedCorners = usesRoundedButtons;
    }
}

- (CGSize)sizeThatFits:(CGSize)size
{
    const UIUserInterfaceIdiom interfaceIdiom = UI_USER_INTERFACE_IDIOM();
    const CGFloat spacing = (interfaceIdiom == UIUserInterfaceIdiomPad) ? MMNumberKeyboardPadBorder : 0.0f;
    
    size.height = MMNumberKeyboardRowHeight * MMNumberKeyboardRows + (spacing * 2.0f);
    
    if (size.width == 0.0f) {
        size.width = [UIScreen mainScreen].bounds.size.width;
    }
    
    return size;
}

#pragma mark - Audio feedback.

- (BOOL)enableInputClicksWhenVisible
{
    return YES;
}

#pragma mark - Accessing keyboard images.

+ (UIImage *)_keyboardImageNamed:(NSString *)name
{
    NSString *resource = [name stringByDeletingPathExtension];
    NSString *extension = [name pathExtension];
    
    if (!resource.length) {
        return nil;
    }

    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *resourcePath = [bundle pathForResource:resource ofType:extension];

    if (resourcePath.length) {
        return [UIImage imageWithContentsOfFile:resourcePath];
    }

    return [UIImage imageNamed:resource];
}

#pragma mark - Matching the system's appearance.

- (BOOL)_systemUsesRoundedRectButtonsOnAllInterfaceIdioms
{
    static BOOL usesRoundedRectButtons;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        usesRoundedRectButtons = ([[[UIDevice currentDevice] systemVersion] compare:@"11.0" options:NSNumericSearch] != NSOrderedAscending);
    });
    return usesRoundedRectButtons;
}

@end
