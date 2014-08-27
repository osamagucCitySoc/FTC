//
//  MasterViewController.m
//  FtcTask
//
//  Created by OsamaMac on 8/27/14.
//  Copyright (c) 2014 Osama Rabie. All rights reserved.
//

#import "MasterViewController.h"
#import "Constants.h"
#import "Photo.h"
#import <CoreText/CoreText.h>
#import "OLGhostAlertView.h"
#import "SettingsViewController.h"
#import "FullScreenImageViewController.h"
#import "Reachability.h"

@interface MasterViewController ()
- (void)configureCell:(UIView *)contentView atIndexPath:(NSIndexPath *)indexPath neededSize:(int)neededSize;
@end

@implementation MasterViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // This is to make the UI adjust with the new ios7 action bar. So views will not go below the action bar, but instead will start under it.
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    firstLoad = YES;
    self.queue = [[NSOperationQueue alloc] init];
    self.queue.maxConcurrentOperationCount = 4;
    self._imageCache = [[NSCache alloc]init];
    backgroundQueuePicOperations = dispatch_queue_create("osama.rabie.image.thread", NULL);
    backgroundQueueUICollectionUpdates = dispatch_queue_create("osama.rabie.collectionView.thread", NULL);
    
    changeLayoutButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"List.png"] style:UIBarButtonItemStylePlain target:self action:@selector(changeLayout:)];
    [changeLayoutButton setTag:2];
    self.navigationItem.rightBarButtonItem = changeLayoutButton;
    
    settingsButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"Settings.png"] style:UIBarButtonItemStylePlain target:self action:@selector(showSettings:)];
    self.navigationItem.leftBarButtonItem = settingsButton;
    
    refreshControl = [[UIRefreshControl alloc]init];
    [refreshControl addTarget:self action:@selector(refreshDataFromFlicker) forControlEvents:UIControlEventValueChanged];
    
    [self clearOldPhotos];
    [self initTableView];
    [self initCollectionView];
    [self initLoaderView];
    [self loadAllFromFlicker];
}

#pragma mark UI Init Methods
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

-(void)setLanguage:(NSString *)language {
    
    NSString *path = [[ NSBundle mainBundle ] pathForResource:language ofType:@"lproj" ];
    bundle = [NSBundle bundleWithPath:path];
}

-(NSString *)get:(NSString *)key alter:(NSString *)alternate {
    return [bundle localizedStringForKey:key value:alternate table:nil];
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self setLanguage:[[NSUserDefaults standardUserDefaults]objectForKey:languageSelected]];
    [self setTitle:[self get:@"MAIN_TITLE" alter:@"Welcome.."]];
}


-(void)initLoaderView
{
    float xOffset = self.view.bounds.size.width-200;
    xOffset /=2;
    float yOffset = self.view.bounds.size.height-200;
    yOffset /=2;
    loaderView = [[UIView alloc]initWithFrame:CGRectMake(xOffset, yOffset, 200, 200)];
    [loaderView setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.4]];
    infoLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 5, 180, 155)];
    [infoLabel setTextColor:[UIColor whiteColor]];
    [infoLabel setText:@"Loading From Flickr.. Please Wait"];
    [infoLabel setNumberOfLines:4];
    [loaderView addSubview:infoLabel];
    busy = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [busy setFrame:CGRectMake((200-busy.frame.size.width)/2, 160, busy.frame.size.width, busy.frame.size.height)];
    [busy startAnimating];
    [loaderView addSubview:busy];
}
-(void)changeLayout:(id)sender
{
    if([changeLayoutButton tag] == 1) // we are now on table and need to change to collection
    {
        [changeLayoutButton setImage:[UIImage imageNamed:@"List.png"]];
        [changeLayoutButton setTag:2];
        [refreshControl removeFromSuperview];
        [collectionView addSubview:refreshControl];
        [UIView transitionWithView:self.view
                          duration:1.25
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^
         {
             
             [tableView removeFromSuperview];
             [self.view addSubview:collectionView];
             
         }completion:NULL];
        
    }else if([changeLayoutButton tag] == 2) // we are now on collection and need to change to table
    {
        [changeLayoutButton setImage:[UIImage imageNamed:@"Grid.png"]];
        [changeLayoutButton setTag:1];
        [refreshControl removeFromSuperview];
        [tableView addSubview:refreshControl];
        [UIView transitionWithView:self.view
                          duration:1.25
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^
         {
             
             [collectionView removeFromSuperview];
             [self.view addSubview:tableView];
             
         }completion:NULL];
    }
}

