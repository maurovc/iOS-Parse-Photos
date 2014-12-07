//
//  ViewController.m
//  LeMalDeCap
//
//  Created by Mauro Vime Castillo on 4/12/14.
//  Copyright (c) 2014 Mauro Vime Castillo. All rights reserved.
//

#import "ViewController.h"
#import <Parse/Parse.h>
#import "AddCommentViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>

@interface ViewController () <UITextFieldDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIAlertViewDelegate,UIActionSheetDelegate>

@property NSString *userName;
@property UIImage *fotoPerfil;
@property (weak, nonatomic) IBOutlet UIButton *botonShare;
@property  UIImageView *perfilView;
@property (weak, nonatomic) IBOutlet UITextField *nombre;
@property BOOL isProfile;
@property UIImage *upImage;
@property (weak, nonatomic) IBOutlet UILabel *numfotosLabel;
@property NSURL *videoURL;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.botonShare.layer setCornerRadius:10];
    [self.botonShare setClipsToBounds:YES];
    [self.nombre setDelegate:self];
    self.fotoPerfil = nil;
    self.isProfile = NO;
    self.userName = nil;
    self.fotoPerfil = [UIImage imageNamed:@"fotoPerfil.jpg"];
    [self loadProfile];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    CGFloat w = self.view.frame.size.width;
    self.perfilView = [[UIImageView alloc] initWithFrame:CGRectMake((w - 170.0)/2.0, 72, 170, 170)];
    if (self.fotoPerfil) [self.perfilView setImage:self.fotoPerfil];
    else [self.perfilView setImage:[UIImage imageNamed:@"fotoPerfil.jpg"]];
    [self.perfilView.layer setCornerRadius:(175/2.0)];
    [self.perfilView setClipsToBounds:YES];
    [self.perfilView.layer setBorderWidth:2.0f];
    [self.perfilView.layer setBorderColor:[[UIColor colorWithRed:(123.0f/255.0f) green:(168.0f/255.0f) blue:(235.0f/255.0f) alpha:1.0f] CGColor]];
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fotoTapped:)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    tapGestureRecognizer.numberOfTouchesRequired = 1;
    [self.perfilView addGestureRecognizer:tapGestureRecognizer];
    [self.perfilView  setUserInteractionEnabled:YES];
    [self.view addSubview:self.perfilView];
    
    if (self.userName != nil) {
        [self.nombre setText:self.userName];
    }
    self.numfotosLabel.text = @"0 fotos";
    [self numberOfFotos];
}

-(void)loadProfile
{
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"nom"];
    if (data) {
        self.userName = [[NSUserDefaults standardUserDefaults] objectForKey:@"nom"];
    }
    data = [[NSUserDefaults standardUserDefaults] objectForKey:@"fotoPerfil"];
    if (data) {
        self.fotoPerfil = [UIImage imageWithData:data];
    }
}

-(void)numberOfFotos
{
    PFQuery *query = [PFQuery queryWithClassName:@"SharedFotos"];
    [query whereKey:@"userName" equalTo:@"Anonymous"];
    query.cachePolicy = kPFCachePolicyNetworkElseCache;
    [query countObjectsInBackgroundWithBlock:^(int count, NSError *error) {
        if (!error) {
            if (count == 1) {
                self.numfotosLabel.text = @"1 file";
            }
            else self.numfotosLabel.text = [NSString stringWithFormat:@"%d files",count];
        }
    }];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)compartirFoto:(id)sender {
    self.isProfile = NO;
    [self chooseFoto];
}

- (IBAction)newName:(id)sender {
    UITextField *field = (UITextField *)sender;
    self.userName = field.text;
    if ([self.userName isEqual:@""]) self.userName = nil;
    [[NSUserDefaults standardUserDefaults] setObject:self.userName forKey:@"nom"];
}

-(void)fotoTapped:(UITapGestureRecognizer *)onetap
{
    self.isProfile = YES;
    [self chooseFoto];
}

