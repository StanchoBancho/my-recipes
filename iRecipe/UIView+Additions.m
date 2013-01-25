//
//  UIView+Additions.m
//  SpyderMate
//
//  Created by Stanimir Nikolov on 12/10/12.
//
//

#import "UIView+Additions.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIView (Additions)

+(UIView*)presentPositiveNotifyingViewWithTitle:(NSString*)title onView:(UIView*)parentView
{
    UIView *postedView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 120, 120)];
    postedView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.85];
    postedView.layer.cornerRadius = 10.0;
    postedView.clipsToBounds = YES;
    
    UIActivityIndicatorView* activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [activity setFrame:CGRectMake(0, 0, 36.0, 36.0)];
    [postedView addSubview:activity];
    [activity setCenter:CGPointMake(postedView.bounds.size.width / 2, 51)];
    [activity startAnimating];
//    UIImageView *checkMark = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"OnlySpyder"]];
//    [postedView addSubview:checkMark];
//    [checkMark setFrame:CGRectMake(0, 0, 73.0, 42.0)];
//    checkMark.center = CGPointMake(postedView.bounds.size.width / 2, 30);
    
    UILabel *postLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 80, 120, 40)];
    postLabel.textAlignment = UITextAlignmentCenter;
    postLabel.numberOfLines = 0;
    postLabel.textColor = [UIColor whiteColor];
    [postLabel setText:title];
    postLabel.backgroundColor = [UIColor clearColor];
    [postedView addSubview:postLabel];
    
    [parentView addSubview:postedView];
    postedView.center = CGPointMake(parentView.bounds.size.width / 2, parentView.bounds.size.height / 2);
    
    [UIView animateWithDuration:0.25 delay:2.0 options:UIViewAnimationCurveLinear animations:^{
        [postedView setAlpha:0];
        postedView.transform = CGAffineTransformScale(postedView.transform, 1.10, 1.10);
    }completion:^(BOOL finished){
        if (finished) {
            [postedView removeFromSuperview];
        }
    }];
    return postedView;
}

@end
