//
//  ANLoginViewController.h
//  AlbumVK
//
//  Created by Андрей on 22.11.15.
//  Copyright (c) 2015 Андрей. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ANAccessToken;

typedef void(^ANLoginCompletionBlock)(ANAccessToken* token);

@interface ANLoginViewController : UIViewController

-(id) initWithServerResponse:(ANLoginCompletionBlock) completionBlock;


@end