-(void)chooseFoto
{
    NSString *title = @"New picture";
    if (self.isProfile) title = @"Profile picture";
    if (nil != NSClassFromString(@"UIAlertController")) {
        //show alertcontroller
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:title
                                      message:@"Select picture source"
                                      preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction* ok = [UIAlertAction
                             actionWithTitle:@"Take a picture"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 //Do some thing here
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 
                                 if ([UIImagePickerController isSourceTypeAvailable:
                                      UIImagePickerControllerSourceTypeCamera] == YES){
                                     // Create image picker controller
                                     UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
                                     
                                     imagePicker.sourceType =  UIImagePickerControllerSourceTypeCamera;
                                     
                                     // Delegate is self
                                     imagePicker.delegate = self;
                                     
                                     [imagePicker setAllowsEditing:YES];
                                     
                                     [imagePicker setShowsCameraControls:YES];
                                     
                                     //[imagePicker setShowsCameraControls:YES];
                                     
                                     imagePicker.navigationBar.barStyle = UIBarStyleBlackOpaque;
                                     imagePicker.navigationBar.tintColor = [UIColor colorWithRed:(123.0f/255.0f) green:(168.0f/255.0f) blue:(235.0f/255.0f) alpha:1.0f];
                                     
                                     // Show image picker
                                     [self presentViewController:imagePicker animated:YES completion:nil];
                                     //[self presentModalViewController:imagePicker animated:YES];
                                 }
                                 
                             }];
        [alert addAction:ok]; // add action to uialertcontroller
        
        
        UIAlertAction* ok2 = [UIAlertAction
                              actionWithTitle:@"Choose from library"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action)
                              {
                                  //Do some thing here
                                  [alert dismissViewControllerAnimated:YES completion:nil];
                                  
                                  if ([UIImagePickerController isSourceTypeAvailable:
                                       UIImagePickerControllerSourceTypePhotoLibrary] == YES){
                                      // Create image picker controller
                                      UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
                                      
                                      // Set source to the camera
                                      imagePicker.sourceType =  UIImagePickerControllerSourceTypePhotoLibrary;
                                      
                                      imagePicker.videoMaximumDuration = 15.0f;
                                      
                                      imagePicker.videoQuality = UIImagePickerControllerQualityTypeMedium;
                                      
                                      imagePicker.mediaTypes = @[(NSString *) kUTTypeImage,
                                                                 (NSString *) kUTTypeMovie];
                                      
                                      // Delegate is self
                                      imagePicker.delegate = self;
                                      
                                      [imagePicker setAllowsEditing:YES];
                                      
                                      imagePicker.navigationBar.barStyle = UIBarStyleBlackOpaque;
                                      imagePicker.navigationBar.tintColor = [UIColor colorWithRed:(123.0f/255.0f) green:(168.0f/255.0f) blue:(235.0f/255.0f) alpha:1.0f];
                                      
                                      // Show image picker
                                      [self presentViewController:imagePicker animated:YES completion:nil];
                                      //[self presentModalViewController:imagePicker animated:YES];
                                  }
                                  
                              }];
        [alert addAction:ok2]; // add action to uialertcontroller
        
        UIAlertAction* ok4 = [UIAlertAction
                              actionWithTitle:@"Cancel"
                              style:UIAlertActionStyleDestructive
                              handler:^(UIAlertAction * action)
                              {
                                  //Do some thing here
                                  [alert dismissViewControllerAnimated:YES completion:nil];
                              }];
        [alert addAction:ok4]; // add action to uialertcontroller
        
        [self presentViewController:alert animated:YES completion:nil];
    }
    else {
        UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:@"Select Picture Source" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:
                                @"Take a picture",
                                @"Choose from library",
                                nil];
        [popup showInView:[UIApplication sharedApplication].keyWindow];
    }
    
}

- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (popup.tag) {
        case 1: {
            switch (buttonIndex) {
                case 0:
                    if ([UIImagePickerController isSourceTypeAvailable:
                         UIImagePickerControllerSourceTypeCamera] == YES){
                        // Create image picker controller
                        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
                        
                        imagePicker.sourceType =  UIImagePickerControllerSourceTypeCamera;
                        
                        // Delegate is self
                        imagePicker.delegate = self;
                        
                        [imagePicker setAllowsEditing:YES];
                        
                        [imagePicker setShowsCameraControls:YES];
                        
                        imagePicker.navigationBar.barStyle = UIBarStyleBlackOpaque;
                        imagePicker.navigationBar.tintColor = [UIColor colorWithRed:(123.0f/255.0f) green:(168.0f/255.0f) blue:(235.0f/255.0f) alpha:1.0f];
                        
                        // Show image picker
                        [self presentViewController:imagePicker animated:YES completion:nil];
                        //[self presentModalViewController:imagePicker animated:YES];
                        
                    }
                    break;
                case 1:
                    if ([UIImagePickerController isSourceTypeAvailable:
                         UIImagePickerControllerSourceTypePhotoLibrary] == YES){
                        // Create image picker controller
                        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
                        
                        // Set source to the camera
                        imagePicker.sourceType =  UIImagePickerControllerSourceTypePhotoLibrary;
                        
                        imagePicker.videoMaximumDuration = 15.0f;
                        
                        imagePicker.videoQuality = UIImagePickerControllerQualityTypeMedium;
                        
                        imagePicker.mediaTypes = @[(NSString *) kUTTypeImage,
                                                   (NSString *) kUTTypeMovie];
                        
                        // Delegate is self
                        imagePicker.delegate = self;
                        
                        [imagePicker setAllowsEditing:YES];

                        
                        imagePicker.navigationBar.barStyle = UIBarStyleBlackOpaque;
                        imagePicker.navigationBar.tintColor = [UIColor colorWithRed:(123.0f/255.0f) green:(168.0f/255.0f) blue:(235.0f/255.0f) alpha:1.0f];
                        
                        // Show image picker
                        [self presentViewController:imagePicker animated:YES completion:nil];
                        //[self presentModalViewController:imagePicker animated:YES];
                    }
                    break;
                case 2:
                    break;
            }
            break;
        }
        default:
            break;
    }
}


-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:^{
        UIImage *image;
        if (self.isProfile) {
            UIImage *Bimage = [info objectForKey:@"UIImagePickerControllerEditedImage"];
            UIGraphicsBeginImageContext(CGSizeMake(200, 200));
            [Bimage drawInRect: CGRectMake(0, 0, 200, 200)];
            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
        else {
            NSURL *source = [info objectForKey:@"UIImagePickerControllerReferenceURL"];
            image = [info objectForKey:@"UIImagePickerControllerEditedImage"];
            if (![[source absoluteString]  hasPrefix:@"assets-library"]) UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
        }
        
        if (image != nil)
        {
            if (self.isProfile) {
                self.fotoPerfil = image;
                self.perfilView.image = image;
                NSData *data = UIImageJPEGRepresentation(image, 1.0);
                [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"fotoPerfil"];
            }
            else {
                self.upImage = image;
                [self performSegueWithIdentifier:@"commentSegue" sender:self];
            }
        }
        else {
            NSURL *movieURL = [info objectForKey: UIImagePickerControllerMediaURL];
            
            self.videoURL = movieURL;
            [self performSegueWithIdentifier:@"commentSegue" sender:self];
        }
    }];
}

