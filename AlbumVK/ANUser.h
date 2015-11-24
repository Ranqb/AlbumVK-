//
//  ANUser.h
//  AlbumVK
//
//  Created by Андрей on 22.11.15.
//  Copyright (c) 2015 Андрей. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ANUser : NSObject

@property (strong, nonatomic) NSString* firstName;
@property (strong, nonatomic) NSString* lastName;
@property (strong, nonatomic) NSURL* imageURL;

@property (strong, nonatomic) NSString* userID;
@property (assign, nonatomic) NSString* online;

-(id) initWithServerResponse:(NSDictionary*) responseObject;

@end