-(void)showSettings:(id)sender
{
    SettingsViewController* settingsVC = [[SettingsViewController alloc]init];
    [self.navigationController pushViewController:settingsVC animated:NO];
}
/**
 This method is for creating and initializing the table view.
 **/
-(void)initTableView
{
    tableView = [[UITableView alloc]initWithFrame:self.view.frame];
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:tableViewCellIdentifier];
    [tableView setDelegate:self];
    [tableView setDataSource:self];
}
/**
 This method is for creating and initializing the collection view.
 **/
-(void)initCollectionView
{
    collectionView = [[UICollectionView alloc]initWithFrame:self.view.frame collectionViewLayout:[[UICollectionViewFlowLayout alloc]init]];
    [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:collectionViewCellIdentifier];
    [collectionView addSubview:refreshControl];
    [collectionView setBackgroundColor:[UIColor whiteColor]];
    [collectionView setDataSource:self];
    [collectionView setDelegate:self];
    [self.view addSubview:collectionView];
}
/**
 This method for drawing an image with color background to be used as a placeholder while loading the image from Flickr
 **/
- (UIImage *)imageWithColor:(CGRect)rect
{
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    
    CGContextSetFillColorWithColor(context, [[UIColor orangeColor] CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}
/**
 This method is used to DRAW a text that will represent the title of the image
 **/
-(UIImage *) drawText:(NSString*) text inImage:(UIImage*)image
{
    UIFont *font = [UIFont boldSystemFontOfSize:15];
    UIGraphicsBeginImageContext(image.size);
    CGRect rect = CGRectMake(0,0,image.size.width, image.size.height);
    [image drawInRect:rect];
    
    NSDictionary *attrsDictionary =
    
    [NSDictionary dictionaryWithObjectsAndKeys:
     font, NSFontAttributeName,
     [NSNumber numberWithFloat:1.0], NSBaselineOffsetAttributeName,[UIColor greenColor],NSForegroundColorAttributeName, nil];
    [text drawInRect:rect withAttributes:attrsDictionary];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Collection View
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
    
}
- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView
{
    return [[self.fetchedResultsController sections] count];
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:collectionViewCellIdentifier forIndexPath:indexPath];
    [self configureCell:cell.contentView atIndexPath:indexPath neededSize:100];
    return cell;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize retval =  CGSizeMake(100, 100);
    retval.height += 5; retval.width += 5; return retval;
}

// 3
- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(10, 10, 10, 10);
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObject *photoDict = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSString* imageKey = [NSString stringWithFormat:@"%@_%@",[[photoDict valueForKey:@"id"] description],[[photoDict valueForKey:@"secret"] description]];
    UIImage *image = [UIImage imageWithData:[self._imageCache objectForKey:imageKey]];
    if (image)
    {
        FullScreenImageViewController* fullScreenVC = [[FullScreenImageViewController alloc]init];
        [fullScreenVC setImageChosenByUser:image];
        [self.navigationController pushViewController:fullScreenVC animated:NO];
    }else
    {
        OLGhostAlertView* alert = [[OLGhostAlertView alloc]initWithTitle:[self get:@"SORRY_TITLE" alter:@"Sorry.."] message:[self get:@"SORRY_MESSAGE" alter:@"Please wait till the image is loaded"] timeout:3 dismissible:YES];
        [alert show];
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableVieww cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tableViewCellIdentifier forIndexPath:indexPath];
    [self configureCell:cell.contentView atIndexPath:indexPath neededSize:300];
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    /*if ([[segue identifier] isEqualToString:@"showDetail"]) {
     NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
     NSManagedObject *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
     [[segue destinationViewController] setDetailItem:object];
     }*/
}