- (void)convertVideoToLowQuailtyWithInputURL:(NSURL*)inputURL
                                   outputURL:(NSURL*)outputURL
{
    //setup video writer
    AVAsset *videoAsset = [[AVURLAsset alloc] initWithURL:inputURL options:nil];
    
    AVAssetTrack *videoTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    
    CGSize videoSize = videoTrack.naturalSize;
    
    NSDictionary *videoWriterCompressionSettings =  [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:1250000], AVVideoAverageBitRateKey, nil];
    
    NSDictionary *videoWriterSettings = [NSDictionary dictionaryWithObjectsAndKeys:AVVideoCodecH264, AVVideoCodecKey, videoWriterCompressionSettings, AVVideoCompressionPropertiesKey, [NSNumber numberWithFloat:videoSize.width], AVVideoWidthKey, [NSNumber numberWithFloat:videoSize.height], AVVideoHeightKey, nil];
    
    AVAssetWriterInput* videoWriterInput = [AVAssetWriterInput
                                            assetWriterInputWithMediaType:AVMediaTypeVideo
                                            outputSettings:videoWriterSettings];
    
    videoWriterInput.expectsMediaDataInRealTime = YES;
    
    videoWriterInput.transform = videoTrack.preferredTransform;
    
    AVAssetWriter *videoWriter = [[AVAssetWriter alloc] initWithURL:outputURL fileType:AVFileTypeQuickTimeMovie error:nil];
    
    [videoWriter addInput:videoWriterInput];
    
    //setup video reader
    NSDictionary *videoReaderSettings = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    
    AVAssetReaderTrackOutput *videoReaderOutput = [[AVAssetReaderTrackOutput alloc] initWithTrack:videoTrack outputSettings:videoReaderSettings];
    
    AVAssetReader *videoReader = [[AVAssetReader alloc] initWithAsset:videoAsset error:nil];
    
    [videoReader addOutput:videoReaderOutput];
    
    //setup audio writer
    AVAssetWriterInput* audioWriterInput = [AVAssetWriterInput
                                            assetWriterInputWithMediaType:AVMediaTypeAudio
                                            outputSettings:nil];
    
    audioWriterInput.expectsMediaDataInRealTime = NO;
    
    [videoWriter addInput:audioWriterInput];
    
    //setup audio reader
    AVAssetTrack* audioTrack = [[videoAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
    
    AVAssetReaderOutput *audioReaderOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:audioTrack outputSettings:nil];
    
    AVAssetReader *audioReader = [AVAssetReader assetReaderWithAsset:videoAsset error:nil];
    
    [audioReader addOutput:audioReaderOutput];
    
    [videoWriter startWriting];
    
    //start writing from video reader
    [videoReader startReading];
    
    [videoWriter startSessionAtSourceTime:kCMTimeZero];
    
    dispatch_queue_t processingQueue = dispatch_queue_create("processingQueue1", NULL);
    
    [videoWriterInput requestMediaDataWhenReadyOnQueue:processingQueue usingBlock:
     ^{
         
         while ([videoWriterInput isReadyForMoreMediaData]) {
             
             CMSampleBufferRef sampleBuffer;
             
             if ([videoReader status] == AVAssetReaderStatusReading &&
                 (sampleBuffer = [videoReaderOutput copyNextSampleBuffer])) {
                 
                 [videoWriterInput appendSampleBuffer:sampleBuffer];
                 CFRelease(sampleBuffer);
             }
             
             else {
                 
                 [videoWriterInput markAsFinished];
                 
                 if ([audioReader status] == AVAssetReaderStatusCompleted) {
                     
                     [videoWriter finishWritingWithCompletionHandler:^(){
                     }];
                 }
             }
         }
     }
     ];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    if ([navigationController.viewControllers count] == 3 && self.isProfile)
    {
        CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
        
        UIView *plCropOverlay = [[[viewController.view.subviews objectAtIndex:1]subviews] objectAtIndex:0];
        
        plCropOverlay.hidden = YES;
        
        int position = 0;
        
        if (screenHeight == 568) {
            position = 124;
        }
        else {
            position = 80;
        }
        
        CAShapeLayer *circleLayer = [CAShapeLayer layer];
        
        CGFloat w = self.view.frame.size.width;
        
        UIBezierPath *path2 = [UIBezierPath bezierPathWithOvalInRect:
                               CGRectMake(0.0f, position, w, w)];
        [path2 setUsesEvenOddFillRule:YES];
        
        [circleLayer setPath:[path2 CGPath]];
        
        [circleLayer setFillColor:[[UIColor clearColor] CGColor]];
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, w, screenHeight-72) cornerRadius:0];
        
        [path appendPath:path2];
        [path setUsesEvenOddFillRule:YES];
        
        CAShapeLayer *fillLayer = [CAShapeLayer layer];
        fillLayer.path = path.CGPath;
        fillLayer.fillRule = kCAFillRuleEvenOdd;
        fillLayer.fillColor = [UIColor blackColor].CGColor;
        fillLayer.opacity = 0.8;
        [viewController.view.layer addSublayer:fillLayer];
        
        UILabel *moveLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 10, w, 50)];
        [moveLabel setText:@"Move and Scale"];
        [moveLabel setTextAlignment:NSTextAlignmentCenter];
        [moveLabel setTextColor:[UIColor whiteColor]];
        
        [viewController.view addSubview:moveLabel];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"commentSegue"]) {
        AddCommentViewController *vc = (AddCommentViewController *)segue.destinationViewController;
        if(self.userName == nil) vc.userName = @"Unknown";
        else vc.userName = self.userName;
        vc.fotoPerfil = self.fotoPerfil;
        if (self.upImage != nil) vc.upImage = self.upImage;
        if (self.videoURL != nil) vc.videoURL = self.videoURL;
    }
}

@end
