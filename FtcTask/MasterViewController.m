//
//  MasterViewController.m
//  FtcTask
//
//  Created by OsamaMac on 8/27/14.
//  Copyright (c) 2014 Osama Rabie. All rights reserved.
//

#import "MasterViewController.h"

#import "DetailViewController.h"

@interface MasterViewController ()
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
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
    
    self.navigationItem.leftBarButtonItem = self.editButtonItem;

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    self.navigationItem.rightBarButtonItem = addButton;
    
    [self clearOldPhotos];
    [self initTableView];
    [self loadAllFromFlicker];
}

#pragma mark UI Init Methods
/**
 This method is for creating and initializing the table view.
 **/
-(void)initTableView
{
    tableView = [[UITableView alloc]initWithFrame:self.view.frame];
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:tableViewCellIdentifier];
    [tableView setDelegate:self];
    [tableView setDataSource:self];
    [self.view addSubview:tableView];
}
- (UIImage *)imageWithColor
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 200.0f, 200.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    
    CGContextSetFillColorWithColor(context, [[UIColor orangeColor] CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        
        NSError *error = nil;
        if (![context save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }   
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return NO;
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
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Photo" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"id" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"DBCache"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
	     // Replace this implementation with code to handle the error appropriately.
	     // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return _fetchedResultsController;
}    

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    if(!firstLoad)
        [tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    if(!firstLoad)
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableVieww = tableView;
    if(!firstLoad)
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableVieww insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableVieww deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableVieww cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableVieww deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableVieww insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    if(!firstLoad)
    [tableView endUpdates];
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
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
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

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObject *photoDict = [self.fetchedResultsController objectAtIndexPath:indexPath];
    //    cell.textLabel.text = [[object valueForKey:@"title"] description];
    
    NSString* imageKey = [NSString stringWithFormat:@"%@_%@",[[photoDict valueForKey:@"id"] description],[[photoDict valueForKey:@"secret"] description]];
    UIImage *image = [UIImage imageWithData:[self._imageCache objectForKey:imageKey]];
    // this is to center the image in the cell
    float xOffset = cell.contentView.bounds.size.width-200;
    xOffset = xOffset/2;
    UIImageView* imageView = [[UIImageView alloc]initWithFrame:CGRectMake(xOffset, 25, 200, 200)];
    [imageView setImage:[self imageWithColor]];
    [imageView setTag:2];
    [[[cell contentView]viewWithTag:2]removeFromSuperview];
    [[cell contentView]addSubview:imageView];
    if (image)
    {
        NSLog(@"%@",@"FROM CACHE");
        [imageView setImage:image];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [imageView setNeedsDisplay];
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
                    NSLog(@"%@",@"GOT IT FROM FLICKR");
                    [self._imageCache setObject:downloadedImageData forKey:imageKey];
                    [imageView setImage:image];
                    imageView.contentMode = UIViewContentModeScaleAspectFit;
                    [imageView setNeedsDisplay];
                }];
            }
        }];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 250.0f;
}



#pragma flicker methods
/**
 This method loads the images from flickr and stores them in the db then initiate a reloadData action.
 **/
-(void)loadAllFromFlicker
{
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",@"https://api.flickr.com/services/rest/?format=json&sort=date-taken-desc&method=flickr.photos.search&tags=it&nojsoncallback=1&api_key=",flickrAPI]];

    NSURLSession *defaultSession = [NSURLSession sharedSession];
    NSURLSessionDataTask * dataTask = [defaultSession dataTaskWithURL:url
                                                    completionHandler:^(NSData *data,    NSURLResponse *response, NSError *error) {
                                                        if(error == nil)
                                                        {
                                                            NSError* error2;
                                                            NSDictionary* dict =[NSJSONSerialization
                                                                                 JSONObjectWithData:data
                                                                                 options:kNilOptions
                                                                                 error:&error2];
                                                            
                                                            dataSource = [[NSMutableArray alloc]initWithArray:[[dict objectForKey:@"photos"] objectForKey:@"photo"]];
                                                            
                                                            for(NSDictionary* photoDictionary in dataSource)
                                                            {
                                                                [self insertNewObject:photoDictionary];
                                                                
                                                            }
                                                            // UI Thread
                                                            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                                                
                                                                [tableView reloadData];
                                                                [tableView setNeedsDisplay];
                                                                
                                                            }];
                                                           
                                                        }else
                                                        {
#warning add the error here
                                                        }
                                                        
                                                    }];
    [dataTask resume];
}



@end
