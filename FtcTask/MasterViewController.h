//
//  MasterViewController.h
//  FtcTask
//
//  Created by OsamaMac on 8/27/14.
//  Copyright (c) 2014 Osama Rabie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "Constants.h"

@interface MasterViewController : UIViewController <NSFetchedResultsControllerDelegate,UITableViewDataSource,UITableViewDelegate>
{
    UITableView* tableView;
}

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
