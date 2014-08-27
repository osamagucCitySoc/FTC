//
//  MasterViewController.h
//  FtcTask
// This class will be responsible for showing the photos in different layouts.
//  Created by OsamaMac on 8/27/14.
//  Copyright (c) 2014 Osama Rabie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "Constants.h"
#import "Photo.h"
#import <CoreText/CoreText.h>

@interface MasterViewController : UIViewController <NSFetchedResultsControllerDelegate,UITableViewDataSource,UITableViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
{
    UITableView* tableView; // to be used when showing in the table layout.
    UICollectionView* collectionView; // to be used when showing in the collection layout.
    BOOL firstLoad; // to be used to tell if this is the first load when the app started, this means we will be using [reloadData] in this case, otherwise will be updating using [beginUpdates]/[endUpdates]
    NSMutableArray *dataSource; // to be used to hold the flickr response
    UIBarButtonItem* changeLayoutButton; // to be used to change between table and collection
    UIRefreshControl* refreshControl;
    NSDate* lastTimeRefreshed;// to be used when a pull-to-refresh happens, this will make us only load from flickr all image posted after our last update, this is to eliminate loading redundant data
}

@property (nonatomic, strong)NSCache *_imageCache; // this is to store the images as a cached version
@property (nonatomic, strong) NSOperationQueue *queue; // this is to handle queuing requests to load images
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
