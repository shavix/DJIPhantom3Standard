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

@interface CaptureViewController () <DJICameraDelegate, DJISDKManagerDelegate, DJIPlaybackDelegate, DJIFlightControllerDelegate>

@property (strong, nonatomic) UIImageView *backgroundImageView;
@property (strong, nonatomic) UIView *fpvPreviewView;
// sliders
@property (strong, nonatomic) UISlider *leftXSlider;
@property (strong, nonatomic) UISlider *leftYSlider;
@property (strong, nonatomic) UISlider *rightXSlider;
@property (strong, nonatomic) UISlider *rightYSlider;
// temp button
@property (strong, nonatomic) UIButton *button;

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
    CGFloat width = self.view.frame.size.width / 2;
    CGFloat height = 3 * self.view.frame.size.height / 4;
    CGRect frame = CGRectMake(width / 2, 0, width, height);
    self.fpvPreviewView = [[UIView alloc] initWithFrame:frame];
    [self.view addSubview:self.fpvPreviewView];
 
    [self setupSliders];
    
    // temp button
    self.button = [UIButton buttonWithType:UIButtonTypeCustom];
    self.button.frame = CGRectMake(self.view.frame.size.width / 3, self.view.frame.size.height - 60, 100, 40);
    self.button.backgroundColor = [UIColor whiteColor];
    // Add an action in current code file (i.e. target)
    [_button addTarget:self action:@selector(buttonPressed:)
     forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_button];
}

- (void)buttonPressed:(id)sender {
    
    [self rotateDroneWithJoystick];
    
}

- (void)setupSliders {
    
    CGFloat width = self.view.frame.size.width;
    CGFloat height = 10;
    CGFloat y = self.view.frame.size.height - 60;
    
    CGRect leftXFrame = CGRectMake(20, y, width/4, height);
    CGRect leftYFrame = CGRectMake(20, y, width/4, height);
    CGRect rightXFrame = CGRectMake(width - width/4 - 20, y, width/4, height);
    CGRect rightYFrame = CGRectMake(width - width/4 - 20, y, width/4, height);
    
    self.leftXSlider = [[UISlider alloc] initWithFrame:leftXFrame];
    self.leftYSlider = [[UISlider alloc] initWithFrame:leftYFrame];
    self.rightXSlider = [[UISlider alloc] initWithFrame:rightXFrame];
    self.rightYSlider = [[UISlider alloc] initWithFrame:rightYFrame];
    
    [self.view addSubview:_leftXSlider];
    //[self.view addSubview:_leftYSlider];
    [self.view addSubview:_rightXSlider];
    //[self.view addSubview:_rightYSlider];
    
}

- (void)viewDidAppear:(BOOL)animated {
    
    [self setupUI];
    
    // register app
    NSString *appKey = @"a005c4b579757f6bc8d284d4";
    [DJISDKManager registerApp:appKey withDelegate:self];
    
    [super viewDidAppear:animated];
    [[VideoPreviewer instance] setView:self.fpvPreviewView];
    

}

#pragma mark - flightController

- (DJIFlightController*) fetchFlightController {
    if (![DJISDKManager product]) {
        return nil;
    }
    if ([[DJISDKManager product] isKindOfClass:[DJIAircraft class]]) {
        return ((DJIAircraft*)[DJISDKManager product]).flightController;
    }
    return nil;
}


- (void)sendVirtualStickFlightControlData:(DJIVirtualStickFlightControlData)controlData withCompletion:(DJICompletionBlock)completion {
    
    NSLog(@"%f", controlData.yaw);
    
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
    
    DJIFlightController *flightController = [self fetchFlightController];
    if (flightController) {
        [flightController setDelegate:self];
        [flightController setYawControlMode:DJIVirtualStickYawControlModeAngle];
        [flightController setRollPitchCoordinateSystem:DJIVirtualStickFlightCoordinateSystemGround];
        [flightController enableVirtualStickControlModeWithCompletion:^(NSError * _Nullable error) {
            if (error) {
                NSLog(@"Enable VirtualStickControlMode Failed");
            }
        }];
    }
    
}


- (void)playbackManager:(DJIPlaybackManager *)playbackManager didUpdatePlaybackState:(DJICameraPlaybackState *)playbackState {
    
    
    
}

- (void)rotateDroneWithJoystick
{
    
    for(int i = 0;i < 1; i++){
        
        float yawAngle = 5*i;
        
        if (yawAngle > DJIVirtualStickYawControlMaxAngle) { //Filter the angle between -180 ~ 0, 0 ~ 180
            yawAngle = yawAngle - 360;
        }
        
        NSTimer *timer =  [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(rotateDrone:) userInfo:@{@"YawAngle":@(yawAngle)} repeats:YES];
        [timer fire];
        
        [[NSRunLoop currentRunLoop]addTimer:timer forMode:NSDefaultRunLoopMode];
        [[NSRunLoop currentRunLoop]runUntilDate:[NSDate dateWithTimeIntervalSinceNow:2]];
        
        [timer invalidate];
        timer = nil;
    }
    
}

- (void)rotateDrone:(NSTimer *)timer
{
    NSDictionary *dict = [timer userInfo];
    float yawAngle = [[dict objectForKey:@"YawAngle"] floatValue];
    
    DJIFlightController *flightController = [self fetchFlightController];
    
    DJIVirtualStickFlightControlData vsFlightCtrlData;
    vsFlightCtrlData.pitch = 0;
    vsFlightCtrlData.roll = 0;
    vsFlightCtrlData.verticalThrottle = 0;
    vsFlightCtrlData.yaw = yawAngle;
    
    [flightController sendVirtualStickFlightControlData:vsFlightCtrlData withCompletion:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"Send FlightControl Data Failed %@", error.description);
        }
    }];
    
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
