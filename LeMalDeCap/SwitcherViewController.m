//
//  SwitcherViewController.m
//  LeMalDeCap
//
//  Created by Mauro Vime Castillo on 4/12/14.
//  Copyright (c) 2014 Mauro Vime Castillo. All rights reserved.
//

#import "SwitcherViewController.h"
#import <Parse/Parse.h>
#import "Reachability.h"

@interface SwitcherViewController ()

@property UIActivityIndicatorView *indicator;
@property (weak, nonatomic) IBOutlet UILabel *status;
@property (weak, nonatomic) IBOutlet UIButton *boton;

@end

@implementation SwitcherViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.boton.layer setCornerRadius:45];
    [self.boton setClipsToBounds:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    self.status.text = @"Loading app mode";
    [self.boton setHidden:YES];
    if ([self connectedToInternet]) {
        CGFloat w = self.view.frame.size.width;
        self.indicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake((w - 37)/2.0, 281, 37, 37)];
        [self.indicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [self.indicator setColor:[UIColor blackColor]];
        [self.indicator startAnimating];
        [self.view addSubview:self.indicator];
        [PFConfig getConfigInBackgroundWithBlock:^(PFConfig *config, NSError *error) {
            NSString *estado = config[@"Estado"];
            [self.indicator stopAnimating];
            if ([estado isEqualToString:@"Foto"]) {
                [self performSegueWithIdentifier:@"fotoSegue" sender:self];
            }
            else if ([estado isEqualToString:@"Viewer"]){
                [self performSegueWithIdentifier:@"viewerSegue" sender:self];
                
            }
            else {
                [self performSegueWithIdentifier:@"segueWait" sender:self];
            }
        }];
    }
    else {
        [self.boton setHidden:NO];
        [self.status setAdjustsFontSizeToFitWidth:YES];
        self.status.text = @"Se necesita una conexión a internet";
        
    }
    
}

- (IBAction)retry:(id)sender {
    [self viewWillAppear:YES];
}

- (BOOL)connectedToInternet
{
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {
        return NO;
    } else {
        return YES;
    }
}

@end
