//
//  CPViewController.m
//  CPSlider
//
//  Created by Charles Powell on 6/6/12.
//  Copyright (c) 2012 Charles Powell. All rights reserved.
//

#import "CPViewController.h"

#import "CPSlider.h"

@interface CPViewController ()

@end

@implementation CPViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    CPSlider *slider = [[CPSlider alloc] initWithFrame:CGRectMake(18, 166, 284, 23)];
    [slider addTarget:self action:@selector(sliderValueDidChange:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:slider];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)sliderValueDidChange:(UISlider *)sender {
    NSLog(@"Value: %f", sender.value);
}

@end
