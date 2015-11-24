//
//  ANPhotoManager.m
//  AlbumVK
//
//  Created by Андрей on 25.11.15.
//  Copyright (c) 2015 Андрей. All rights reserved.
//

#import "ANPhotoManager.h"
#import "ANPhoto.h"

@interface ANPhotoManager ()

@end


@implementation ANPhotoManager
@synthesize session;


+(ANPhotoManager*) sharedManager{
    static ANPhotoManager* manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[ANPhotoManager alloc] init];
    });
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSURLSessionConfiguration *configSession =
        [NSURLSessionConfiguration defaultSessionConfiguration];
        session = [NSURLSession sessionWithConfiguration:configSession];
    }
    return self;
}

- (void)getPhotosFromAlbumID:(NSString *)ids
                     ownerID:(NSString *)ownerIDs
                       count:(NSInteger)count offset:(NSInteger)offset
                   onSuccess:(void (^) (NSArray *arrayWithPhotos))success
                   onFailure:(void (^) (NSError *error, NSInteger statusCode)) failure {
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSString *string =
        [NSString stringWithFormat:@"https://api.vk.com/method/photos.get?owner_id=%@&v=5.40&album_id=%@&count=%ld&offset=%ld&extended=1", ownerIDs, ids, (long)count, (long)offset];
        NSURL* url = [NSURL URLWithString:string];
        
        
        
        [[session dataTaskWithURL:url completionHandler:^(NSData *data,
                                                          NSURLResponse *response,
                                                          NSError *error) {
            if (!error) {
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data
                                                                     options:kNilOptions
                                                                       error:nil];
                NSDictionary* objects = [json objectForKey:@"response"];
                
                NSArray* photosArray = [objects objectForKey:@"items"];
                
                NSMutableArray* arrayWithPhotos = [[NSMutableArray alloc]init];
                
                for (int i = 0; i < [photosArray count]; i++) {
                    
                    ANPhoto* photo = [[ANPhoto alloc]initWithDictionary:[photosArray objectAtIndex:i]];
                    
                    [arrayWithPhotos addObject:photo];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    success(arrayWithPhotos);
                });
                
                
            }
        }] resume];

    });
    
    
}

@end


