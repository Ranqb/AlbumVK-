//
//  ANPhoto.h
//  AlbumVK
//
//  Created by Андрей on 22.11.15.
//  Copyright (c) 2015 Андрей. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ANPhoto : NSObject

@property (assign,nonatomic) NSInteger width;
@property (assign,nonatomic) NSInteger height;
@property (strong,nonatomic) NSString *photo_604;
@property (strong,nonatomic) NSString *photo_75;
@property (strong,nonatomic) NSString *photo_130;
@property (strong,nonatomic) NSString *photo_807;
@property (strong,nonatomic) NSString *photo_1280;
@property (strong,nonatomic) NSString *photo_2560;

- (instancetype)initWithDictionary:(NSDictionary *) responseObject;

@end
