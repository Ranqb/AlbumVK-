//
//  ANFriends.h
//  AlbumVK
//
//  Created by Андрей on 22.11.15.
//  Copyright (c) 2015 Андрей. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ANFriends : NSObject

@property (strong, nonatomic) NSString* firstName;
@property (strong, nonatomic) NSString* lastName;
@property (strong, nonatomic) NSURL* imageURL;

@property (strong, nonatomic) NSString* userID;
@property (assign, nonatomic) NSString* onlineFlag;
@property (assign, nonatomic) NSString* onlineMobileFlag;

-(id) initWithServerResponse:(NSDictionary*) responseObject;


@end
