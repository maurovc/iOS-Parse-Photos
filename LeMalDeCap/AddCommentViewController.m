//
//  AddCommentViewController.m
//  LeMalDeCap
//
//  Created by Mauro Vime Castillo on 4/12/14.
//  Copyright (c) 2014 Mauro Vime Castillo. All rights reserved.
//

#import "AddCommentViewController.h"
#import "MBProgressHUD.h"
#import <Parse/Parse.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

@interface AddCommentViewController () <UITextFieldDelegate>

@property MBProgressHUD *HUD;
@property (weak, nonatomic) IBOutlet UIImageView *imagePreview;
@property (weak, nonatomic) IBOutlet UITextField *commentField;
@property NSString *comentario;
@property (weak, nonatomic) IBOutlet UIButton *boton;

@end

@implementation AddCommentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.commentField setDelegate:self];
    if (self.upImage != nil) self.imagePreview.image = self.upImage;
    else {
        AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:self.videoURL options:nil];
        AVAssetImageGenerator *generateImg = [[AVAssetImageGenerator alloc] initWithAsset:asset];
        NSError *error = NULL;
        CMTime time = CMTimeMake(1, 65);
        CGImageRef refImg = [generateImg copyCGImageAtTime:time actualTime:NULL error:&error];
        
        self.imagePreview.image = [[UIImage alloc] initWithCGImage:refImg];
    }
    [self.boton.layer setCornerRadius:10.0f];
    [self.boton setClipsToBounds:YES];
}

-(void)viewDidAppear:(BOOL)animated
{
    [self.commentField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sendFoto:(id)sender {
    [self.commentField resignFirstResponder];
    if(self.comentario == nil) self.comentario = @"";
    [self shareFoto:self.upImage andComment:self.comentario];
}

- (IBAction)commentChanged:(id)sender {
    self.comentario = self.commentField.text;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(void)shareFoto:(UIImage *)foto andComment:(NSString *)comment
{
    
    NSData *data;
    PFFile *concertFile;
    if (foto != nil)  {
        data  =  UIImageJPEGRepresentation(foto, 1.0f);
        concertFile = [PFFile fileWithName:@"fotoLMDC.jpg" data:data];
    }
    else {
        data = [NSData dataWithContentsOfURL:self.videoURL];
        concertFile = [PFFile fileWithName:@"video.mp4" data:data];
    }
    
    if ([data length] <= 10000000) {
        //HUD creation here (see example for code)
        self.HUD = [[MBProgressHUD alloc] initWithView:self.view.window];
        [self.view.window addSubview:self.HUD];
        self.HUD.labelText = @"Uploading file";
        self.HUD.mode = MBProgressHUDModeAnnularDeterminate;
        [self.HUD show:YES];
        
        NSData *data2 = UIImageJPEGRepresentation(self.fotoPerfil, 1.0f);
        PFFile *profileFile = [PFFile fileWithName:@"fotoPerfil.jpg" data:data2];
        
        [profileFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                // Save PFFile
                [concertFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (!error) {
                        // Hide old HUD, show completed HUD (see example for code)
                        
                        // Create a PFObject around a PFFile and associate it with the current user
                        PFObject *concertObject = [PFObject objectWithClassName:@"SharedFotos"];
                        NSArray *files = [[NSArray alloc] initWithObjects:concertFile,profileFile, nil];
                        [concertObject setObject:files forKey:@"Fotos"];
                        
                        concertObject[@"userName"] = @"Anonymous";
                        concertObject[@"comment"] = comment;
                        concertObject[@"realUser"] = self.userName;
                        
                        [NSTimeZone setDefaultTimeZone:[NSTimeZone timeZoneWithName:@"Europe/Madrid"]];
                        NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:[NSDate date]];
                        NSInteger hour = [components hour];
                        NSInteger minute = [components minute];
                        NSInteger seconds = [components second];
                        NSString *timeStamp = [NSString stringWithFormat:@"%02d:%02d:%02d",(int)hour,(int)minute,(int)seconds];
                        
                        concertObject[@"hora"] = timeStamp;
                        
                        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
                        [dateFormatter setDateFormat:@"dd/MM/yyyy"];
                        NSString *anomesdia = [dateFormatter stringFromDate:[NSDate date]];
                        
                        concertObject[@"fecha"] = anomesdia;
                        
                        [concertObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                            if (!error) {
                                // MOSTRAR EXITO
                                self.HUD.labelText = @"Shared";
                                self.HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
                                self.HUD.mode = MBProgressHUDModeCustomView;
                                sleep(2);
                                [self.HUD hide:YES];
                                [self.navigationController popViewControllerAnimated:YES];
                            }
                            else{
                                self.HUD.labelText = @"An error ocurred";
                                self.HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cross"]];
                                self.HUD.mode = MBProgressHUDModeCustomView;
                                [self.HUD hide:YES afterDelay:2];
                            }
                        }];
                    }
                    else{
                        self.HUD.labelText = @"An error ocurred";
                        self.HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cross"]];
                        self.HUD.mode = MBProgressHUDModeCustomView;
                        [self.HUD hide:YES afterDelay:2];
                        // Log details of the failure
                        NSLog(@"Error: %@ %@", error, [error userInfo]);
                    }
                } progressBlock:^(int percentDone) {
                    // Update your progress spinner here. percentDone will be between 0 and 100.
                    self.HUD.progress = (float)percentDone/100;
                }];
            }
            else{
                self.HUD.labelText = @"An error ocurred";
                self.HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cross"]];
                self.HUD.mode = MBProgressHUDModeCustomView;
                [self.HUD hide:YES afterDelay:2];
                // Log details of the failure
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];
    }
}

@end
