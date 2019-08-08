//
//  UIColor+MMNumberKeyboardAdditions.m
//  MMNumberKeyboard
//
//  Created by Matías Martínez on 8/7/19.
//  Copyright © 2019 Matías Martínez. All rights reserved.
//

#import "UIColor+MMNumberKeyboardAdditions.h"

@implementation UIColor (MMNumberKeyboardAdditions)

- (UIColor *)MM_colorWithDarkColor:(UIColor *)darkColor
{
    NSParameterAssert(darkColor);
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 130000
    if (@available(iOS 13.0, *)) {
        darkColor = [darkColor copy];
        UIColor *lightColor = [self copy];
        
        return [UIColor colorWithDynamicProvider:^UIColor *(UITraitCollection *traitCollection) {
            if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
                return darkColor;
            } else {
                return lightColor;
            }
        }];
    }
#endif
    
    return self;
}

@end
