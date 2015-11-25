//
//  ANDetailTableViewController.m
//  AlbumVK
//
//  Created by Андрей on 22.11.15.
//  Copyright (c) 2015 Андрей. All rights reserved.
//

#import "ANDetailTableViewController.h"
#import <UIImageView+AFNetworking.h>
#import "ANServerManager.h"
#import "ANPhoto.h"
#import "MHFacebookImageViewer.h"
#import "UIImage+animatedGIF.h"


@interface ANDetailTableViewController () <UINavigationControllerDelegate, MHFacebookImageViewerDatasource, UICollectionViewDataSource, UICollectionViewDelegate>

@property (strong,nonatomic) NSMutableArray *photosArray;
@property (strong,nonatomic) UIRefreshControl *refresh;
@property (assign,nonatomic) BOOL loadingData;

@end


const CGFloat leftAndRightPaddings = 32.f;
const CGFloat numberOfItems = 3.f;


@implementation ANDetailTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.photosArray = [NSMutableArray array];
    self.refresh = [[UIRefreshControl alloc] init];
    [self.refresh addTarget:self action:@selector(refreshWall) forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:self.refresh];
    //[self getPhotosFromServer];
}

- (void)refreshWall {
    
    [[ANServerManager sharedManager]getPhotosFromAlbumID:self.album ownerID:self.user.userID count:15 offset:0 onSuccess:^(NSArray *arrayWithPhotos) {
        
        if ([arrayWithPhotos count] > 0) {
            
            [self.photosArray removeAllObjects];
            
            [self.photosArray addObjectsFromArray:arrayWithPhotos];
            
            NSMutableArray* newPaths = [NSMutableArray array];
            for (int i = (int)[self.photosArray count] - (int)[arrayWithPhotos count]; i < [self.photosArray count]; i++) {
                [newPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
            }
            
            [self.collectionView reloadData];
            [self.refresh endRefreshing];
            self.loadingData = NO;
        }
        
        
    } onFailure:^(NSError *error, NSInteger statusCode) {
        [self.refresh endRefreshing];
    }];
    
}

- (void) getPhotosFromServer {
    
    if (self.loadingData != YES) {
        self.loadingData = YES;
        
        [[ANServerManager sharedManager]getPhotosFromAlbumID:self.album ownerID:self.user.userID count:25 offset:[self.photosArray count] onSuccess:^(NSArray *arrayWithPhotos) {

            [self.photosArray addObjectsFromArray:arrayWithPhotos];
            
            NSMutableArray* newPaths = [NSMutableArray array];
            for (int i = (int)[self.photosArray count] - (int)[arrayWithPhotos count]; i < [self.photosArray count]; i++) {
                [newPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
            }
            
            [self.collectionView reloadData];
            self.loadingData = NO;
            
            
        } onFailure:^(NSError *error, NSInteger statusCode) {
        }];
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.photosArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *collectionCellIdentifier = @"collectionCellIdentifier";
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:collectionCellIdentifier forIndexPath:indexPath];
    
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width / 3.0f, self.view.frame.size.width / 3.0f)];
    
    [cell.contentView addSubview:imageView];
    
    ANPhoto *photo = [self.photosArray objectAtIndex:indexPath.row];
    
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:[NSURL URLWithString:photo.photo_130]];
    
    __weak UIImageView *weakimageView = imageView;
    __weak id weakSelf = self;
    
    NSString *path=[[NSBundle mainBundle]pathForResource:@"loading" ofType:@"gif"];
    NSURL *url=[[NSURL alloc] initFileURLWithPath:path];
    
    [imageView setImageWithURLRequest:request
                     placeholderImage:[UIImage animatedImageWithAnimatedGIFURL:url]
                              success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                  
                                  [UIView transitionWithView:weakimageView
                                                    duration:0.3f
                                                     options:UIViewAnimationOptionTransitionCrossDissolve
                                                  animations:^{
                                                      weakimageView.image = image;
                                                      [weakSelf displayImage:weakimageView withImage:image withImageURL:[NSURL URLWithString:photo.photo_130] index:indexPath.row];
                                                      weakimageView.clipsToBounds = YES;
                                                      
                                                  } completion:NULL];
                                  
                                  
                              }
                              failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                  
                              }];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    
    return cell;
}

- (void) displayImage:(UIImageView*)imageView withImage:(UIImage *)image  withImageURL:(NSURL *)imageURL index:(NSInteger)index {
    
    [imageView setImage:image];
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

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
}

#pragma mark - UICollectionViewFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    CGFloat picDimension = (self.view.frame.size.width - leftAndRightPaddings) / numberOfItems;
    return CGSizeMake(picDimension, picDimension);
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= self.collectionView.contentSize.height - scrollView.frame.size.height/2) {
        if (!self.loadingData) {
            [self getPhotosFromServer];
        }
    }
}

- (void)dealloc {
    
    [self.collectionView setDelegate:nil];
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
