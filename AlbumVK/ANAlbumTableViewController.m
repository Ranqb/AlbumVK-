//
//  ANAlbumTableViewController.m
//  AlbumVK
//
//  Created by Андрей on 22.11.15.
//  Copyright (c) 2015 Андрей. All rights reserved.
//

#import "ANAlbumTableViewController.h"
#import "ANPhotoTableViewCell.h"
#import "ANServerManager.h"
#import "ANUserTableViewCell.h"
#import <UIImageView+AFNetworking.h>
#import "ANFriendsTableViewController.h"
#import "ANUser.h"
#import "ANAlbum.h"
#import "ANDetailTableViewController.h"

@interface ANAlbumTableViewController ()

@property (strong, nonatomic) ANUser* user;
@property (strong, nonatomic) NSString* cityName;
@property (strong, nonatomic) NSMutableArray* albumArray;
@property (assign, nonatomic) BOOL loadingData;

@end


@implementation ANAlbumTableViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.refreshControl = [UIRefreshControl new];
    [self.refreshControl addTarget:self
                            action:@selector(pullToRefresh)
                  forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    
    self.albumArray = [NSMutableArray array];
    self.loadingData = YES;
    if (self.userId){
        [self getUserAndAlbum:self.userId];

    }else{
        [[ANServerManager sharedManager] authorizeUser:^(ANUser *user) {
            [self getUserAndAlbum:user.userID];
        }];
        
    }
    
}
-(void) getUserAndAlbum:(NSString*) userId{
    [[ANServerManager sharedManager]
     getUserWithUserId:userId
     onSuccess:^(ANUser *user) {
         self.user = user;
         [self getAlbumsFromServer];
         [self.tableView reloadData];
         
         
     } onFailure:^(NSError *error, NSInteger statusCode) {
         
     }];
}

- (void) getAlbumsFromServer {
    
    [[ANServerManager sharedManager]
     getAlbumsUser:self.user.userID
     count:20
     offset:[self.albumArray count]
     onSuccess:^(NSArray *arrayWithAlbums) {
         NSLog(@"Albom count %lu", (unsigned long)[arrayWithAlbums count]);
         dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
             [self.albumArray addObjectsFromArray:arrayWithAlbums];
             
             NSMutableArray* newPaths = [NSMutableArray array];
             for (int i = (int)[self.albumArray count] - (int)[arrayWithAlbums count]; i < [self.albumArray count]; i++) {
                 [newPaths addObject:[NSIndexPath indexPathForRow:i inSection:1]];
             }
             dispatch_sync(dispatch_get_main_queue(), ^{
                 [self.tableView beginUpdates];
                 [self.tableView insertRowsAtIndexPaths:newPaths withRowAnimation:UITableViewRowAnimationFade];
                 [self.tableView endUpdates];
                 self.loadingData = NO;
             });
         });

    } onFailure:^(NSError *error,  NSInteger statusCode) {
        
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 1;
    }else{
        return [self.albumArray count];
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString* cellIdentifier1 = @"UserCell";
    static NSString *cellIdentifier2 = @"photosCell";

    if (indexPath.section == 0) {
        ANUserTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier1];
        
        cell.nameLabel.text = [NSString stringWithFormat:@"%@ %@", self.user.firstName, self.user.lastName];
        NSInteger onlineIndicator = [self.user.online integerValue];
        
        if (onlineIndicator == 0) {
            cell.onlineLabel.text = @"Offline";
        }else{
            cell.onlineLabel.text = @"Online";
            
        }
        NSURLRequest* request = [NSURLRequest requestWithURL:self.user.imageURL];
        
        __weak ANUserTableViewCell* weakCell = cell;
        
        [cell.userImage setImageWithURLRequest:request placeholderImage:[UIImage imageNamed:@"1.jpg"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            weakCell.userImage.image = image;
            [weakCell layoutSubviews];
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            
        }];
        
        return cell;
    }
    if (indexPath.section == 1){

        ANAlbum *album = [self.albumArray objectAtIndex:indexPath.row];
        
        ANPhotoTableViewCell *cell = (ANPhotoTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier2];
        
        if (!cell) {
            cell = [[ANPhotoTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault album:album user:self.user reuseIdentifier:cellIdentifier2];
        }else{
            //ну без костылей никак ¯\_(ツ)_/¯ вроде получше при скролле 
            [cell.collectionView performBatchUpdates:^{
                [cell.collectionView reloadData];
            } completion:nil];
        }
        
        cell.albumNameLabel.text = album.title;
        cell.albumPhotosCountLabel.text = [NSString stringWithFormat:@"%@ photos",album.size];
        
        return cell;
        }
    
    
    return nil;
}

#pragma mark - UITableViewDelegate

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    id cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    
    if ([cell isKindOfClass:[ANUserTableViewCell class]]) {
        return 130.f;
    }

    
    return 100.f;
}
- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return NO;
    }
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [self performSegueWithIdentifier:@"detailCollectionSegue" sender:indexPath];
    }

}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"detailCollectionSegue"]) {
        
        NSIndexPath *indexPath = (NSIndexPath *)sender;
        
        ANAlbum *album = [self.albumArray objectAtIndex:indexPath.row];
        ANDetailTableViewController *vc = [segue destinationViewController];
        vc.user = self.user;
        vc.album = album;
    }
}
#pragma mark - Action


- (IBAction)userInfoAction:(UIButton *)sender {
    
    if (sender.tag == 100) {
        ANFriendsTableViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ANFriendsTableViewController"];
        vc.userID = self.user.userID;
        [self.navigationController pushViewController:vc animated:YES];
        
    }
}



#pragma mark - PullToRefresh


- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    cell.transform = CGAffineTransformMakeScale(0.8, 0.8);
    [UIView animateWithDuration:0.5 animations:^{
        cell.transform = CGAffineTransformIdentity;
    }];
}


#pragma mark - PullToRefresh


- (void)pullToRefresh {
    
    //Чтобы не испортить анимацию делаем задержку при скроле
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^{
        if ([[UIApplication sharedApplication]isIgnoringInteractionEvents]) {
            [[UIApplication sharedApplication]beginIgnoringInteractionEvents];
        }
        [self.refreshControl endRefreshing];
        [self.albumArray removeAllObjects];
        
        [[ANServerManager sharedManager] getAlbumsUser:self.user.userID count:15 offset:[self.albumArray count] onSuccess:^(NSArray *arrayWithAlbums) {
            [self.albumArray addObjectsFromArray:arrayWithAlbums];
            [self.tableView reloadData];
            
        } onFailure:^(NSError *error, NSInteger statusCode) {
            NSLog(@"error = %@, code = %ld",[error localizedDescription], (long)statusCode);
            
        }];
    });
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView
                  willDecelerate:(BOOL)decelerate {
    
    CGFloat currentOffset = scrollView.contentOffset.y;
    CGFloat maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height;
    
    // Change 10.0 to adjust the distance from bottom
    if (maximumOffset - currentOffset <= 10.0) {
        
        //Чтобы не испортить анимацию делаем задержку при скроле
        double delayInSeconds = 1.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^{
            if ([[UIApplication sharedApplication]isIgnoringInteractionEvents]) {
                [[UIApplication sharedApplication]beginIgnoringInteractionEvents];
            }
            [self getAlbumsFromServer];
        });
    }
}




@end
