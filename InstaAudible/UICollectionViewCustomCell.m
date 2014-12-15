//
//  UICollectionViewCustomCell.m
//  InstaAudible
//
//  Created by Edgar Ramirez on 12/14/14.
//  Copyright (c) 2014 Edgar Ramirez. All rights reserved.
//

#import "UICollectionViewCustomCell.h"


@interface UICollectionViewCustomCell ()
@property (strong) IBOutlet UIImageView *imageView;
@end

@implementation UICollectionViewCustomCell

-(void)prepareForReuse
{
    [self setImage:nil];
}

-(void)setImage:(UIImage *)image
{
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectInset(CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)), 5, 5)];
    self.imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;[self.contentView addSubview:self.imageView];
    self.contentView.translatesAutoresizingMaskIntoConstraints = YES;
    self.backgroundColor = [UIColor whiteColor];
    
    self.imageView.image = image;
}

@end