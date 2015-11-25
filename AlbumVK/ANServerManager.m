//
//  ANServerManager.m
//  AlbumVK
//
//  Created by Андрей on 22.11.15.
//  Copyright (c) 2015 Андрей. All rights reserved.
//

#import "ANServerManager.h"
#import "ANFriends.h"
#import "ANUser.h"
#import "ANAlbum.h"
#import "ANPhoto.h"
#import "ANLoginViewController.h"
#import "ANAccessToken.h"
#import <AFNetworking.h>



static NSString* kToken = @"kToken";
static NSString* kExpirationDate = @"kExpirationDate";
static NSString* kUserId = @"kUserId";

@interface ANServerManager ()
@property (strong, nonatomic) ANAccessToken* accessToken;
@property (strong,nonatomic) dispatch_queue_t requestQueue;
@property (strong, nonatomic) AFHTTPRequestOperationManager* requestOperationManager;




@end


@implementation ANServerManager

+(ANServerManager*) sharedManager{
    static ANServerManager* manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[ANServerManager alloc] init];
    });
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.requestQueue = dispatch_queue_create("VKAlbum.requestVk", DISPATCH_QUEUE_PRIORITY_DEFAULT);
        NSURL* url = [NSURL URLWithString:@"https://api.vk.com/method/"];
        self.requestOperationManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
        self.accessToken = [[ANAccessToken alloc]init];
        [self loadSettings];
    }
    return self;
}

- (void)saveSettings:(ANAccessToken *)token {
    
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:token.token forKey:kToken];
    [userDefaults setObject:token.expirationDate forKey:kExpirationDate];
    [userDefaults setObject:token.userId forKey:kUserId];
    [userDefaults synchronize];
}

- (void)loadSettings {
    
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    self.accessToken.token = [userDefaults objectForKey:kToken];
    self.accessToken.expirationDate = [userDefaults objectForKey:kExpirationDate];
    self.accessToken.userId = [userDefaults objectForKey:kUserId];
    
}


-(void) authorizeUser:(void(^)(ANUser* user)) completion{
    
    if ([self.accessToken.expirationDate compare:[NSDate date]] == NSOrderedDescending) {
        
        [self getUserWithUserId:self.accessToken.userId onSuccess:^(ANUser *user) {
            if (completion) {
                self.user = user;
                completion(user);
            }
        } onFailure:^(NSError *error, NSInteger statusCode) {
            if (completion) {
                completion(nil);
            }
        }];
        
    }else{
        ANLoginViewController* vc = [[ANLoginViewController alloc] initWithServerResponse:^(ANAccessToken *token) {
            
            [self saveSettings:token];
            self.accessToken = token;
            
            if (token) {
                
                [self getUserWithUserId:self.accessToken.userId
                              onSuccess:^(ANUser *user) {
                                  if (completion) {
                                      completion(user);
                                  }
                              }
                              onFailure:^(NSError *error, NSInteger statusCode) {
                                  if (completion) {
                                      completion(nil);
                                  }
                              }];
                
            } else if (completion) {
                completion(nil);
            }
        }];
        
        UINavigationController* nv = [[UINavigationController alloc]initWithRootViewController:vc];
        
        UIViewController* mainVC = [[[[UIApplication sharedApplication] windows] firstObject] rootViewController];
        
        [mainVC presentViewController:nv animated:YES completion:nil];
    }
    
    
    
}


-(void) getUserWithUserId:(NSString*) userId
                onSuccess:(void(^)(ANUser* user)) success
                onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure{
    
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:
                            userId,                         @"user_ids",
                            @"photo_100,city,online",       @"fields",
                            @"nom",                         @"name_case",
                            @"5.37",                        @"v",
                            self.accessToken.token,         @"access_token",
                            nil];
    
    [self.requestOperationManager
     GET:@"users.get"
     parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
         NSLog(@"JSON: %@", responseObject);

         dispatch_async(self.requestQueue, ^{
             
             NSArray* array = [responseObject objectForKey:@"response"];
             NSDictionary* dict = [array firstObject];
             ANUser* user = [[ANUser alloc] initWithServerResponse:dict];
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 self.user = user;
                 if (success) {
                     success(user);
                 }
             });
         });
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"Error: %@", error);
         
         if (failure) {
             failure(error, operation.response.statusCode);
         }
     }];

}

