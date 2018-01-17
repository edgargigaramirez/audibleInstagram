//
//  ViewController.m
//  InstaAudible
//
//  Created by Edgar Ramirez on 12/13/14.
//  Copyright (c) 2014 Edgar Ramirez. All rights reserved.
//

#import "ViewController.h"
#import "Media.h"
#import "UICollectionViewCustomCell.h"
#import "FullscreenViewController.h"

#import "AFCollectionViewFlowLargeLayout.h"
#import "AFCollectionViewFlowSmallLayout.h"

@interface ViewController ()
@property CGRect previousPreheatRect;

@property (nonatomic, strong) AFCollectionViewFlowLargeLayout *largeLayout;
@property (nonatomic, strong) AFCollectionViewFlowSmallLayout *smallLayout;
@end

@implementation ViewController

static NSString * const CellReuseIdentifier = @"Cell";

NSString * const client_id = @"client_id=41b73dd596144547a01e5e43aae31c4e";
NSString * const kInstagramBaseURLString = @"https://api.instagram.com/v1/media/popular?%@&count=100";
NSString * const kInstagramBaseUrlStringForUser = @"https://api.instagram.com/v1/users/25025320/media/recent/?%@&count=100";
NSString * const kInstagramBaseUrlStringForTag = @"https://api.instagram.com/v1/tags/%@/media/recent/?%@&count=100";

NSString * const TAG_SELFIE = @"selfie";
bool JSON_IS_READY = NO;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.smallLayout = [[AFCollectionViewFlowSmallLayout alloc] init];
    self.largeLayout = [[AFCollectionViewFlowLargeLayout alloc] init];
    
    [self.collectionView setCollectionViewLayout:self.smallLayout animated:YES];
    
    self.title = [NSString stringWithFormat:@"#%@", TAG_SELFIE];
    // Do any additional setup after loading the view, typically from a nib.
        
    [self refreshContent:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger count = JSON_IS_READY ? self.images.count : self.imagesToBeLoadedCount;
    
    NSLog(@"Refresing the collection view.. %ld", (long)count);
    
    return count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCustomCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellReuseIdentifier forIndexPath:indexPath];
    
    // Increment the cell's tag
    NSInteger currentTag = cell.tag + 1;
    cell.tag = currentTag;
    
    if (JSON_IS_READY) {
        Media *media = self.images[indexPath.item];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
            NSString* thumbnailUrl = media.thumbnailUrl;
            NSData* data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:thumbnailUrl]];
            UIImage* image = [UIImage imageWithData:data];
//            NSLog(@"Loading...%@", thumbnailUrl);
            dispatch_async(dispatch_get_main_queue(), ^ {
                NSLog(@"Loading...%@ - END", thumbnailUrl);
                // Only update the thumbnail if the cell tag hasn't changed. Otherwise, the cell has been re-used.
                if (cell.tag == currentTag) {
                    [cell setImage:image];
                }
            });
        });
    } else {
        // Only update the thumbnail if the cell tag hasn't changed. Otherwise, the cell has been re-used.
        if (cell.tag == currentTag) {
            NSString* thumbnailUrl = @"Slate.png";
            UIImage* image = [UIImage imageNamed:thumbnailUrl];
            [cell setImage:image];
        }
    }
    
    return cell;
}

#pragma mark - Prepare for Segue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UICollectionViewCell *cell = (UICollectionViewCell *)sender;
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    
    FullscreenViewController *imageDetailViewController = (FullscreenViewController *)segue.destinationViewController;
    imageDetailViewController.imageName = ((Media*)[self.images objectAtIndex:indexPath.row]).standardUrl;
}

#pragma mark - Instagram API

- (void)getUserMediaWithId:(NSString*)userId
           withAccessToken:(NSString *)accessToken
                     block:(void (^)(NSArray *records))block
{
    NSString *endPointString = [NSString stringWithFormat:kInstagramBaseUrlStringForTag, TAG_SELFIE, client_id];
    NSLog(@"Fetching %@", endPointString);

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:endPointString]];
    [request setHTTPMethod:@"GET"];
    NSString *contentType = [NSString stringWithFormat:@"application/json"];
    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
    [request addValue:@"application/json" forHTTPHeaderField: @"Accept"];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        NSURLResponse *response = nil;
        NSError *error = nil;
        NSData *receivedData = [NSURLConnection sendSynchronousRequest:request
                                                     returningResponse:&response
                                                                 error:&error];
        NSError *jsonError = nil;
        
        if (error == nil && jsonError == nil) {
            NSDictionary *res = [NSJSONSerialization JSONObjectWithData:receivedData options:NSJSONReadingMutableLeaves error:&jsonError];
            NSMutableArray *mutableRecords = [NSMutableArray array];
            NSArray* data = [res objectForKey:@"data"];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                //tasks on main thread
                // tell the collection view to render the placeholders
                self.imagesToBeLoadedCount = (unsigned long)data.count;
                NSLog(@"Number of placeholders to show: %lu", self.imagesToBeLoadedCount);
                [self.collectionView reloadData];
            });
            
            for (NSDictionary* obj in data) {
                Media *theMedia = [[Media alloc] initWithAttributes:obj];
                [mutableRecords addObject:theMedia];
            }
            
            JSON_IS_READY = (mutableRecords.count > 0);
            NSLog(@"Number of photos fetch: %lu", mutableRecords.count);
            
            if (block) {
                block([NSArray arrayWithArray:mutableRecords]);
            }
        } else
        {
            NSLog(@"An error has occurred.");
            
        }
    });
    
}

# pragma mark - custom
-(IBAction)refreshContent:(id)sender {
    [self getUserMediaWithId:nil withAccessToken:nil block:^(NSArray *records) {
        self.images = records;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];
        });
    }];
}

-(IBAction)toggleTileSizes:(id)sender {
    if (self.collectionView.collectionViewLayout == self.smallLayout)
    {
        [self.largeLayout invalidateLayout];
        [self.collectionView setCollectionViewLayout:self.largeLayout animated:YES];
    }
    else
    {
        [self.smallLayout invalidateLayout];
        [self.collectionView setCollectionViewLayout:self.smallLayout animated:YES];
    }
}

@end
