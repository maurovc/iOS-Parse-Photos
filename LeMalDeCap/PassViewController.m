//
//  PassViewController.m
//  LeMalDeCap
//
//  Created by Mauro Vime Castillo on 7/12/14.
//  Copyright (c) 2014 Mauro Vime Castillo. All rights reserved.
//

#import "PassViewController.h"
#import <LocalAuthentication/LocalAuthentication.h>
#import <Parse/Parse.h>

@interface PassViewController () <UITextFieldDelegate>

@property UIActivityIndicatorView *indicator;
@property (weak, nonatomic) IBOutlet UITextField *passField;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property NSString *pass;

@end

@implementation PassViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.passField setDelegate:self];
    [self.passField becomeFirstResponder];
    CGFloat w = self.view.frame.size.width;
    self.indicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake((w - 37)/2.0, 281, 37, 37)];
    [self.indicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.indicator setColor:[UIColor blackColor]];
    [self.indicator startAnimating];
    [self.view addSubview:self.indicator];
    [PFConfig getConfigInBackgroundWithBlock:^(PFConfig *config, NSError *error) {
        self.pass = config[@"Pass"];
        [self.indicator stopAnimating];
        NSString *passEnabled = config[@"PassEnabled"];
        if ([passEnabled isEqualToString:@"NO"]) {
            [NSTimer scheduledTimerWithTimeInterval:0.75
                                             target:self
                                           selector:@selector(sendSegue:)
                                           userInfo:nil
                                            repeats:NO];
        }
        else {
            [NSTimer scheduledTimerWithTimeInterval:0.75
                                             target:self
                                           selector:@selector(showTouchID:)
                                           userInfo:nil
                                            repeats:NO];
        }
    }];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField.text isEqualToString:self.pass]) {
        [[NSUserDefaults standardUserDefaults] setObject:@"YEAH" forKey:@"pass"];
        [self performSegueWithIdentifier:@"seguePassOk" sender:self];
    }
    else {
        self.label.text = @"Bad password";
    }
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)showTouchID:(NSTimer *)timer
{
    if ([self hasEnteredBefore]) {
        if (nil != NSClassFromString(@"LAContext")) {
            LAContext *context = [[LAContext alloc] init];
            
            NSError *error = nil;
            if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
                // Authenticate User
                [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                        localizedReason:@"Unlock with TouchID"
                                  reply:^(BOOL success, NSError *error) {
                                      if (success) {
                                          dispatch_async(dispatch_get_main_queue(), ^{
                                              [NSTimer scheduledTimerWithTimeInterval:0.75
                                                                               target:self
                                                                             selector:@selector(sendSegue:)
                                                                             userInfo:nil
                                                                              repeats:NO];
                                          });
                                      }
                                  }
                 ];
            }
        }
    }
}

-(void)sendSegue:(NSTimer *)timer
{
    [self performSegueWithIdentifier:@"seguePassOk" sender:self];
}

-(BOOL)hasEnteredBefore
{
    NSString *pass = [[NSUserDefaults standardUserDefaults] objectForKey:@"pass"];
    if (pass == nil) return NO;
    return YES;
}

@end
