//
//  SettingsViewController.m
//  FtcTask
//
//  Created by OsamaMac on 8/27/14.
//  Copyright (c) 2014 Osama Rabie. All rights reserved.
//

#import "SettingsViewController.h"
#import "Constants.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

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
    
    [self.view setBackgroundColor:[UIColor whiteColor]];

    
    englishSwitch = [[UISwitch alloc]initWithFrame:CGRectMake(250, 20, 40, 40)];
    germanSwitch = [[UISwitch alloc]initWithFrame:CGRectMake(250, 80, 40, 40)];
    
    UILabel* engLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 20, 200, 40)];
    [engLabel setText:@"English"];
    
    UILabel* germanLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 80, 200, 40)];
    [germanLabel setText:@"German"];
    if([[[NSUserDefaults standardUserDefaults] objectForKey:languageSelected] isEqualToString:@"de"])
    {
        [self setLanguage:@"de"];
        [englishSwitch setOn:NO];
        [germanSwitch setOn:YES];
    }else
    {
        [self setLanguage:@"en"];
        [englishSwitch setOn:YES];
        [germanSwitch setOn:NO];
    }
    
    [englishSwitch addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    [germanSwitch addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:englishSwitch];
    [self.view addSubview:germanSwitch];
    [self.view addSubview:engLabel];
    [self.view addSubview:germanLabel];    
    
    backButton = [[UIBarButtonItem alloc]initWithTitle:[self get:@"BACK" alter:@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(backClicked:)];
    self.navigationItem.leftBarButtonItem = backButton;
    
    [self setTitle:[self get:@"SETTINGS_TITLE" alter:@"Settings"]];
    
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}



-(void)backClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:NO];
}
/**
 This method checks for what language did the user selects.
 Moreover, it makes sure that ONE AND ONLY ONE language is being selected.
 **/
-(void)valueChanged:(id)sender
{
    if(![(UISwitch*)sender isOn])
    {
        [(UISwitch*)sender setOn:YES];
    }else
    {
        if(sender == germanSwitch)
        {
            [[NSUserDefaults standardUserDefaults]setObject:@"de" forKey:languageSelected];
            [[NSUserDefaults standardUserDefaults]synchronize];

            [self setLanguage:@"de"];
            [englishSwitch setOn:NO];
            [germanSwitch setOn:YES];
        }else
        {
            [[NSUserDefaults standardUserDefaults]setObject:@"en" forKey:languageSelected];
            [[NSUserDefaults standardUserDefaults]synchronize];
            [self setLanguage:@"en"];
            [englishSwitch setOn:YES];
            [germanSwitch setOn:NO];
        }
        [self setTitle:[self get:@"SETTINGS_TITLE" alter:@"Settings"]];
        [backButton setTitle:[self get:@"BACK" alter:@"Back"]];
    }
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

@end
