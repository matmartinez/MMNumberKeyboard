//
//  MMKeyboardButton.m
//  MMNumberKeyboard
//
//  Created by Matías Martínez on 2/12/18.
//  Copyright © 2018 Matías Martínez. All rights reserved.
//

#import "MMKeyboardButton.h"

@interface MMKeyboardButton ()

@property (strong, nonatomic) NSTimer *continuousPressTimer;
@property (assign, nonatomic) NSTimeInterval continuousPressTimeInterval;

@property (strong, nonatomic) UIColor *fillColor;
@property (strong, nonatomic) UIColor *highlightedFillColor;
@property (strong, nonatomic) UIColor *disabledFillColor;

@property (strong, nonatomic) UIColor *controlColor;
@property (strong, nonatomic) UIColor *highlightedControlColor;
@property (strong, nonatomic) UIColor *disabledControlColor;

@end

@implementation MMKeyboardButton

+ (instancetype)keyboardButtonWithStyle:(MMNumberKeyboardButtonStyle)style
{
    MMKeyboardButton *button = [self buttonWithType:UIButtonTypeCustom];
    button.style = style;
    
    return button;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _buttonStyleDidChange];
    }
    return self;
}

- (void)setStyle:(MMNumberKeyboardButtonStyle)style
{
    if (style != _style) {
        _style = style;
        
        [self _buttonStyleDidChange];
    }
}

- (void)_buttonStyleDidChange
{
    const UIUserInterfaceIdiom interfaceIdiom = UI_USER_INTERFACE_IDIOM();
    const MMNumberKeyboardButtonStyle style = self.style;
    
    UIColor *fillColor = nil;
    UIColor *highlightedFillColor = nil;
    if (style == MMNumberKeyboardButtonStyleWhite) {
        fillColor = [UIColor whiteColor];
        highlightedFillColor = [UIColor colorWithRed:0.82f green:0.837f blue:0.863f alpha:1];
    } else if (style == MMNumberKeyboardButtonStyleGray) {
        if (interfaceIdiom == UIUserInterfaceIdiomPad) {
            fillColor =  [UIColor colorWithRed:0.674f green:0.7f blue:0.744f alpha:1];
        } else {
            fillColor = [UIColor colorWithRed:0.81f green:0.837f blue:0.86f alpha:1];
        }
        highlightedFillColor = [UIColor whiteColor];
    } else if (style == MMNumberKeyboardButtonStyleDone) {
        fillColor = [UIColor colorWithRed:0 green:0.479f blue:1 alpha:1];
        highlightedFillColor = [UIColor whiteColor];
    }
    
    UIColor *controlColor = nil;
    UIColor *highlightedControlColor = nil;
    if (style == MMNumberKeyboardButtonStyleDone) {
        controlColor = [UIColor whiteColor];
        highlightedControlColor = [UIColor blackColor];
    } else {
        controlColor = [UIColor blackColor];
        highlightedControlColor = [UIColor blackColor];
    }
    
    UIColor *disabledFillColor = [UIColor colorWithRed:0.678f green:0.701f blue:0.735f alpha:1];
    UIColor *disabledControlColor = [UIColor colorWithRed:0.458f green:0.478f blue:0.499f alpha:1];
    
    [self setTitleColor:controlColor forState:UIControlStateNormal];
    [self setTitleColor:highlightedControlColor forState:UIControlStateSelected];
    [self setTitleColor:highlightedControlColor forState:UIControlStateHighlighted];
    [self setTitleColor:disabledControlColor forState:UIControlStateDisabled];
    
    self.fillColor = fillColor;
    self.highlightedFillColor = highlightedFillColor;
    self.controlColor = controlColor;
    self.highlightedControlColor = highlightedControlColor;
    self.disabledFillColor = disabledFillColor;
    
    [self _updateButtonAppearance];
}

- (void)willMoveToWindow:(UIWindow *)newWindow
{
    [super willMoveToWindow:newWindow];
    
    if (newWindow) {
        [self _updateButtonAppearance];
    }
}

- (void)_updateButtonAppearance
{
    if (!self.isEnabled) {
        self.backgroundColor = self.disabledFillColor;
        self.imageView.tintColor = self.disabledControlColor;
    } else {
        if (self.isHighlighted || self.isSelected) {
            self.backgroundColor = self.highlightedFillColor;
            self.imageView.tintColor = self.controlColor;
        } else {
            self.backgroundColor = self.fillColor;
            self.imageView.tintColor = self.highlightedControlColor;
        }
    }
}

- (void)setEnabled:(BOOL)enabled
{
    [super setEnabled:enabled];
    
    [self _updateButtonAppearance];
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    
    [self _updateButtonAppearance];
}

- (void)setUsesRoundedCorners:(BOOL)usesRoundedCorners
{
    if (usesRoundedCorners != _usesRoundedCorners) {
        _usesRoundedCorners = usesRoundedCorners;
        
        static const CGFloat radius = 4.0f;
        
        CALayer *buttonLayer = [self layer];
        buttonLayer.cornerRadius = (usesRoundedCorners) ? radius : 0.0f;
        buttonLayer.shadowOpacity = (usesRoundedCorners) ? 1.0f : 0.0f;
        buttonLayer.shadowColor = [UIColor colorWithRed:0.533f green:0.541f blue:0.556f alpha:1].CGColor;
        buttonLayer.shadowOffset = CGSizeMake(0, 1.0f);
        buttonLayer.shadowRadius = 0.0f;
    }
}

#pragma mark - Continuous press.

- (void)addTarget:(id)target action:(SEL)action forContinuousPressWithTimeInterval:(NSTimeInterval)timeInterval
{
    self.continuousPressTimeInterval = timeInterval;
    
    [self addTarget:target action:action forControlEvents:UIControlEventValueChanged];
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    BOOL begins = [super beginTrackingWithTouch:touch withEvent:event];
    const NSTimeInterval continuousPressTimeInterval = self.continuousPressTimeInterval;
    
    if (begins && continuousPressTimeInterval > 0) {
        [self _beginContinuousPressDelayed];
    }
    
    return begins;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    [super endTrackingWithTouch:touch withEvent:event];
    [self _cancelContinousPressIfNeeded];
}

- (void)dealloc
{
    [self _cancelContinousPressIfNeeded];
}

- (void)_beginContinuousPress
{
    const NSTimeInterval continuousPressTimeInterval = self.continuousPressTimeInterval;
    
    if (!self.isTracking || continuousPressTimeInterval == 0) {
        return;
    }
    
    self.continuousPressTimer = [NSTimer scheduledTimerWithTimeInterval:continuousPressTimeInterval target:self selector:@selector(_handleContinuousPressTimer:) userInfo:nil repeats:YES];
}

- (void)_handleContinuousPressTimer:(NSTimer *)timer
{
    if (!self.isTracking) {
        [self _cancelContinousPressIfNeeded];
        return;
    }
    
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)_beginContinuousPressDelayed
{
    [self performSelector:@selector(_beginContinuousPress) withObject:nil afterDelay:self.continuousPressTimeInterval * 2.0f];
}

- (void)_cancelContinousPressIfNeeded
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_beginContinuousPress) object:nil];
    
    NSTimer *timer = self.continuousPressTimer;
    if (timer) {
        [timer invalidate];
        
        self.continuousPressTimer = nil;
    }
}

@end
