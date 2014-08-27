//
//  FullScreenImageViewController.m
//  FtcTask
//
//  Created by OsamaMac on 8/27/14.
//  Copyright (c) 2014 Osama Rabie. All rights reserved.
//

#import "FullScreenImageViewController.h"
#import "Constants.h"
@interface FullScreenImageViewController ()

@end

@implementation FullScreenImageViewController

@synthesize imageChosenByUser;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // This is to make the UI adjust with the new ios7 action bar. So views will not go below the action bar, but instead will start under it.
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }

    [self.navigationItem setHidesBackButton:YES animated:YES];
    
    pinch = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(handlePinch:)];
    tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap:)];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self setLanguage:[[NSUserDefaults standardUserDefaults] objectForKey:languageSelected]];
       

    self.navigationItem.leftBarButtonItem = nil;
    [self setTitle:[self get:@"FULL_TITLE" alter:@"Full Screen.."]];
    
    imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    
    [imageView setImage:imageChosenByUser];
    [imageView setContentMode:UIViewContentModeScaleAspectFit];
    [imageView setUserInteractionEnabled:YES];
    [imageView addGestureRecognizer:pinch];
    [self.view addSubview:imageView];
    button = [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width-64,10,64,64)];
    
    [button setBackgroundImage:[UIImage imageNamed:@"Close.png"]forState:UIControlStateNormal];
    [button addTarget:self action:@selector(backClicked:) forControlEvents:UIControlEventTouchUpInside];
    [button setAlpha:0.0];
    [self.view addSubview:button];
    [self.view addGestureRecognizer:tap];

    
}
-(void)viewWillAppear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(orientationChanged:)    name:UIDeviceOrientationDidChangeNotification  object:nil];
}

- (void)orientationChanged:(NSNotification *)notification{
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    
    if(orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight)
    {
        [imageView removeFromSuperview];
        imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        
        [imageView setImage:imageChosenByUser];
        [imageView setUserInteractionEnabled:YES];
        [imageView addGestureRecognizer:pinch];
        [imageView setContentMode:UIViewContentModeScaleAspectFit];
        
        [self.view addSubview:imageView];
        [self.view bringSubviewToFront:button];
        [button setFrame:CGRectMake(self.view.bounds.size.width-64,10,64,64)];
    }else
    {
        [imageView removeFromSuperview];
        imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        
        [imageView setImage:imageChosenByUser];
        [imageView setUserInteractionEnabled:YES];
        [imageView addGestureRecognizer:pinch];
        [imageView setContentMode:UIViewContentModeScaleAspectFit];
        
        [self.view addSubview:imageView];
        [self.view bringSubviewToFront:button];
        [button setFrame:CGRectMake(self.view.bounds.size.width-64,10,64,64)];
    }

}

- (BOOL)shouldAutorotate {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setLanguage:(NSString *)language {
    
    NSString *path = [[ NSBundle mainBundle ] pathForResource:language ofType:@"lproj" ];
    bundle = [NSBundle bundleWithPath:path];
}

-(NSString *)get:(NSString *)key alter:(NSString *)alternate {
    return [bundle localizedStringForKey:key value:alternate table:nil];
}

-(void)backClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:NO];
}


- (void)handlePinch:(UIPinchGestureRecognizer *)recognizer {
    recognizer.view.transform = CGAffineTransformScale(recognizer.view.transform, recognizer.scale, recognizer.scale);
    recognizer.scale = 1;
}

- (void)handleTap:(UITapGestureRecognizer *)recognizer {
    [button setAlpha:(1-button.alpha)];
}

@end
