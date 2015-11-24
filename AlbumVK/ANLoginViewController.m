//
//  ANLoginViewController.m
//  AlbumVK
//
//  Created by Андрей on 22.11.15.
//  Copyright (c) 2015 Андрей. All rights reserved.
//

#import "ANLoginViewController.h"
#import "ANAccessToken.h"

@interface ANLoginViewController () <UIWebViewDelegate>
@property (copy, nonatomic) ANLoginCompletionBlock completionBlock;
@property (weak, nonatomic) UIWebView* webView;
@end

@implementation ANLoginViewController



-(id) initWithServerResponse:(ANLoginCompletionBlock) completionBlock
{
    self = [super init];
    if (self) {
        self.completionBlock = completionBlock;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIWebView* webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    webView.delegate =self;
    
    webView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    [self.view addSubview:webView];
    
    UIBarButtonItem* item = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                         target:self
                                                                         action:@selector(actionCancel:)];
    self.navigationItem.leftBarButtonItem = item;
    self.navigationItem.title = @"Authorization";
    
    self.webView = webView;
    
    NSString* urlString = [NSString stringWithFormat:
                           @"https://oauth.vk.com/authorize?"
                           "client_id=5128591&"
                           "display=mobile&"
                           "redirect_uri=https://oauth.vk.com/blank.html&"
                           "scope=139286&"
                           "response_type=token&"
                           "v=5.37"];
    
    NSURL* url  = [NSURL URLWithString:urlString];
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    [webView loadRequest:request];
    
}

-(void) dealloc{
    self.webView.delegate = nil;
}

#pragma mark - Action

-(void) actionCancel:(UIBarButtonItem*) item{
    
    if (self.completionBlock){
        self.completionBlock(nil);
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    
    NSLog(@"%@", [request URL]);
    
    if ([[[request URL] description] rangeOfString:@"#access_token="].location != NSNotFound) {
        
        ANAccessToken* token = [[ANAccessToken alloc] init];
        NSString* query = [[request URL] description];
        
        NSArray* array = [query componentsSeparatedByString:@"#"];
        if ([array count] > 1) {
            query = [array lastObject];
        }
        
        NSArray* pairs = [query componentsSeparatedByString:@"&"];
        for (NSString* string  in pairs) {
            
            NSArray* values = [string componentsSeparatedByString:@"="];
            if ([values count] == 2) {
                NSString* key = [values firstObject];
                if ([key isEqualToString:@"access_token"]) {
                    token.token = [values lastObject];
                }else if ([key isEqualToString:@"expires_in"]){
                    NSTimeInterval interval = [[values lastObject] doubleValue];
                    token.expirationDate = [NSDate dateWithTimeIntervalSinceNow:interval];
                }else if([key isEqualToString:@"user_id"]){
                    token.userId = [values lastObject];
                }
            }
        }
        
        self.webView.delegate = nil;
        if (self.completionBlock){
            self.completionBlock(token);
        }
        
        [self dismissViewControllerAnimated:YES completion:nil];
        
        return NO;
    }
    return YES;
}

@end

