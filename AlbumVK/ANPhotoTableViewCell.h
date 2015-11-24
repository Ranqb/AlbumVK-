//
//  ANPhotoTableViewCell.h
//  AlbumVK
//
//  Created by Андрей on 22.11.15.
//  Copyright (c) 2015 Андрей. All rights reserved.
//

#import "ANPhotoTableViewCell.h"
#import "ANIndexedCollectionView.h"
#import "ANAlbum.h"
#import "ANUser.h"


@interface ANPhotoTableViewCell : UITableViewCell <UICollectionViewDataSource, UICollectionViewDelegate>

@property (strong, nonatomic) UILabel *albumNameLabel;
@property (strong, nonatomic) UILabel *albumPhotosCountLabel;
@property (strong, nonatomic) ANAlbum *album;
@property (strong, nonatomic) ANUser *user;
@property (nonatomic, strong) ANIndexedCollectionView *collectionView;

- (id)initWithStyle:(UITableViewCellStyle)style album:(ANAlbum *)album user:(ANUser*)user reuseIdentifier:(NSString *)reuseIdentifier;


@end