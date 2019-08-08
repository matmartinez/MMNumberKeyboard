//
//  MMKeyboardTheme.h
//  MMNumberKeyboard
//
//  Created by Matías Martínez on 8/7/19.
//  Copyright © 2019 Matías Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMNumberKeyboard.h"

NS_ASSUME_NONNULL_BEGIN

/**
*  A theme object used internally by @c MMNumberKeyboard that defines the color theme for the keyboard.
*/
@interface MMKeyboardTheme : NSObject

/**
 *  Returns an appropiate theme for the specified keyboard button style.
 *
 *  @param style          The style of the button that determines the theme.
 *
 *  @returns An initialized theme object.
 */
+ (instancetype)themeForStyle:(MMNumberKeyboardButtonStyle)style;

/**
 *  The fill color for the buttons.
 */
@property (readonly, nonatomic) UIColor *fillColor;

/**
 *  The fill color for the buttons on their highlighted state.
 */
@property (readonly, nonatomic) UIColor *highlightedFillColor;

/**
 *  The foreground color for text and other elements.
 */
@property (readonly, nonatomic) UIColor *controlColor;

/**
 *  The foreground color for text and other elements on their highlighted state.
 */
@property (readonly, nonatomic) UIColor *highlightedControlColor;

/**
 *  The fill color for the buttons on their disabled state.
 */
@property (readonly, nonatomic) UIColor *disabledFillColor;

/**
 *  The foreground color for text and other elements on their disabled state.
 */
@property (readonly, nonatomic) UIColor *disabledControlColor;

/**
 *  The shadow color of the buttons.
 */
@property (readonly, nonatomic) UIColor *shadowColor;

@end

NS_ASSUME_NONNULL_END
