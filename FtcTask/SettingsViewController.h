//
//  SettingsViewController.h
//  FtcTask
//  This class is to show the settings screen which is able to choose the language from
//  Created by OsamaMac on 8/27/14.
//  Copyright (c) 2014 Osama Rabie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"

@interface SettingsViewController : UIViewController
{
    // to be used to change the language
    UISwitch* englishSwitch;
    UISwitch* germanSwitch;
    NSBundle* bundle;
    UIBarButtonItem* backButton;
}
@end
