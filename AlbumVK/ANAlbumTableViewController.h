//
//  ANAlbumTableViewController.h
//  AlbumVK
//
//  Created by Андрей on 22.11.15.
//  Copyright (c) 2015 Андрей. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ANAlbumTableViewController : UITableViewController

@property (strong, nonatomic) NSString* userId;
- (IBAction)userInfoAction:(UIButton *)sender;

@end
