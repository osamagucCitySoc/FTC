//
//  FullScreenImageViewController.h
//  FtcTask
//
//  Created by OsamaMac on 8/27/14.
//  Copyright (c) 2014 Osama Rabie. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FullScreenImageViewController : UIViewController<UIScrollViewDelegate>
{
    NSBundle* bundle;
    UIBarButtonItem* backButton;
    UIImageView* imageView;
    UIScrollView* scrollView;
    UIPinchGestureRecognizer* pinch;
}


@property(nonatomic,strong)UIImage* imageChosenByUser;

@end
