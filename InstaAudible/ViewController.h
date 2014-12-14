//
//  ViewController.h
//  InstaAudible
//
//  Created by Edgar Ramirez on 12/13/14.
//  Copyright (c) 2014 Edgar Ramirez. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIScrollView* gridScrollView;
@property (strong, nonatomic) NSArray* images;
@property (strong, nonatomic) NSMutableArray* thumbnails;


@end

