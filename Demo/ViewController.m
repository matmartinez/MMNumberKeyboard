//
//  ViewController.m
//  MMNumberKeyboard
//
//  Created by Matías Martínez on 12/10/15.
//  Copyright © 2015 Matías Martínez. All rights reserved.
//

#import "ViewController.h"
#import "MMNumberKeyboard.h"

@interface ViewController () <MMNumberKeyboardDelegate>

@property (strong, nonatomic) UITextField *textField;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    // Create and configure the keyboard.
    MMNumberKeyboard *keyboard = [[MMNumberKeyboard alloc] initWithFrame:CGRectZero];
    keyboard.allowsDecimalPoint = YES;
    keyboard.delegate = self;
    
    // Uncomment this line to override the decimal separator character
    // keyboard.decimalCharacter = @"🐼";
    
    // Configure an example UITextField.
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectZero];
    textField.inputView = keyboard;
    textField.text = @(123456789).stringValue;
    textField.placeholder = @"Type something…";
    textField.font = [UIFont systemFontOfSize:24.0f];
    textField.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
    
    self.textField = textField;
    
    [self.view addSubview:textField];
}

#pragma mark - MMNumberKeyboardDelegate.

- (BOOL)numberKeyboardShouldReturn:(MMNumberKeyboard *)numberKeyboard
{
    // Do something with the done key if neeed. Return YES to dismiss the keyboard.
    return YES;
}

#pragma mark - Layout.

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    CGRect bounds = (CGRect){
        .size = self.view.bounds.size
    };
    
    CGRect contentRect = UIEdgeInsetsInsetRect(bounds, (UIEdgeInsets){
        .top = self.topLayoutGuide.length,
        .bottom = self.bottomLayoutGuide.length,
    });
    
    const CGFloat pad = 20.0f;
    
    self.textField.frame = CGRectInset(contentRect, pad, pad);
}

#pragma mark - View events.

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.textField becomeFirstResponder];
}

@end
