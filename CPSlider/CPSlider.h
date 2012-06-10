//
//  CPSlider.h
//  CPSlider
//

/**
 * Copyright (c) 2012 Charles Powell
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 * 
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 */

#import <UIKit/UIKit.h>

@protocol CPSliderDelegate;

@interface CPSlider : UISlider

@property (nonatomic, weak) id <CPSliderDelegate>delegate;
@property (nonatomic, strong) NSArray *scrubbingSpeedPositions;
@property (nonatomic, strong) NSArray *scrubbingSpeeds;

@property (nonatomic, readonly) float currentScrubbingSpeed;
@property (nonatomic, readonly) NSUInteger currentScrubbingSpeedPosition;

/*
 * accelerateWhenReturning:
 * Defaults to: YES
 * If set to YES, as the user's touch point returns to the slider, CPSlider will adjust
 * the position more and more rapidly towards the "true" position. The true position is
 * considered to be where the slider would be directly under the user's finger.
 */
@property (nonatomic) BOOL accelerateWhenReturning;

/*
 * ignoreDraggingAboveSlider
 * Defaults to: YES
 * If set to YES, if the user's touch strays above (i.e. lower Y position) the slider,
 * CPSlider will still use the lowest scrubbing speed. WARNING: if set to NO, and there's
 * not a negative scrubbing speed position above the touch point, you will get a crash.
 */
@property (nonatomic) BOOL ignoreDraggingAboveSlider;

@end


@protocol CPSliderDelegate <NSObject>

@optional
- (void)slider:(CPSlider *)slider didChangeToSpeed:(CGFloat)speed whileTracking:(BOOL)tracking;
- (void)slider:(CPSlider *)slider didChangeToSpeedIndex:(NSUInteger)index whileTracking:(BOOL)tracking;

@end