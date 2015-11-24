//
//  ANFriends.m
//  AlbumVK
//
//  Created by Андрей on 22.11.15.
//  Copyright (c) 2015 Андрей. All rights reserved.
//

#import "ANFriends.h"

@implementation ANFriends

- (instancetype)initWithServerResponse:(NSDictionary*) responseObject{
    self = [super init];
    if (self) {
        
        self.firstName = [responseObject objectForKey:@"first_name"];
        self.lastName = [responseObject objectForKey:@"last_name"];
        self.userID = [responseObject objectForKey:@"user_id"];
        self.onlineFlag = [responseObject objectForKey:@"online"];
        self.onlineMobileFlag = [responseObject objectForKey:@"online_mobile"];
        
        NSString* urlString = [responseObject objectForKey:@"photo_100"];
        if (urlString) {
            self.imageURL = [NSURL URLWithString:urlString];
        }
        
    }
    return self;
}

@end
