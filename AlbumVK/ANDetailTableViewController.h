//
//  ANDetailTableViewController.h
//  AlbumVK
//
//  Created by Андрей on 22.11.15.
//  Copyright (c) 2015 Андрей. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ANAlbum.h"
#import "ANUser.h"


@interface ANDetailTableViewController : UIViewController

@property (strong, nonatomic) ANAlbum *album;
@property (strong, nonatomic) ANUser* user;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

