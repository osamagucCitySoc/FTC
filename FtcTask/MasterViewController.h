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
#import "OLGhostAlertView.h"

@interface MasterViewController : UIViewController <NSFetchedResultsControllerDelegate,UITableViewDataSource,UITableViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
{
    UITableView* tableView; // to be used when showing in the table layout.
    UICollectionView* collectionView; // to be used when showing in the collection layout.
    BOOL firstLoad; // to be used to tell if this is the first load when the app started, this means we will be using [reloadData] in this case, otherwise will be updating using [beginUpdates]/[endUpdates]
    NSMutableArray *dataSource; // to be used to hold the flickr response
    UIBarButtonItem* changeLayoutButton; // to be used to change between table and collection
    UIBarButtonItem* settingsButton; // to be used to show settings page
    UIRefreshControl* refreshControl;
    NSDate* lastTimeRefreshed;// to be used when a pull-to-refresh happens, this will make us only load from flickr all image posted after our last update, this is to eliminate loading redundant data
    dispatch_queue_t backgroundQueuePicOperations; // to be used as a backgroud thread to do all processing functions on image (drawing title, resizing, face etc etc)
    int currentChanges; // to be used to limit the simultenous changes to the UICollectionView when refreshing, as if you do more than 31 at the same time will crashe
    dispatch_queue_t backgroundQueueUICollectionUpdates; // to be used as a backgroud thread to queue the changes because of pull to refresh to the UICollectionView
    
    // those all to be used as a unit. They will be used in the case of loading from flicker and cannot respond till we get a response
    UIView* loaderView;
    UILabel* infoLabel;
    UIActivityIndicatorView* busy;

}

@property (nonatomic, strong)NSCache *_imageCache; // this is to store the images as a cached version
@property (nonatomic, strong) NSOperationQueue *queue; // this is to handle queuing requests to load images
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
