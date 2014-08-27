//
//  FullScreenImageViewController.h
//  FtcTask
//
//  Created by OsamaMac on 8/27/14.
//  Copyright (c) 2014 Osama Rabie. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FullScreenImageViewController : UIViewController
{
    NSBundle* bundle;
    UIButton *button;
    UIImageView* imageView;
    UIPinchGestureRecognizer* pinch;
    UITapGestureRecognizer* tap;
}


@property(nonatomic,strong)UIImage* imageChosenByUser;

@end
