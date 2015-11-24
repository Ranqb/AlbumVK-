//
//  ANUser.m
//  AlbumVK
//
//  Created by Андрей on 22.11.15.
//  Copyright (c) 2015 Андрей. All rights reserved.
//

#import "ANUser.h"

@implementation ANUser

- (instancetype)initWithServerResponse:(NSDictionary*) responseObject{
    self = [super init];
    if (self) {
        
        self.firstName = [responseObject objectForKey:@"first_name"];
        self.lastName = [responseObject objectForKey:@"last_name"];
        self.userID = [responseObject objectForKey:@"id"];
        self.online = [responseObject objectForKey:@"online"];        
        NSString* urlString = [responseObject objectForKey:@"photo_100"];
        if (urlString) {
            self.imageURL = [NSURL URLWithString:urlString];
        }
        
    }
    return self;
}

@end