#pragma mark - Fetched results controller
/**
 This method to remove all previously stored data
 **/
-(void)clearOldPhotos
{
    NSManagedObjectContext * context = [self managedObjectContext];
    NSFetchRequest * fetch = [[NSFetchRequest alloc] init];
    [fetch setEntity:[NSEntityDescription entityForName:@"Photo" inManagedObjectContext:context]];
    NSArray * result = [context executeFetchRequest:fetch error:nil];
    for (id photo in result)
        [context deleteObject:photo];
    
}
- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Photo" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:20];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"id" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"DBCache"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
	    //NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return _fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    if(!firstLoad)
    {
        [tableView beginUpdates];
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    if(!firstLoad)
    {
        if(type == NSFetchedResultsChangeInsert) {
            [tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            [collectionView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]];
        }else if(type == NSFetchedResultsChangeDelete)
        {
            [tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            [collectionView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]];
        }
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableVieww = tableView;
    UICollectionView* collectionVieww = collectionView;
    //NSLog(@"%@",@"YES");
    if(!firstLoad)
    {
        if(type == NSFetchedResultsChangeInsert) {
            [tableVieww insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            
            [collectionVieww insertItemsAtIndexPaths:@[newIndexPath]];
            
        }else if(type == NSFetchedResultsChangeDelete)
        {
            [tableVieww deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [collectionVieww deleteItemsAtIndexPaths:@[indexPath]];
            
        }else if(type == NSFetchedResultsChangeUpdate)
        {
            [self configureCell:[tableVieww cellForRowAtIndexPath:indexPath].contentView atIndexPath:indexPath neededSize:300];
            [self configureCell:[collectionVieww cellForItemAtIndexPath:indexPath].contentView atIndexPath:indexPath neededSize:100];
        }else if(type ==  NSFetchedResultsChangeMove)
        {
            [tableVieww deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableVieww insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            [collectionVieww deleteItemsAtIndexPaths:@[indexPath]];
            [collectionVieww insertItemsAtIndexPaths:@[newIndexPath]];
        }
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    if(!firstLoad)
    {
        [tableView endUpdates];
    }
}

- (void)insertNewObject:(NSDictionary*)photoDictionary
{
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSEntityDescription *entity = [Photo entityInManagedObjectContext:context];
    
    Photo* photo = [[Photo alloc]initWithEntity:entity insertIntoManagedObjectContext:context];
    [photo setTitle:[photoDictionary objectForKey:@"title"]];
    [photo setSecret:[photoDictionary objectForKey:@"secret"]];
    [photo setServer:[photoDictionary objectForKey:@"server"]];
    [photo setFarm:[photoDictionary objectForKey:@"farm"]];
    [photo setOwner:[photoDictionary objectForKey:@"owner"]];
    [photo setId:[photoDictionary objectForKey:@"id"]];
    [photo setIsfamily:[photoDictionary objectForKey:@"isfamily"]];
    [photo setIspublic:[photoDictionary objectForKey:@"ispublic"]];
    [photo setIsfriend:[photoDictionary objectForKey:@"isfriend"]];
    
    // Save the context.
    NSError *error = nil;
    if (![context save:&error]) {
        //NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}


/*
 // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
 {
 // In the simplest, most efficient, case, reload the table view.
 [self.tableView reloadData];
 }
 */

- (void)configureCell:(UIView* )contentView atIndexPath:(NSIndexPath *)indexPath neededSize:(int)neededSize
{
    NSManagedObject *photoDict = [self.fetchedResultsController objectAtIndexPath:indexPath];
    //    cell.textLabel.text = [[object valueForKey:@"title"] description];
    
    NSString* imageKey = [NSString stringWithFormat:@"%@_%@",[[photoDict valueForKey:@"id"] description],[[photoDict valueForKey:@"secret"] description]];
    UIImage *image = [UIImage imageWithData:[self._imageCache objectForKey:imageKey]];
    // this is to center the image in the cell
    float xOffset = contentView.bounds.size.width-neededSize;
    xOffset = xOffset/2;
    UIImageView* imageView = [[UIImageView alloc]initWithFrame:CGRectMake(xOffset, 25, neededSize, neededSize)];
    [imageView setImage:[self imageWithColor:CGRectMake(0.0f, 0.0f, neededSize, neededSize)]];
    [imageView setTag:2];
    [[contentView viewWithTag:2]removeFromSuperview];
    [contentView addSubview:imageView];
    if (image)
    {
        //NSLog(@"%@",@"FROM CACHE");
        //[imageView setFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
        [imageView setImage:[self drawText:[[photoDict valueForKey:@"title"] description] inImage:image]];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [imageView setNeedsDisplay];
        dispatch_async(backgroundQueuePicOperations, ^(void) {
            [self startForFaceDetectionForImage:image imageView:imageView];
        });
        
    }else
    {
        [self.queue addOperationWithBlock:^{
            
            // get the UIImage
            NSString* urlString = [NSString stringWithFormat:@"https://farm%@.staticflickr.com/%@/%@_m.jpg",[[photoDict valueForKey:@"farm"] description],[[photoDict valueForKey:@"server"] description],imageKey];
            
            NSData *downloadedImageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]];
            
            UIImage *image = [UIImage imageWithData:downloadedImageData];
            
            if (image)
            {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    //NSLog(@"%@",@"GOT IT FROM FLICKR");
                    [self._imageCache setObject:downloadedImageData forKey:imageKey];
                    // [imageView setFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
                    [imageView setImage:[self drawText:[[photoDict valueForKey:@"title"] description] inImage:image]];
                    imageView.contentMode = UIViewContentModeScaleAspectFit;
                    [imageView setNeedsDisplay];
                    dispatch_async(backgroundQueuePicOperations, ^(void) {
                        [self startForFaceDetectionForImage:image imageView:imageView];
                    });
                }];
            }
        }];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 350.0f;
}

/**
 This method will check when the user clicks on an image in the table view.
 This will go to the full screen only if the image is loaded and cached.
 If not will tell the user to wait a bit and click again.
 **/
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObject *photoDict = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSString* imageKey = [NSString stringWithFormat:@"%@_%@",[[photoDict valueForKey:@"id"] description],[[photoDict valueForKey:@"secret"] description]];
    UIImage *image = [UIImage imageWithData:[self._imageCache objectForKey:imageKey]];
    if (image)
    {
        FullScreenImageViewController* fullScreenVC = [[FullScreenImageViewController alloc]init];
        [fullScreenVC setImageChosenByUser:image];
        [self.navigationController pushViewController:fullScreenVC animated:NO];
    }else
    {
        OLGhostAlertView* alert = [[OLGhostAlertView alloc]initWithTitle:@"Sorry" message:@"Please wait till the image is loaded" timeout:3 dismissible:YES];
        [alert show];
    }
}



#pragma flicker methods
/**
 This method loads the images from flickr and stores them in the db then initiate a reloadData action.
 **/
-(void)loadAllFromFlicker
{
    if(![self connectedToNetwork])
    {
        [refreshControl endRefreshing];
    }else
    {
        [self.view addSubview:loaderView];
        [self.view setUserInteractionEnabled:NO];
        NSString* urlString =[NSString stringWithFormat:@"%@%@",@"https://api.flickr.com/services/rest/?format=json&method=flickr.photos.search&tags=it&nojsoncallback=1&api_key=",flickrAPI];
        //    to be used when a pull-to-refresh happens, this will make us only load from flickr all image posted after our last update, this is to eliminate loading redundant data
        
        if(!firstLoad)
        {
            urlString = [urlString stringByAppendingFormat:@"%@%f",@"&min_upload_date=",[lastTimeRefreshed timeIntervalSince1970]];
        }
        lastTimeRefreshed = [NSDate date];
        NSURL* url = [NSURL URLWithString:urlString];
        
        NSURLSession *defaultSession = [NSURLSession sharedSession];
        NSURLSessionDataTask * dataTask = [defaultSession dataTaskWithURL:url
                                                        completionHandler:^(NSData *data,    NSURLResponse *response, NSError *error) {
                                                            if(error == nil)
                                                            {
                                                                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                                                    [loaderView removeFromSuperview];
                                                                    [self.view setUserInteractionEnabled:YES];
                                                                    
                                                                    
                                                                    [refreshControl endRefreshing];
                                                                    OLGhostAlertView* alert = [[OLGhostAlertView alloc]initWithTitle:[self get:@"DONE_TITLE" alter:@"Done"] message:[self get:@"DONE_MESSAGE" alter:@"Now Images Will Be Loaded Successively"] timeout:3 dismissible:YES];
                                                                    [alert show];
                                                                }];
                                                                NSError* error2;
                                                                NSDictionary* dict =[NSJSONSerialization
                                                                                     JSONObjectWithData:data
                                                                                     options:kNilOptions
                                                                                     error:&error2];
                                                                NSArray* returnedData = [[dict objectForKey:@"photos"] objectForKey:@"photo"];
                                                                
                                                                if(firstLoad) // then we are first time to get any data so we need to allocate the array
                                                                {
                                                                    dataSource = [[NSMutableArray alloc]initWithArray:returnedData];
                                                                }else // else we need just to add to our current data
                                                                {
                                                                    [dataSource addObjectsFromArray:returnedData];
                                                                }
                                                                currentChanges = 0;
                                                                
                                                                for(NSDictionary* photoDictionary in returnedData)
                                                                {
                                                                    currentChanges++;
                                                                    if(!firstLoad)
                                                                    {
                                                                        [self performSelectorOnMainThread:@selector(syncronizeIt:) withObject:photoDictionary waitUntilDone:YES];
                                                                    }else
                                                                    {
                                                                        [self insertNewObject:photoDictionary];
                                                                    }
                                                                }
                                                                // UI Thread
                                                                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                                                    if(firstLoad){
                                                                        [tableView reloadData];
                                                                        [tableView setNeedsDisplay];
                                                                        [collectionView reloadData];
                                                                        [collectionView setNeedsDisplay];
                                                                        firstLoad = NO;
                                                                    }
                                                                    
                                                                }];
                                                                
                                                            }else
                                                            {
                                                                OLGhostAlertView* alert = [[OLGhostAlertView alloc]initWithTitle:[self get:@"SORRY_TITLE" alter:@"Sorry"] message:[self get:@"ERROR_MESSAGE" alter:@"Error happened from Flickr.."] timeout:3 dismissible:YES];
                                                                [alert show];
                                                            }
                                                            
                                                        }];
        [dataTask resume];
    }
}
-(void)refreshDataFromFlicker
{
    [self loadAllFromFlicker];
}
/**
 This method will be used to syncronize the changes requests to the uicollection view.
 In the case that it is not the first time to load the app (i.e not allowed to use the realodData)
 So it will crashe if the requests passes 31 at the same time. So what we do, is that we group the changes in chunks of 20 changes at a time :)
 **/
