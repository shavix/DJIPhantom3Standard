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
#import<CoreLocation/CoreLocation.h>

#define weakSelf(__TARGET__) __weak typeof(self) __TARGET__=self
#define weakReturn(__TARGET__) if(__TARGET__==nil)return;

float rollAngle = 10;
float yawAngle = 10;

@interface CaptureViewController () <DJICameraDelegate, DJISDKManagerDelegate, DJIPlaybackDelegate, DJIFlightControllerDelegate,CLLocationManagerDelegate>

@property (strong, nonatomic) UIImageView *backgroundImageView;
@property (strong, nonatomic) UIView *fpvPreviewView;
@property (strong, nonatomic) UIButton *landButton;
@property (strong, nonatomic) UIButton *rotateRightButton;
@property (strong, nonatomic) UIButton *rotateLeftButton;
@property (strong, nonatomic) UIButton *rollRightButton;
@property (strong, nonatomic) UIButton *rollLeftButton;

@property (strong, nonatomic) CLLocationManager *locationManager;

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
    
    [self setupButtons];
    
}

- (void)setupButtons {
    
    // autoLand button
    self.landButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _landButton.frame = CGRectMake(3 * self.view.frame.size.width / 8, self.view.frame.size.height - 60, self.view.frame.size.width / 4, 40);
    [_landButton setTitle:@"Hack" forState:UIControlStateNormal];
    [_landButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _landButton.backgroundColor = [UIColor redColor];
    // Add an action in current code file (i.e. target)
    [_landButton addTarget:self action:@selector(landButtonPressed:)
      forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_landButton];
    
    CGFloat width = self.view.frame.size.width / 5;
    CGFloat height = self.view.frame.size.height / 3;
    
    // rotate left button
    self.rotateLeftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _rotateLeftButton.frame = CGRectMake(10, 10, width, height);
    [_rotateLeftButton setTitle:@"L Rotate" forState:UIControlStateNormal];
    [_rotateLeftButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _rotateLeftButton.backgroundColor = [UIColor whiteColor];
    // Add an action in current code file (i.e. target)
    [_rotateLeftButton addTarget:self action:@selector(lRotatePressed:)
          forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_rotateLeftButton];
    
    // rotate right button
    self.rotateRightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _rotateRightButton.frame = CGRectMake(10, 20 + height, width, height);
    [_rotateRightButton setTitle:@"R Rotate" forState:UIControlStateNormal];
    [_rotateRightButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _rotateRightButton.backgroundColor = [UIColor whiteColor];
    // Add an action in current code file (i.e. target)
    [_rotateRightButton addTarget:self action:@selector(rRotatePressed:)
          forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_rotateRightButton];
    
    // roll left button
    self.rollLeftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _rollLeftButton.frame = CGRectMake(self.view.frame.size.width - width - 10, 10, width, height);
    [_rollLeftButton setTitle:@"L Roll" forState:UIControlStateNormal];
    [_rollLeftButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _rollLeftButton.backgroundColor = [UIColor whiteColor];
    // Add an action in current code file (i.e. target)
    [_rollLeftButton addTarget:self action:@selector(lRollPressed:)
                 forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_rollLeftButton];
    
    
    // roll right button
    self.rollRightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _rollRightButton.frame = CGRectMake(self.view.frame.size.width - width - 10, 20 + height, width, height);
    [_rollRightButton setTitle:@"R Roll" forState:UIControlStateNormal];
    [_rollRightButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _rollRightButton.backgroundColor = [UIColor whiteColor];
    // Add an action in current code file (i.e. target)
    [_rollRightButton addTarget:self action:@selector(rRollPressed:)
               forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_rollRightButton];
    
}

- (void)viewDidAppear:(BOOL)animated {
    
    [self setupUI];
    
    // register app
    NSString *appKey = @"a005c4b579757f6bc8d284d4";
    [DJISDKManager registerApp:appKey withDelegate:self];
    
    [super viewDidAppear:animated];
    [[VideoPreviewer instance] setView:self.fpvPreviewView];
    
}

#pragma mark - buttons

- (void)landButtonPressed:(id)sender {
    
    DJIFlightController *flightController = [self fetchFlightController];
    
    float latitude = 34.0209481;
    float longitude = -118.2825436;
    /*
    CLLocationCoordinate2D home = CLLocationCoordinate2DMake(latitude, longitude);
    
    NSLog(@"%f", home.latitude);
    NSLog(@"%f", home.longitude);
    
    [flightController setHomeLocation:home withCompletion:^(NSError *err) {
        NSLog(@"%@", err.description);
    }];
    
    
    [flightController goHomeWithCompletion:^(NSError *err) {
        NSLog(@"%@", err.description);
    }];
     */
    
    NSString *message = [NSString stringWithFormat:@"Drone hacked! Sending to coordinates:\r(%f, %f)", latitude, longitude];
    
    [self showAlertViewWithTitle:@"Success" withMessage:message];
    
    /*
    [flightController autoLandingWithCompletion:^(NSError *error){
        NSLog(@"landed");
    }];
     */
}

- (void)lRotatePressed:(id)sender {
    
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(rotateDrone:) userInfo:@{@"Direction":@"l"} repeats:NO];
    [timer fire];
    
    [[NSRunLoop currentRunLoop]addTimer:timer forMode:NSDefaultRunLoopMode];
    [[NSRunLoop currentRunLoop]runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
    
    [timer invalidate];
    timer = nil;

    
}

- (void)rRotatePressed:(id)sender {
    
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(rotateDrone:) userInfo:@{@"Direction":@"r"} repeats:NO];
    [timer fire];
    
    [[NSRunLoop currentRunLoop]addTimer:timer forMode:NSDefaultRunLoopMode];
    [[NSRunLoop currentRunLoop]runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
    
    [timer invalidate];
    timer = nil;

    
}

- (void)lRollPressed:(id)sender {
    
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(rollDrone:) userInfo:@{@"Direction":@"l"} repeats:NO];
    [timer fire];
    
    [[NSRunLoop currentRunLoop]addTimer:timer forMode:NSDefaultRunLoopMode];
    [[NSRunLoop currentRunLoop]runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
    
    [timer invalidate];
    timer = nil;

    
}

- (void)rRollPressed:(id)sender {
    
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(rollDrone:) userInfo:@{@"Direction":@"r"} repeats:NO];
    [timer fire];
    
    [[NSRunLoop currentRunLoop]addTimer:timer forMode:NSDefaultRunLoopMode];
    [[NSRunLoop currentRunLoop]runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
    
    [timer invalidate];
    timer = nil;
    
}

#pragma mark - DJIFlightController


- (void)rollDrone:(NSTimer *)timer {
    
    
    DJIMissionManager *missionManager = [DJIMissionManager sharedInstance];
    [missionManager stopMissionExecutionWithCompletion:^(NSError *error) {
        NSLog(@"%@", error.description);
    }];
    
    
    NSDictionary *dict = [timer userInfo];
    NSString *direction = [dict objectForKey:@"Direction"];
    
    float angle = rollAngle;
    if([direction isEqualToString:@"l"]) {
        angle = angle*-1;
    }
    
    NSLog(@"%f", angle);
    
    DJIFlightController *flightController = [self fetchFlightController];
    
    DJIVirtualStickFlightControlData vsFlightCtrlData;
    vsFlightCtrlData.pitch = 0;
    vsFlightCtrlData.roll = 10;
    vsFlightCtrlData.verticalThrottle = 0;
    vsFlightCtrlData.yaw = 0;
    
    [flightController sendVirtualStickFlightControlData:vsFlightCtrlData withCompletion:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"Send FlightControl Data Failed %@", error.description);
        }
    }];
    
}

- (void)rotateDrone:(NSTimer *)timer
{
    
    DJIMissionManager *missionManager = [DJIMissionManager sharedInstance];
    [missionManager stopMissionExecutionWithCompletion:^(NSError *error) {
        NSLog(@"%@", error.description);
    }];
    
    NSDictionary *dict = [timer userInfo];
    NSString *direction = [dict objectForKey:@"Direction"];
    
    float angle = yawAngle;
    if([direction isEqualToString:@"l"]) {
        angle = angle*-1;
    }
    NSLog(@"%f", angle);
   
    DJIFlightController *flightController = [self fetchFlightController];
    
    DJIVirtualStickFlightControlData vsFlightCtrlData;
    vsFlightCtrlData.pitch = 0;
    vsFlightCtrlData.roll = 0;
    vsFlightCtrlData.verticalThrottle = 0;
    vsFlightCtrlData.yaw = 10;
    
    [flightController sendVirtualStickFlightControlData:vsFlightCtrlData withCompletion:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"Send FlightControl Data Failed %@", error.description);
        }
    }];
    
}




