//
//  ANPhoto.m
//  AlbumVK
//
//  Created by Андрей on 22.11.15.
//  Copyright (c) 2015 Андрей. All rights reserved.
//

#import "ANPhoto.h"

@implementation ANPhoto

- (instancetype)initWithDictionary:(NSDictionary *) responseObject {
    
    self = [super init];
    if (self) {
        
        self.width = [[responseObject objectForKey:@"width"] integerValue];
        self.height = [[responseObject objectForKey:@"height"] integerValue];
        self.photo_75 = [responseObject objectForKey:@"photo_75"];
        self.photo_130 = [responseObject objectForKey:@"photo_130"];
        self.photo_807 = [responseObject objectForKey:@"photo_807"];
        self.photo_604 = [responseObject objectForKey:@"photo_604"];
        self.photo_1280 = [responseObject objectForKey:@"photo_1280"];
        self.photo_2560 = [responseObject objectForKey:@"photo_2560"];
    }
    return self;
}

@end
