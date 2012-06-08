//
//  CPSlider.h
//  CPSlider
//
//  Created by Charles Powell on 6/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CPSliderDelegate;

@interface CPSlider : UISlider

@property (nonatomic, weak) id <CPSliderDelegate>delegate;
@property (nonatomic, strong) NSArray *scrubbingSpeedPositions;
@property (nonatomic, strong) NSArray *scrubbingSpeeds;

@property (nonatomic) BOOL ignoreDraggingAboveSlider;

@end


@protocol CPSliderDelegate <NSObject>

@optional
- (void)slider:(CPSlider *)slider didChangeToSpeed:(CGFloat)speed;
- (void)slider:(CPSlider *)slider didChangeToSpeedIndex:(NSUInteger)index;

@end