-(void)syncronizeIt:(NSDictionary*)dict
{
    float rem = (int)currentChanges%20;
    rem--;
    //rem *= 0.5;
    [self performSelector:@selector(insertNewObject:) withObject:dict afterDelay:rem];
}

#pragma mark FaceDetection
-(void)startForFaceDetectionForImage:(UIImage *)image imageView:(UIImageView*)imageView
{
    CGRect rect = [self displayedImageBounds:imageView];
    UIGraphicsBeginImageContext( rect.size );
    [image drawInRect:rect];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [self detectForFacesInUIImage:scaledImage imageView:imageView];
}
-(void)detectForFacesInUIImage:(UIImage *)facePicture imageView:(UIImageView*)imageView
{
    CIImage* image = [CIImage imageWithCGImage:facePicture.CGImage];
    
    CIDetector* detector = [CIDetector detectorOfType:CIDetectorTypeFace
                                              context:nil options:[NSDictionary dictionaryWithObject:CIDetectorAccuracyLow forKey:CIDetectorAccuracy]];
    
    NSArray* features = [detector featuresInImage:image];
    
    for(CIFaceFeature* faceObject in features)
    {
        CGRect modifiedFaceBounds = faceObject.bounds;
        modifiedFaceBounds.origin.y = facePicture.size.height-faceObject.bounds.size.height-faceObject.bounds.origin.y;
        
        [self addSubViewWithFrame:modifiedFaceBounds imageView:imageView];
        /* This is commented out just due to performance considerations as it is not a fatal requirement in the project. It is just added as a proof of ability and concept.
         if(faceObject.hasLeftEyePosition)
         {
         
         CGRect leftEye = CGRectMake(faceObject.leftEyePosition.x,(facePicture.size.height-faceObject.leftEyePosition.y), 10, 10);
         [self addSubViewWithFrame:leftEye imageView:imageView];
         }
         
         if(faceObject.hasRightEyePosition)
         {
         
         CGRect rightEye = CGRectMake(faceObject.rightEyePosition.x, (facePicture.size.height-faceObject.rightEyePosition.y), 10, 10);
         [self addSubViewWithFrame:rightEye imageView:imageView];
         
         }
         if(faceObject.hasMouthPosition)
         {
         CGRect  mouth = CGRectMake(faceObject.mouthPosition.x,facePicture.size.height-faceObject.mouthPosition.y,10, 10);
         [self addSubViewWithFrame:mouth imageView:imageView];
         }*/
    }
}

