//
//  FotoViewerTableViewController.m
//  LeMalDeCap
//
//  Created by Mauro Vime Castillo on 4/12/14.
//  Copyright (c) 2014 Mauro Vime Castillo. All rights reserved.
//

#import "FotoViewerTableViewController.h"
#import "MBProgressHUD.h"
#import <Parse/Parse.h>
#import "UIImage+ImageEffects.h"
#import <MediaPlayer/MediaPlayer.h>
#import "VideoOrPhotoCellTableViewCell.h"

@interface FotoViewerTableViewController ()

@property NSArray *objects;
@property MBProgressHUD *HUD;
@property NSMutableArray *vcs;

@end

@implementation FotoViewerTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.objects = [[NSArray alloc] init];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated
{
    [self loadObjects];
    
    /*
     PFObject *object = [self.concerts objectAtIndex:section];
     
     if ([comentario isEqualToString:@""]) return 105;
     CGSize labelSize = [comentario
     sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:15.0f]
     constrainedToSize:CGSizeMake(self.tableView.frame.size.width - 30, 95)
     lineBreakMode:NSLineBreakByWordWrapping];
     CGFloat labelHeight = labelSize.height;
     return (105 + 15 + labelHeight + 15);
     */
}

-(void)loadObjects
{
    self.HUD = [[MBProgressHUD alloc] initWithView:self.view.window];
    [self.view.window addSubview:self.HUD];
    self.HUD.labelText = @"Downloading fotos";
    self.HUD.mode = MBProgressHUDModeIndeterminate;
    [self.HUD show:YES];
    
    PFQuery *query = [PFQuery queryWithClassName:@"SharedFotos"];
    [query whereKey:@"userName" equalTo:@"Anonymous"];
    query.cachePolicy = kPFCachePolicyNetworkElseCache;
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error == nil) {
            self.HUD.labelText = @"Downloaded";
            self.HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
            self.HUD.mode = MBProgressHUDModeCustomView;
            [self.HUD hide:YES afterDelay:1];
            NSSortDescriptor *dateDescriptor = [NSSortDescriptor
                                                sortDescriptorWithKey:@"createdAt"
                                                ascending:NO];
            NSArray *sortDescriptors = [NSArray arrayWithObject:dateDescriptor];
            self.objects = [objects
                                         sortedArrayUsingDescriptors:sortDescriptors];
            [self.tableView reloadData];
        }
        else {
            self.HUD.labelText = @"An error ocurred";
            self.HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cross"]];
            self.HUD.mode = MBProgressHUDModeCustomView;
            [self.HUD hide:YES afterDelay:1];
        }
    }];

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    self.vcs = [[NSMutableArray alloc] initWithCapacity:[self.objects count]];
    for (int i = 0; i < [self.objects count]; ++i) {
        [self.vcs addObject:[[NSObject alloc] init]];
    }
    return [self.objects count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 80.0f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 50.0f;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGFloat w = self.view.frame.size.width;
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, w, 80)];
    
    PFObject *object = [self.objects objectAtIndex:section];
    
    
    PFFile *file = [object objectForKey:@"Profile"];
    UIImageView *imV = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 60, 60)];
    [imV.layer setBorderWidth:2.0f];
    [imV.layer setBorderColor:[[UIColor colorWithRed:(123.0f/255.0f) green:(168.0f/255.0f) blue:(235.0f/255.0f) alpha:1.0f] CGColor]];
    [imV.layer setCornerRadius:30.0f];
    [imV setClipsToBounds:YES];
    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (error == nil) {
            UIImage *img = [UIImage imageWithData:data];
            imV.image = img;
            [v addSubview:imV];
        }
    }];
    
    UILabel *nom = [[UILabel alloc] initWithFrame:CGRectMake(80, 10, 160, 60)];
    nom.text = [object objectForKey:@"realUser"];
    nom.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:15.0f];
    [nom setAdjustsFontSizeToFitWidth:YES];
    [v addSubview:nom];
    
    UILabel *time = [[UILabel alloc] initWithFrame:CGRectMake(250, 10, (w - 258), 30)];
    time.text = [object objectForKey:@"fecha"];
    [time setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:12.0f]];
    [time setTextAlignment:NSTextAlignmentRight];
    [v addSubview:time];
    
    UILabel *fecha = [[UILabel alloc] initWithFrame:CGRectMake(250, 40, (w - 258), 30)];
    fecha.text = [object objectForKey:@"hora"];
    [fecha setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:12.0f]];
    [fecha setTextAlignment:NSTextAlignmentRight];
    [v addSubview:fecha];
    
    return v;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat w = self.view.frame.size.width;
    PFObject *object = [self.objects objectAtIndex:indexPath.section];
    NSString *comentario = [object objectForKey:@"comment"];
    return (w + [self heightForView:[UIFont fontWithName:@"HelveticaNeue-Bold" size:15.0f] text:comentario andSize:(w - 16)] + 10 + 8);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    VideoOrPhotoCellTableViewCell *cell = (VideoOrPhotoCellTableViewCell *)[tableView dequeueReusableCellWithIdentifier: @"fotoCell" forIndexPath:indexPath];
    CGFloat w = self.view.frame.size.width;
    
    PFObject *object = [self.objects objectAtIndex:indexPath.section];
    NSString *comentario = [object objectForKey:@"comment"];
    UITextView *comment = [[UITextView alloc] initWithFrame:CGRectMake(8, w, (w - 16), 10 + [self heightForView:[UIFont fontWithName:@"HelveticaNeue-Bold" size:15.0f] text:comentario andSize:(w - 16)])];
    
    PFFile *file = [object objectForKey:@"Foto"];
    
    if ([file.name hasSuffix:@"video.mp4"]) {
        [[cell.contentView viewWithTag:123]removeFromSuperview] ;
        [[cell.contentView viewWithTag:456]removeFromSuperview] ;
        
    }
    else {
        [[cell.contentView viewWithTag:123]removeFromSuperview] ;
        [[cell.contentView viewWithTag:456]removeFromSuperview] ;
        
    }
    [comment setText:comentario];
    [comment setTextColor:[UIColor blackColor]];
    [comment setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:15.0f]];
    [comment setContentInset:UIEdgeInsetsZero];
    [comment setEditable:NO];
    [comment setBackgroundColor:[UIColor clearColor]];
    comment.tag = 123;
    [comment setScrollEnabled:NO];
    [cell.contentView addSubview:comment];
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(8, 8, (w - 16), (w - 16))];
    [indicator setHidesWhenStopped:YES];
    [indicator setColor:[UIColor colorWithRed:(123.0f/255.0f) green:(168.0f/255.0f) blue:(235.0f/255.0f) alpha:1.0f]];
    [indicator startAnimating];
    
    if ([file.name hasSuffix:@"video.mp4"]) {
        [file getDataInBackgroundWithBlock:^(NSData *videoData, NSError *error) {
            if (error == nil) {
                [indicator stopAnimating];
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *documentsDirectory = [paths objectAtIndex:0];
                NSString *path = [documentsDirectory stringByAppendingPathComponent:@"myMovie.mp4"];
                
                [videoData writeToFile:path atomically:YES];
                NSURL *moveUrl = [NSURL fileURLWithPath:path];
                MPMoviePlayerController *player = [[MPMoviePlayerController alloc]init];
                player.movieSourceType = MPMovieSourceTypeStreaming;
                [player setContentURL:moveUrl];
                [self.vcs setObject:player atIndexedSubscript:indexPath.section];
                player.view.frame = CGRectMake(8, 8, (w - 16), (w - 16));
                player.view.tag = 456;
                [cell.contentView addSubview:player.view];
                player.fullscreen = NO;
                [player setControlStyle:MPMovieControlStyleDefault];
                [player setShouldAutoplay:NO];
                [player prepareToPlay];
                [player setRepeatMode:MPMovieRepeatModeNone];
            }
        }];
        
    }
    else {
        [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (error == nil) {
                [indicator stopAnimating];
                UIImageView *foto = [[UIImageView alloc] initWithFrame:CGRectMake(8, 8, (w - 16), (w - 16))];
                UIImage *img = [UIImage imageWithData:data];
                foto.image = img;
                [foto.layer setCornerRadius:(w / 32)];
                [foto setClipsToBounds:YES];
                [foto setContentMode:UIViewContentModeScaleAspectFit];
                foto.tag = 456;
                [foto setBackgroundColor:[UIColor blackColor]];
                [cell.contentView addSubview:foto];
            }
        }];
    }
    
    return cell;
}

-(CGFloat)heightForView:(UIFont *)font text:(NSString *)text andSize:(CGFloat)width
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, CGFLOAT_MAX)];
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.font = font;
    label.text = text;
    [label sizeToFit];
    return label.frame.size.height;
}

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 1.0f);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
