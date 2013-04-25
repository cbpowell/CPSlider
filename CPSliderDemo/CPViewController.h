//
//  CPViewController.h
//  CPSlider
//
//  Created by Charles Powell on 6/6/12.
//  Copyright (c) 2013 Charles Powell. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CPSlider.h"

@interface CPViewController : UIViewController <CPSliderDelegate>

@property (nonatomic, strong) CPSlider *slider;
@property (nonatomic, strong) IBOutlet UIButton *resetButton;
@property (nonatomic, strong) IBOutlet UILabel *positionLabel;
@property (nonatomic, strong) IBOutlet UILabel *speedLabel;

- (IBAction)resetToCenter:(id)sender;

@end
