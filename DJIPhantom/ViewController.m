//
//  ViewController.m
//  DJIPhantom
//
//  Created by David Richardson on 4/10/16.
//  Copyright © 2016 David Richardson. All rights reserved.
//

#import "ViewController.h"
#import <DJISDK/DJISDK.h>

@interface ViewController () <DJISDKManagerDelegate>

@property (strong, nonatomic) UIImageView *backgroundImageView;

@end

@implementation ViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self setupUI];

}

- (void)setupUI {
    
    self.backgroundImageView = [[UIImageView alloc] initWithFrame:self.view.frame];
    self.backgroundImageView.image = [UIImage imageNamed:@"drone.jpeg"];
    [self.view addSubview:self.backgroundImageView];
    
}

- (void)viewDidAppear:(BOOL)animated {
    
    NSString *appKey = @"94084e2f1f048fedad8947cd";
    [DJISDKManager registerApp:appKey withDelegate:self];
    
}


#pragma mark - DJISDKManager

- (void)sdkManagerDidRegisterAppWithError:(NSError *)error {
    
    NSString* message = @"Register App Successfully!";
    if (error) {
        message = @"Register App Failed! Please enter your App Key and check the network.";
    }else{
        NSLog(@"registerAppSuccess");
        [DJISDKManager startConnectionToProduct];
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