-(void) getFriendsWithUserId:(NSString*) user
                      offset:(NSInteger) offset
                       count:(NSInteger) count
                   onSuccess:(void(^)(NSArray* friends)) success
                   onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure{
    
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:  user,                   @"user_id",
                                                                        @"hints",               @"order",
                                                                        @(count),               @"count",
                                                                        @(offset),              @"offset",
                                                                        @"photo_100,online",    @"fields",
                                                                        @"nom",                 @"name_case",
                                                                        @"3",                   @"v",
                                                                        self.accessToken.token, @"access_token",
                                                                        nil];
    
    
    [self.requestOperationManager
     GET:@"friends.get"
     parameters:params
     success:^(AFHTTPRequestOperation *operation, NSDictionary* responseObject) {
         NSLog(@"JSON: %@", responseObject);
         
         NSArray* dictsArray = [responseObject objectForKey:@"response"];
         
         NSMutableArray* objectArray = [NSMutableArray array];
         for (NSDictionary* dict in dictsArray) {
             ANFriends* user = [[ANFriends alloc] initWithServerResponse:dict];
             [objectArray addObject:user];
         }
         
//         dispatch_async(dispatch_get_main_queue(), ^{
         
             if (success) {
                 success(objectArray);
             }
//         });
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"Error: %@", error);
         
         if (failure) {
             failure(error, operation.response.statusCode);
         }
         
     }];
    
}

- (void)getAlbumsUser:(NSString *)ids
                      count:(NSInteger)count
                     offset:(NSInteger)offset
                  onSuccess:(void (^) (NSArray* arrayWithAlbums))success
                  onFailure:(void (^) (NSError* error, NSInteger statusCode)) failure {
    
    NSDictionary* parameters = [NSDictionary dictionaryWithObjectsAndKeys:ids,                  @"owner_id",
                                                                        @(count),               @"count",
                                                                        @(offset),              @"offset",
                                                                        @"1",                   @"need_system",
                                                                        @"5.40",                @"v",
                                                                        self.accessToken.token, @"access_token",
                                                                        nil];

    
    [self.requestOperationManager GET:@"photos.getAlbums"
                           parameters:parameters
                              success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        dispatch_async(self.requestQueue, ^{
            NSLog(@"JSON: %@", responseObject);

            
            NSDictionary* objects = [responseObject objectForKey:@"response"];
            
            NSArray* commentsArray = [objects objectForKey:@"items"];
            
            NSMutableArray* arrayWithAlbums = [[NSMutableArray alloc]init];
            
            for (int i = 0; i < [commentsArray count]; i++) {
                
                ANAlbum* album = [[ANAlbum alloc]initWithDictionary:[commentsArray objectAtIndex:i]];
                [arrayWithAlbums addObject:album];
                
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                success(arrayWithAlbums);
            });
        });
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(error, operation.response.statusCode);
        }
    }];
    
}

- (void)getPhotosFromAlbumID:(NSString *)ids
                     ownerID:(NSString *)ownerIDs
                       count:(NSInteger)count offset:(NSInteger)offset
                   onSuccess:(void (^) (NSArray *arrayWithPhotos))success
                   onFailure:(void (^) (NSError *error, NSInteger statusCode)) failure {
    
    
    NSDictionary* parameters = [NSDictionary dictionaryWithObjectsAndKeys:  ownerIDs,               @"owner_id" ,
                                                                            ids,                    @"album_id",
                                                                            @(count),               @"count" ,
                                                                            @(offset),              @"offset",
                                                                            @"1",                   @"extended",
                                                                            @"5.37",                @"v",
                                                                            self.accessToken.token, @"access_token",
                                                                            nil];

    
    [self.requestOperationManager GET:@"photos.get" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        dispatch_async(self.requestQueue, ^{
        
            NSDictionary* objects = [responseObject objectForKey:@"response"];
            
            NSArray* photosArray = [objects objectForKey:@"items"];
            
            NSMutableArray* arrayWithPhotos = [[NSMutableArray alloc]init];
            
            for (int i = 0; i < [photosArray count]; i++) {
                
                ANPhoto* photo = [[ANPhoto alloc]initWithDictionary:[photosArray objectAtIndex:i]];
                
                [arrayWithPhotos addObject:photo];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                success(arrayWithPhotos);
            });
        });
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(error, operation.response.statusCode);
    }];
    
    
}




@end
