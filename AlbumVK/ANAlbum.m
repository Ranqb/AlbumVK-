//
//  ANAlbum.m
//  AlbumVK
//
//  Created by Андрей on 22.11.15.
//  Copyright (c) 2015 Андрей. All rights reserved.
//

#import "ANAlbum.h"

@implementation ANAlbum

- (instancetype)initWithDictionary:(NSDictionary *) responseObject {
    
    self = [super init];
    if (self) {
        
        self.title = [responseObject objectForKey:@"title"];
        self.albumid = [NSString stringWithFormat:@"%ld",(long)[[responseObject objectForKey:@"id"] integerValue]];
        self.size = [NSString stringWithFormat:@"%ld",(long)[[responseObject objectForKey:@"size"] integerValue]];
        self.desc = [responseObject objectForKey:@"description"];
    }
    return self;
}

@end
