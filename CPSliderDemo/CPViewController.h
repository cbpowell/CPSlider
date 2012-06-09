//
//  CPViewController.h
//  CPSlider
//
//  Created by Charles Powell on 6/6/12.
//  Copyright (c) 2012 Charles Powell. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CPSlider.h"

@interface CPViewController : UIViewController <CPSliderDelegate>

@property (nonatomic, weak) CPSlider *slider;
@property (nonatomic, weak) IBOutlet UIButton *resetButton;
@property (nonatomic, weak) IBOutlet UILabel *positionLabel;
@property (nonatomic, weak) IBOutlet UILabel *speedLabel;

- (IBAction)resetToCenter:(id)sender;

@end
