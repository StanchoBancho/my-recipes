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

+(UIView*)presentBasicViewWithTitle:(NSString*)title onView:(UIView*)parentView;
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
    
    UILabel *postLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 75, 120, 40)];
    postLabel.textAlignment = UITextAlignmentCenter;
    postLabel.numberOfLines = 0;
    postLabel.textColor = [UIColor whiteColor];
    [postLabel setText:title];
    postLabel.backgroundColor = [UIColor clearColor];
    [postedView addSubview:postLabel];
    
    [parentView addSubview:postedView];
    postedView.center = CGPointMake(parentView.bounds.size.width / 2, parentView.bounds.size.height / 2);
    
    return postedView;
}

+(CustomLoadingView*)presentCustomLoadingViewWithTitle:(NSString*)title onView:(UIView*)parentView
{
    CustomLoadingView *postedView = [[CustomLoadingView alloc] initWithFrame:CGRectMake(0, 0, 180, 120)];
    postedView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.85];
    postedView.layer.cornerRadius = 10.0;
    postedView.clipsToBounds = YES;
    
    UIProgressView* progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
    [progressView setFrame:CGRectMake(0, 0, 140.0, 20.0)];
    [postedView addSubview:progressView];
    [progressView setCenter:CGPointMake(postedView.bounds.size.width / 2, 51)];
    [progressView setProgress:0.0];
    [postedView setProgress:progressView];
    
    UILabel *postLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 65, 120, 40)];
    postLabel.textAlignment = UITextAlignmentCenter;
    postLabel.numberOfLines = 0;
    postLabel.textColor = [UIColor whiteColor];
    [postLabel setText:title];
    postLabel.backgroundColor = [UIColor clearColor];
    [postedView addSubview:postLabel];
    
    [parentView addSubview:postedView];
    postedView.center = CGPointMake(parentView.bounds.size.width / 2, parentView.bounds.size.height / 2);
    
    return postedView;
}

@end
