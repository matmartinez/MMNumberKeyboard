//
//  MMNumberKeyboard.h
//  MMNumberKeyboard
//
//  Created by Matías Martínez on 12/10/15.
//  Copyright © 2015 Matías Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MMNumberKeyboard;

/**
 *  The @c MMNumberKeyboardDelegate protocol defines the messages sent to a delegate object as part of the sequence of editing text. All of the methods of this protocol are optional.
 */
@protocol MMNumberKeyboardDelegate <NSObject>
@optional

/**
 *  Asks whether the specified text should be inserted.
 *
 *  @param numberKeyboard The keyboard instance proposing the text insertion.
 *  @param text           The proposed text to be inserted.
 *
 *  @return Returns	@c YES if the text should be inserted or @c NO if it should not.
 */
- (BOOL)numberKeyboard:(MMNumberKeyboard *)numberKeyboard shouldInsertText:(NSString *)text;

/**
 *  Asks the delegate if the keyboard should process the pressing of the return button.
 *
 *  @param numberKeyboard The keyboard whose return button was pressed.
 *
 *  @return Returns	@c YES if the keyboard should implement its default behavior for the return button; otherwise, @c NO.
 */
- (BOOL)numberKeyboardShouldReturn:(MMNumberKeyboard *)numberKeyboard;

@end

/**
 *  A simple keyboard to use with numbers and, optionally, a decimal point.
 */
@interface MMNumberKeyboard : UIInputView

/**
 *  The receiver key input object. If @c nil the object at top of the responder chain is used.
 */
@property (weak, nonatomic) id <UIKeyInput> keyInput;

/**
 *  Delegate to change text insertion or return key behavior.
 */
@property (weak, nonatomic) id <MMNumberKeyboardDelegate> delegate;

/**
 *  Configures the special key with an image and an action block.
 *
 *  @param image   The image to display in the key.
 *  @param handler A handler block.
 */
- (void)configureSpecialKeyWithImage:(UIImage *)image actionHandler:(dispatch_block_t)handler;

/**
 *  Configures the special key with an image and a target-action.
 *
 *  @param image  The image to display in the key.
 *  @param target The target object—that is, the object to which the action message is sent.
 *  @param action A selector identifying an action message. It cannot be NULL.
 */
- (void)configureSpecialKeyWithImage:(UIImage *)image target:(id)target action:(SEL)action;

/**
 *  If @c YES, the decimal separator key will be displayed.
 *
 *  @note The default value of this property is @c NO.
 */
@property (assign, nonatomic) BOOL allowsDecimalPoint;

@end
