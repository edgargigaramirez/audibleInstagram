//
//  ViewController.m
//  InstaAudible
//
//  Created by Edgar Ramirez on 12/13/14.
//  Copyright (c) 2014 Edgar Ramirez. All rights reserved.
//

#import "ViewController.h"
#import "Media.h"

@interface ViewController ()

@end

@implementation ViewController

NSString * const kInstagramBaseURLString = @"https://api.instagram.com/v1/media/popular?client_id=41b73dd596144547a01e5e43aae31c4e";
const NSInteger kthumbnailWidth = 80;
const NSInteger kthumbnailHeight = 80;
const NSInteger kImagesPerRow = 4;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillAppear:(BOOL)animated {
    [self configureView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configureView {
    // Update the user interface for the detail item.
    self.gridScrollView.contentSize = self.view.bounds.size;
    
    self.thumbnails = [[NSMutableArray alloc] init];
    
    [self getUserMediaWithId:nil withAccessToken:nil block:^(NSArray *records) {
        self.images = records;
        [self loadImages];
    }];
}

#pragma mark - custom

- (void) loadImages {
    int item = 0;
    
    for (Media* media in self.images) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
            NSString* thumbnailUrl = media.thumbnailUrl;
            NSData* data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:thumbnailUrl]];
            UIImage* image = [UIImage imageWithData:data];
            NSLog(@"Loading...%@", thumbnailUrl);
            dispatch_async(dispatch_get_main_queue(), ^ {
                UIButton* button = [self.thumbnails objectAtIndex:item];
                [button setImage:image forState:UIControlStateNormal];
            });
        });
        ++item;
    }
}
- (void)buttonAction:(id)sender {
    
}

#pragma mark - Instagram API

- (void)getUserMediaWithId:(NSString*)userId
           withAccessToken:(NSString *)accessToken
                     block:(void (^)(NSArray *records))block
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:kInstagramBaseURLString]];
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
        NSDictionary *res = [NSJSONSerialization JSONObjectWithData:receivedData options:NSJSONReadingMutableLeaves error:&jsonError];
        NSMutableArray *mutableRecords = [NSMutableArray array];
        NSArray* data = [res objectForKey:@"data"];
        for (NSDictionary* obj in data) {
            Media *theMedia = [[Media alloc] initWithAttributes:obj];
            [mutableRecords addObject:theMedia];
        }
        int item = 0, row = 0, col = 0;
        for (NSDictionary* image in mutableRecords) {
            UIButton* button = [[UIButton alloc] initWithFrame:CGRectMake(col*kthumbnailWidth,
                                                                          row*kthumbnailHeight,
                                                                          kthumbnailWidth,
                                                                          kthumbnailHeight)];
            button.tag = item;
            [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
            ++col;++item;
            if (col >= kImagesPerRow) {
                row++;
                col = 0;
            }
            [self.gridScrollView addSubview:button];
            [self.thumbnails addObject:button];
        }
        NSLog(@"Number of photos about to be display...");
        
        if (block) {
            block([NSArray arrayWithArray:mutableRecords]);
        }
    });
    
}

@end
