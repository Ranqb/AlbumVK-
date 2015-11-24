//
//  ANPhotoTableViewCell.m
//  AlbumVK
//
//  Created by Андрей on 22.11.15.
//  Copyright (c) 2015 Андрей. All rights reserved.
//

#import "ANPhotoTableViewCell.h"
#import "ANServerManager.h"
#include "ANPhotoManager.h"
#import "ANPhoto.h"
#import <UIImageView+AFNetworking.h>
#import "MHFacebookImageViewer.h"
#import "UIImage+animatedGIF.h"
#import <AFNetworking.h>

static NSString *CollectionViewCellIdentifier = @"CollectionViewCellIdentifier";

@interface ANPhotoTableViewCell () <MHFacebookImageViewerDatasource>

@property (strong,nonatomic) NSMutableArray *photosArray;
@property (assign,nonatomic) BOOL loadingData;

@end

@implementation ANPhotoTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style album:(ANAlbum *)album user:(ANUser*)user reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (!(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) return nil;
    
    self.photosArray = [NSMutableArray array];
    
    self.backgroundColor = [UIColor colorWithRed:0.082 green:0.082 blue:0.082 alpha:1.000];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.sectionInset = UIEdgeInsetsMake(0, 5, 0, 0);
    layout.itemSize = CGSizeMake(46, 46);
    layout.minimumInteritemSpacing = 5.f;
    layout.minimumLineSpacing = 2.f;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.collectionView = [[ANIndexedCollectionView alloc] initWithFrame:CGRectMake(0, 50, self.bounds.size.width, 50) collectionViewLayout:layout];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:CollectionViewCellIdentifier];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor colorWithRed:0.082 green:0.082 blue:0.082 alpha:1.000];
    self.albumNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, 231, 21)];
    self.albumNameLabel.font = [UIFont systemFontOfSize:15.f];
    self.albumNameLabel.textColor = [UIColor whiteColor];
    
    [self addSubview:self.albumNameLabel];
    
    self.albumPhotosCountLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 29, 231, 21)];
    self.albumPhotosCountLabel.font = [UIFont systemFontOfSize:13.f];
    self.albumPhotosCountLabel.textColor = [UIColor lightGrayColor];
    [self addSubview:self.albumPhotosCountLabel];
    self.album = album;
    self.user = user;
    self.loadingData = YES;
    [self getPhotosFromServer];
    
    [self.contentView addSubview:self.collectionView];    

    return self;
}

- (void) getPhotosFromServer {
    
    [[ANPhotoManager sharedManager]getPhotosFromAlbumID:self.album.albumid ownerID:self.user.userID count:15 offset:[self.photosArray count] onSuccess:^(NSArray *arrayWithPhotos) {

        [self.photosArray addObjectsFromArray:arrayWithPhotos];
        
        [self.collectionView reloadData];
        self.loadingData = NO;
        
    } onFailure:^(NSError *error, NSInteger statusCode) {
        
    }];
}


#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(ANIndexedCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.photosArray count];
}

- (UICollectionViewCell *)collectionView:(ANIndexedCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CollectionViewCellIdentifier forIndexPath:indexPath];
    
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 46, 46)];
    
    [cell.contentView addSubview:imageView];
    
    ANPhoto *photo = [self.photosArray objectAtIndex:indexPath.row];
    
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:[NSURL URLWithString:photo.photo_130]];
    
    __weak UIImageView *weakImageView = imageView;
    __weak id weakSelf = self;

    NSString *path=[[NSBundle mainBundle]pathForResource:@"loading" ofType:@"gif"];
    NSURL *url=[[NSURL alloc] initFileURLWithPath:path];
    
    [imageView setImageWithURLRequest:request
                     placeholderImage:[UIImage animatedImageWithAnimatedGIFURL:url]
                              success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                  
                                  [UIView transitionWithView:weakImageView
                                                    duration:0.3f
                                                     options:UIViewAnimationOptionTransitionCrossDissolve
                                                  animations:^{
                                                      weakImageView.image = image;
                                                      [weakSelf displayImage:weakImageView withImage:image withImageURL:[NSURL URLWithString:photo.photo_130] index:indexPath.row];
                                                     // weakImageView.clipsToBounds = YES;
                                                      
                                                  } completion:NULL];
                                  
                                  
                              }
                              failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                  
                              }];
    imageView.clipsToBounds = YES;
    imageView.contentMode = UIViewContentModeScaleAspectFill;

    
    return cell;
}


- (void) displayImage:(UIImageView*)imageView withImage:(UIImage *)image  withImageURL:(NSURL *)imageURL index:(NSInteger)index {
    
    [imageView setImage:image];
    // imageView.contentMode = UIViewContentModeScaleAspectFill;
    
    [imageView setupImageViewerWithDatasource:self initialIndex:index onOpen:^{
        
    } onClose:^{
        
    }];
}

#pragma mark - MHFacebookImageViewerDatasource

- (NSInteger) numberImagesForImageViewer:(MHFacebookImageViewer *)imageViewer {
    return [self.photosArray count];
}

-  (NSURL*) imageURLAtIndex:(NSInteger)index imageViewer:(MHFacebookImageViewer *)imageViewer {
    
    if ([[self.photosArray objectAtIndex:index] isKindOfClass:[ANPhoto class]]) {
        ANPhoto *photo = [self.photosArray objectAtIndex:index];
        
        if (photo.photo_2560) {
            return [NSURL URLWithString:photo.photo_2560];
            
        }else if (photo.photo_1280){
            return [NSURL URLWithString:photo.photo_1280];
        }else if (photo.photo_807){
            return [NSURL URLWithString:photo.photo_807];
        }
        return [NSURL URLWithString:photo.photo_604];
        
    }
    else {
        return 0;
    }
}

- (UIImage *) imageDefaultAtIndex:(NSInteger)index imageViewer:(MHFacebookImageViewer *)imageViewer{
    
    NSString *path=[[NSBundle mainBundle]pathForResource:@"loading" ofType:@"gif"];
    NSURL *url=[[NSURL alloc] initFileURLWithPath:path];
    
    return [UIImage animatedImageWithAnimatedGIFURL:url];
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height) {
        if (!self.loadingData)
        {
            self.loadingData = YES;
            [self getPhotosFromServer];
        }
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.collectionView.frame = CGRectMake(0, 50, self.bounds.size.width, 50);
}

@end
