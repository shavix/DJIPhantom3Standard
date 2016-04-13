//
//  ViewController.m
//  DJIPhantom
//
//  Created by David Richardson on 4/10/16.
//  Copyright © 2016 David Richardson. All rights reserved.
//

// iOS-PanoramaDemo
    // https://github.com/DJI-Mobile-SDK/iOS-PanoramaDemo

#import "CaptureViewController.h"
#import "VideoPreviewer/VideoPreviewer.h"
#import <DJISDK/DJISDK.h>

#define weakSelf(__TARGET__) __weak typeof(self) __TARGET__=self
#define weakReturn(__TARGET__) if(__TARGET__==nil)return;

@interface CaptureViewController () <DJICameraDelegate, DJISDKManagerDelegate, DJIPlaybackDelegate>

@property (strong, nonatomic) UIImageView *backgroundImageView;
@property (strong, nonatomic) UIView *fpvPreviewView;

@end

@implementation CaptureViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
}

- (void)setupUI {
    
    // backgroundImageView
    self.backgroundImageView = [[UIImageView alloc] initWithFrame:self.view.frame];
    self.backgroundImageView.image = [UIImage imageNamed:@"drone.jpeg"];
    [self.view addSubview:self.backgroundImageView];
    
    // imageView
    self.fpvPreviewView = [[UIView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:self.fpvPreviewView];
    
}

- (void)viewDidAppear:(BOOL)animated {
    
    [self setupUI];
    
    // register app
    NSString *appKey = @"a005c4b579757f6bc8d284d4";
    [DJISDKManager registerApp:appKey withDelegate:self];
    
    [super viewDidAppear:animated];
    [[VideoPreviewer instance] setView:self.fpvPreviewView];
    

}

#pragma mark - Camera

- (DJICamera*) fetchCamera {
    
    if (![DJISDKManager product]) {
        return nil;
    }
    if ([[DJISDKManager product] isKindOfClass:[DJIAircraft class]]) {
        return ((DJIAircraft*)[DJISDKManager product]).camera;
    }
    return nil;
}


-(void) sdkManagerProductDidChangeFrom:(DJIBaseProduct* _Nullable) oldProduct to:(DJIBaseProduct* _Nullable) newProduct
{
    __weak DJICamera* camera = [self fetchCamera];
    if (camera) {
        
        [camera setDelegate:self];
        [camera.playbackManager setDelegate:self];
    }
}

#pragma mark - DJICameraDelegate Method
-(void)camera:(DJICamera *)camera didReceiveVideoData:(uint8_t *)videoBuffer length:(size_t)size
{
    uint8_t* pBuffer = (uint8_t*)malloc(size);
    memcpy(pBuffer, videoBuffer, size);
    [[VideoPreviewer instance].dataQueue push:pBuffer length:(int)size];
}

- (void)camera:(DJICamera *)camera didUpdateSystemState:(DJICameraSystemState *)systemState
{
}

#pragma mark - DJISDKManager

- (void)sdkManagerDidRegisterAppWithError:(NSError *)error {
    
    NSString* message = @"Register App Successfully!";
    if (error) {
        message = @"Register App Failed! Please enter your App Key and check the network.";
    }else{
        NSLog(@"registerAppSuccess");
        [DJISDKManager startConnectionToProduct];
        [[VideoPreviewer instance] start];

    }
    
    [self showAlertViewWithTitle:@"Register App" withMessage:message];
    
}

- (void)showAlertViewWithTitle:(NSString *)title withMessage:(NSString *)message
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}


@end
