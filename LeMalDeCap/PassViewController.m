//
//  PassViewController.m
//  LeMalDeCap
//
//  Created by Mauro Vime Castillo on 7/12/14.
//  Copyright (c) 2014 Mauro Vime Castillo. All rights reserved.
//

#import "PassViewController.h"
#import <LocalAuthentication/LocalAuthentication.h>

@interface PassViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *passField;
@property (weak, nonatomic) IBOutlet UILabel *label;

@end

@implementation PassViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.passField setDelegate:self];
    [self.passField becomeFirstResponder];
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

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField.text isEqualToString:@""]) {
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
    // Dispose of any resources that can be recreated.
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
