//
//  FullscreenViewController.m
//  InstaAudible
//
//  Created by Edgar Ramirez on 12/14/14.
//  Copyright (c) 2014 Edgar Ramirez. All rights reserved.
//

#import "FullscreenViewController.h"

@implementation FullscreenViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    UIImageView *fullScreenImageView = [[UIImageView alloc] initWithFrame:CGRectInset(CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetWidth(self.view.frame)), 5, 5)];
    fullScreenImageView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:fullScreenImageView];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
        NSString* thumbnailUrl = self.imageName;
        NSData* data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:thumbnailUrl]];
        UIImage* image = [UIImage imageWithData:data];
//        NSLog(@"Loading...%@", thumbnailUrl);
        dispatch_async(dispatch_get_main_queue(), ^ {
//            NSLog(@"Loading...%@ - END", thumbnailUrl);
            fullScreenImageView.image = image;
        });
    });
}

@end
