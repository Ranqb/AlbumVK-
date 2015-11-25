//
//  ANAlbum.h
//  AlbumVK
//
//  Created by Андрей on 22.11.15.
//  Copyright (c) 2015 Андрей. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ANAlbum : NSObject

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *desc;
@property (strong, nonatomic) NSString *size;
@property (strong, nonatomic) NSString *albumid;
@property (strong, nonatomic) NSString* privacy;
@property (strong,nonatomic) NSMutableArray *photosArray;

- (instancetype)initWithDictionary:(NSDictionary *) responseObject;

@end