-(void)addSubViewWithFrame:(CGRect)frame imageView:(UIImageView*)imageView
{
    UIView* highlitView = [[UIView alloc] initWithFrame:frame];
    highlitView.layer.borderWidth = 1;
    highlitView.layer.borderColor = [[UIColor whiteColor] CGColor];
    
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [imageView addSubview:highlitView];
    });
    
}



- (CGRect)displayedImageBounds:(UIImageView*)imageView {
    UIImage *image = [imageView image];
    if(imageView.contentMode != UIViewContentModeScaleAspectFit || !image)
        return CGRectInfinite;
    
    CGFloat boundsWidth  = [imageView bounds].size.width,
    boundsHeight = [imageView bounds].size.height;
    
    CGSize  imageSize  = [image size];
    CGFloat imageRatio = imageSize.width / imageSize.height;
    CGFloat viewRatio  = boundsWidth / boundsHeight;
    
    if(imageRatio < viewRatio) {
        CGFloat scale = boundsHeight / imageSize.height;
        CGFloat width = scale * imageSize.width;
        CGFloat topLeftX = (boundsWidth - width) * 0.5;
        return CGRectMake(topLeftX, 0, width, boundsHeight);
    }
    
    CGFloat scale = boundsWidth / imageSize.width;
    CGFloat height = scale * imageSize.height;
    CGFloat topLeftY = (boundsHeight - height) * 0.5;
    
    return CGRectMake(0, topLeftY, boundsWidth, height);
}


#pragma mark connection
- (BOOL) connectedToNetwork{
    Reachability* reachability = [Reachability reachabilityWithHostName:@"google.com"];
    NetworkStatus remoteHostStatus = [reachability currentReachabilityStatus];
    
    if(remoteHostStatus == NotReachable)
    {
        return NO;
    }
    else if (remoteHostStatus == ReachableViaWWAN)
    {
        return YES;
    }
    else if (remoteHostStatus == ReachableViaWiFi)
    {
        return YES;
    }
    return NO;
}


@end
