//
//  Header.h
//  AudibleInsta
//
//  Created by Edgar Ramirez on 12/13/14.
//  Copyright (c) 2014 Edgar Ramirez. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Media : NSObject

@property (nonatomic, strong) NSString* thumbnailUrl;
@property (nonatomic, strong) NSString* standardUrl;
@property (nonatomic, assign) NSUInteger likes;

- (id)initWithAttributes:(NSDictionary *)attributes;

@end
