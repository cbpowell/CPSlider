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

@property (nonatomic, unsafe_unretained) CPSlider *slider;
@property (nonatomic, unsafe_unretained) IBOutlet UIButton *resetButton;
@property (nonatomic, unsafe_unretained) IBOutlet UILabel *positionLabel;
@property (nonatomic, unsafe_unretained) IBOutlet UILabel *speedLabel;

- (IBAction)resetToCenter:(id)sender;

@end
