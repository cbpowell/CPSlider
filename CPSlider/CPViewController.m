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

@synthesize slider;
@synthesize resetButton, positionLabel, speedLabel;

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    CPSlider *newSlider = [[CPSlider alloc] initWithFrame:CGRectMake(18, 166, 284, 23)];
    [self.view addSubview:newSlider];
    self.slider = newSlider;
    self.slider.delegate = self;
    [self.slider addTarget:self action:@selector(sliderValueDidChange:) forControlEvents:UIControlEventValueChanged];
    
    self.slider.scrubbingSpeedPositions = [NSArray arrayWithObjects:
                                           [NSNumber numberWithInt:0],
                                           [NSNumber numberWithInt:50], 
                                           [NSNumber numberWithInt:125],
                                           [NSNumber numberWithInt:175], nil];
    
    self.slider.scrubbingSpeeds = [NSArray arrayWithObjects:
                                   [NSNumber numberWithFloat:1.0f],
                                   [NSNumber numberWithFloat:0.5f],
                                   [NSNumber numberWithFloat:0.25f],
                                   [NSNumber numberWithFloat:0.1f], nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)sliderValueDidChange:(CPSlider *)sender {
    self.positionLabel.text = [NSString stringWithFormat:@"%.5f", sender.value];
}

- (void)resetToCenter:(id)sender {
    self.slider.value = 0.5f;
    self.positionLabel.text = @"0.5f";
    self.speedLabel.text = [NSString stringWithFormat:@"%.3f", [[slider.scrubbingSpeeds objectAtIndex:0] floatValue]];
}

#pragma mark - Slider Delegate

- (void)slider:(CPSlider *)slider didChangeToSpeed:(CGFloat)speed {
    self.speedLabel.text = [NSString stringWithFormat:@"%.3f", speed];
}

@end