- (void)rotateDroneWithJoystick
{
    
    
    /*
     int iterations = 1;
     
     for(int i = 0;i < iterations; i++){
     
     float yawAngle = 90*i;
     float rollAngle = 10;
     
     if (yawAngle > DJIVirtualStickYawControlMaxAngle) { //Filter the angle between -180 ~ 0, 0 ~ 180
     yawAngle = yawAngle - 360;
     }
     
     //NSTimer *timer =  [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(rotateDrone:) userInfo:@{@"YawAngle":@(yawAngle)} repeats:NO];
     NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(rollDrone:) userInfo:@{@"RollAngle":@(rollAngle)} repeats:NO];
     [timer fire];
     
     [[NSRunLoop currentRunLoop]addTimer:timer forMode:NSDefaultRunLoopMode];
     [[NSRunLoop currentRunLoop]runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.2]];
     
     [timer invalidate];
     timer = nil;
     }
     */
    
    
}

#pragma mark - DJICamera

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

-(void)camera:(DJICamera *)camera didReceiveVideoData:(uint8_t *)videoBuffer length:(size_t)size
{
    uint8_t* pBuffer = (uint8_t*)malloc(size);
    memcpy(pBuffer, videoBuffer, size);
    [[VideoPreviewer instance].dataQueue push:pBuffer length:(int)size];
}

- (void)camera:(DJICamera *)camera didUpdateSystemState:(DJICameraSystemState *)systemState
{
    
}


- (DJICamera*) fetchCamera {
    
    if (![DJISDKManager product]) {
        return nil;
    }
    if ([[DJISDKManager product] isKindOfClass:[DJIAircraft class]]) {
        return ((DJIAircraft*)[DJISDKManager product]).camera;
    }
    return nil;
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


#pragma mark - DJIPlaybackManager

- (void)playbackManager:(DJIPlaybackManager *)playbackManager didUpdatePlaybackState:(DJICameraPlaybackState *)playbackState {
    
}



@end
