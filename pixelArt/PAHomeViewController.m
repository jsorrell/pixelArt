//
//  PAHomeViewController.m
//  pixelArt
//
//  Created by Jack Sorrell on 7/28/13.
//  Copyright (c) 2013 Jack Sorrell. All rights reserved.
//

#import "PAHomeViewController.h"

@interface PAHomeViewController ()
- (IBAction)drawPressed:(UIButton *)sender;
- (IBAction)galleryPressed:(UIButton *)sender;

@end

@implementation PAHomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated
{

}

- (void)viewWillAppear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)drawPressed:(UIButton *)sender
{
    [self performSegueWithIdentifier:@"newDrawing" sender:self];
}

- (IBAction)galleryPressed:(UIButton *)sender {
}
@end
