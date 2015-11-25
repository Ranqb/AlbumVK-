//
//  ANServerManager.h
//  AlbumVK
//
//  Created by Андрей on 22.11.15.
//  Copyright (c) 2015 Андрей. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ANUser.h"


@class ANAccessToken;

@interface ANServerManager : NSObject

@property (strong, nonatomic) ANUser* user;



+(ANServerManager*) sharedManager;

-(void) authorizeUser:(void(^)(ANUser* user)) completion;

-(void) getFriendsWithUserId:(NSString*) user
                      offset:(NSInteger) offset
                       count:(NSInteger) count
                   onSuccess:(void(^)(NSArray* friends)) success
                   onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure;

-(void) getUserWithUserId:(NSString*) userId
                onSuccess:(void(^)(ANUser* user)) success
                onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure;

- (void)getAlbumsUser:(NSString *)ids
                count:(NSInteger)count
               offset:(NSInteger)offset
            onSuccess:(void (^) (NSArray *arrayWithAlbums))success
            onFailure:(void (^) (NSError *error, NSInteger statusCode)) failure;

- (void)getPhotosFromAlbumID:(NSString *)ids
                     ownerID:(NSString *)ownerIDs
                       count:(NSInteger)count offset:(NSInteger)offset
                   onSuccess:(void (^) (NSArray *arrayWithPhotos))success
                   onFailure:(void (^) (NSError *error, NSInteger statusCode)) failure;

@end
