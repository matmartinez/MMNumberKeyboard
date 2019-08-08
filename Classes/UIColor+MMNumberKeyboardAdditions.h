//
//  UIColor+MMNumberKeyboardAdditions.h
//  MMNumberKeyboard
//
//  Created by Matías Martínez on 8/7/19.
//  Copyright © 2019 Matías Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (MMNumberKeyboardAdditions)

/**
 *  Returns a color object that generates its color data dynamically using the specified dark color, depending if the user interface style is dark.
 *
 *  An initialized view object or @c nil if the view could not be initialized.
 *
 *  @param darkColor The color the receiver generates when the user interface style is dark.
 *
 *  @note This method will just return the receiver if there's no support for dynamic colors.
 *
 *  @returns A color object whose color information is determined by the receiver and specified color.
 */
- (UIColor *)MM_colorWithDarkColor:(UIColor *)darkColor;

@end

NS_ASSUME_NONNULL_END
