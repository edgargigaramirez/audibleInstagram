//
//  ViewController.h
//  InstaAudible
//
//  Created by Edgar Ramirez on 12/13/14.
//  Copyright (c) 2014 Edgar Ramirez. All rights reserved.
//

@import UIKit;

@interface ViewController : UICollectionViewController
@property (strong, nonatomic) NSArray *images;
@property NSUInteger imagesToBeLoadedCount;

-(IBAction)refreshContent:(id)sender;

@end

