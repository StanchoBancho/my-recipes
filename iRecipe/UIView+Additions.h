//
//  UIView+Additions.h
//  SpyderMate
//
//  Created by Stanimir Nikolov on 12/10/12.
//
//

#import <UIKit/UIKit.h>
#import "CustomLoadingView.h"

@interface UIView (Additions)

+(CustomLoadingView*)presentCustomLoadingViewWithTitle:(NSString*)title onView:(UIView*)parentView;

+(UIView*)presentBasicViewWithTitle:(NSString*)title onView:(UIView*)parentView;

@end
