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
    
    pinch = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(handlePinch:)];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self setLanguage:[[NSUserDefaults standardUserDefaults] objectForKey:languageSelected]];
    backButton = [[UIBarButtonItem alloc]initWithTitle:[self get:@"BACK" alter:@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(backClicked:)];
    self.navigationItem.leftBarButtonItem = backButton;
    [self setTitle:[self get:@"FULL_TITLE" alter:@"Full Screen.."]];
    
    scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    
    imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    
    [imageView setImage:imageChosenByUser];
    [imageView setContentMode:UIViewContentModeScaleAspectFit];
    [imageView setUserInteractionEnabled:YES];
    [imageView addGestureRecognizer:pinch];
    [self.view addSubview:imageView];
    
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
    }else
    {
        [imageView removeFromSuperview];
        imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        
        [imageView setImage:imageChosenByUser];
        [imageView setUserInteractionEnabled:YES];
        [imageView addGestureRecognizer:pinch];
        [imageView setContentMode:UIViewContentModeScaleAspectFit];
        
        [self.view addSubview:imageView];
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

@end
