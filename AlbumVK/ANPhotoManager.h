//
//  ANPhotoManager.h
//  AlbumVK
//
//  Created by Андрей on 25.11.15.
//  Copyright (c) 2015 Андрей. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ANPhotoManager : NSObject

@property (nonatomic, strong) NSURLSession *session;


+(ANPhotoManager*) sharedManager;


- (void)getPhotosFromAlbumID:(NSString *)ids
                     ownerID:(NSString *)ownerIDs
                       count:(NSInteger)count offset:(NSInteger)offset
                   onSuccess:(void (^) (NSArray *arrayWithPhotos))success
                   onFailure:(void (^) (NSError *error, NSInteger statusCode)) failure;

@end
