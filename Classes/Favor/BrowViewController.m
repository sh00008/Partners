//
//  BrowViewController.m
//  Partners
//
//  Created by JiaLi on 13-7-29.
//  Copyright (c) 2013年 JiaLi. All rights reserved.
//

#import "BrowViewController.h"

@interface BrowViewController ()

@end

@implementation BrowViewController
@synthesize buttonDownload;
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
    // Do any additional setup after loading the view from its nib.
    UIImage *normalImage = nil;
    UIImage *highlightedImage = nil;
    
    CGFloat hInset = floorf(normalImage.size.width / 2);
    CGFloat vInset = floorf(normalImage.size.height / 2);
    UIEdgeInsets insets = UIEdgeInsetsMake(vInset, hInset, vInset, hInset);
    
    normalImage = [UIImage imageNamed:@"SIAlertView.bundle/button-default"];
    highlightedImage = [UIImage imageNamed:@"SIAlertView.bundle/button-default-d"];
    [self.buttonDownload setTitleColor:[UIColor colorWithWhite:0.4 alpha:1] forState:UIControlStateNormal];
    [self.buttonDownload setTitleColor:[UIColor colorWithWhite:0.4 alpha:0.8] forState:UIControlStateHighlighted];
    normalImage = [normalImage resizableImageWithCapInsets:insets];
    highlightedImage = [highlightedImage resizableImageWithCapInsets:insets];
    [self.buttonDownload setBackgroundImage:normalImage forState:UIControlStateNormal];
    [self.buttonDownload setBackgroundImage:highlightedImage forState:UIControlStateHighlighted];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [self.buttonDownload release];
    [super dealloc];
}

- (IBAction)downAll:(id)sender;
{
    
}
@end
