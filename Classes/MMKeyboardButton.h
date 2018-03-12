//
//  MMKeyboardButton.h
//  MMNumberKeyboard
//
//  Created by Matías Martínez on 2/12/18.
//  Copyright © 2018 Matías Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMNumberKeyboard.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  The custom button class used on @c MMNumberKeyboard.
 */
@interface MMKeyboardButton : UIButton

/**
 *  Initializes and returns a keyboard button view using the specified style.
 *
 *  An initialized view object or @c nil if the view could not be initialized.
 *
 *  @param style The style to use when altering the appearance of the button. For a list of possible values, see @c MMNumberKeyboardButtonStyle
 *
 *  @returns An initialized view object or @c nil if the view could not be initialized.
 */
+ (instancetype)keyboardButtonWithStyle:(MMNumberKeyboardButtonStyle)style;

/**
 *  The style of the button.
 *
 *  @note The default value of this property is @c MMNumberKeyboardButtonStyleWhite.
 */
@property (assign, nonatomic) MMNumberKeyboardButtonStyle style;

/**
 *  Determines whether the button has a rounded corners or not.
 *
 *  @note The default value of this property is @c NO.
 */
@property (assign, nonatomic) BOOL usesRoundedCorners;

/**
 *  Associates a target object and action method with a continuous press interaction.
 *
 *  @param target       The target object—that is, the object to which the action message is sent.
 *  @param action       A selector identifying an action message. It cannot be NULL.
 *  @param timeInterval The continuous press time interval, in seconds.
 *
 *  @note The @c UIControlEventValueChanged event is sent multiple times as the continuous press is performed.
 */
- (void)addTarget:(id)target action:(SEL)action forContinuousPressWithTimeInterval:(NSTimeInterval)timeInterval;

@end

NS_ASSUME_NONNULL_END
