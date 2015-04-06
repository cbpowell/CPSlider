//
//  CPSlider.m
//  CPSlider
//

/**
 * Copyright (c) 2013 Charles Powell
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

#import "CPSlider.h"

@interface CPSlider ()

@property (nonatomic) CGFloat startingX;
@property (nonatomic) float lastValue;
@property (nonatomic) NSUInteger currentSpeedPositionIndex;
@property (nonatomic) float effectiveValue;
@property (nonatomic) float verticalChangeAdjustment;
@property (nonatomic) float horizontalChangeAdjustment;
@property (nonatomic) float beginTrackingValue;

@end

@implementation CPSlider

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSliderDefaults];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupSliderDefaults];
    }
    return self;
}

- (void)setupSliderDefaults
{
    self.scrubbingSpeedPositions = [NSArray arrayWithObjects:
                                    [NSNumber numberWithInt:0],
                                    [NSNumber numberWithInt:50],
                                    [NSNumber numberWithInt:100],
                                    [NSNumber numberWithInt:150], nil];
    
    self.scrubbingSpeeds = [NSArray arrayWithObjects:
                            [NSNumber numberWithFloat:1.0f],
                            [NSNumber numberWithFloat:0.5f],
                            [NSNumber numberWithFloat:0.25f],
                            [NSNumber numberWithFloat:0.1f], nil];
    
    self.effectiveValue = 0.0f;
    self.ignoreDraggingAboveSlider = YES;
    self.accelerateWhenReturning = YES;
}

#pragma mark - Custom UISlider getters/setters

- (void)setValue:(float)value animated:(BOOL)animated {
    if (self.isTracking) {
        // Adjust effective value
        float effectiveDifference = (value - self.lastValue) * self.currentScrubbingSpeed;
        
        self.effectiveValue += (effectiveDifference + self.verticalChangeAdjustment + self.horizontalChangeAdjustment);
        // Reset adjustments
        self.verticalChangeAdjustment = 0.0f;
        self.horizontalChangeAdjustment = 0.0f;
        
        self.lastValue = value;
        
    } else {
        // No adjustment
        self.effectiveValue = value;
    }
    
    // Either way, set use super to set true value
    float actual = MAX(MIN(value, self.maximumValue), self.minimumValue);
    
    [super setValue:actual animated:animated];
}

- (float)value {
    if (self.isTracking) {
        // If sliding, return the effective value
        return self.effectiveValue;
    } else {
        // Otherwise, the true value (grabbed via super to prevent infinite recursion)
        return [super value];
    }
}

#pragma mark - Custom getters/setters

- (void)setCurrentSpeedPositionIndex:(NSUInteger)currentSpeedPositionIndex {
    if (_currentSpeedPositionIndex == currentSpeedPositionIndex) {
        return;
    }
    
    if (currentSpeedPositionIndex == NSNotFound) {
        currentSpeedPositionIndex = self.scrubbingSpeedPositions.count-1;
    }
    _currentSpeedPositionIndex = currentSpeedPositionIndex;
    
    // Notify delegates
    if ([self.delegate respondsToSelector:@selector(slider:didChangeToSpeedIndex:whileTracking:)]) {
        [self.delegate slider:self didChangeToSpeedIndex:_currentSpeedPositionIndex whileTracking:self.isTracking];
    }
    if ([self.delegate respondsToSelector:@selector(slider:didChangeToSpeed:whileTracking:)] && _currentSpeedPositionIndex != NSNotFound) {
        [self.delegate slider:self didChangeToSpeed:[[self.scrubbingSpeeds objectAtIndex:_currentSpeedPositionIndex] floatValue] whileTracking:self.isTracking];
    }
}

- (void)setEffectiveValue:(float)effectiveValue {
    if (_effectiveValue == effectiveValue) {
        return;
    }
    
    _effectiveValue = MAX(MIN(effectiveValue, self.maximumValue), self.minimumValue);
}

#pragma mark - Touch handlers

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    self.currentSpeedPositionIndex = 0;
    
    float value = [self value];
    
    CGRect trackRect = [self trackRectForBounds:self.bounds];
    
    CGPoint currentTouchPoint = [touch locationInView:self];
    
    CGRect thumbRect = [self thumbRectForBounds:self.bounds trackRect:trackRect value:value];
    
    self.startingX = thumbRect.size.width - CGRectGetMaxX(thumbRect) + currentTouchPoint.x;
    self.lastValue = value;
	
	self.beginTrackingValue = value;

	// Skipping call to [super beginTrackingWithTouch:withEvent:] fixes a "jump" that occurs on touchdown on iOS 7 (and up?)
	BOOL beginTracking = self.shouldNotCallSuperOnBeginTracking ? YES :	[super beginTrackingWithTouch:touch withEvent:event];
	
	return beginTracking;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    if (self.isTracking) {
        CGRect trackRect = [self trackRectForBounds:self.bounds];
        
        CGPoint currentTouchPoint = [touch locationInView:self];
        currentTouchPoint.x -= trackRect.origin.x;
        
        CGPoint previousTouchPoint = [touch previousLocationInView:self];
        CGFloat verticalDownrange = currentTouchPoint.y - CGRectGetMidY(trackRect);
        self.currentSpeedPositionIndex = [self scrubbingSpeedPositionForVerticalDownrange:verticalDownrange];
        
        // Check if the touch is returning to the slider
        float maxDownrange = [[self.scrubbingSpeedPositions lastObject] floatValue];
        if (self.accelerateWhenReturning &&
            fabsf(currentTouchPoint.y < fabsf(previousTouchPoint.y)) && // adjust only if touch is returning
            fabsf(currentTouchPoint.y) < maxDownrange && // adjust only if it's inside the furthest slider speed position
            ![self pointInside:currentTouchPoint withEvent:nil]) // do not adjust if the touch is on the slider. Prevents jumpiness when default speed is not 1.0f
        {
            // Calculate and apply any vertical adjustment
            verticalDownrange = fabsf(verticalDownrange);
            float adjustmentRatio = powf((1 - (verticalDownrange/maxDownrange)), 4);
            self.verticalChangeAdjustment = ([super value] - self.effectiveValue) * adjustmentRatio;
        }
        
        // Apply horizontal change (emulation (I think?) of standard UISlider)
        
        CGRect thumbRect = [self thumbRectForBounds:self.bounds trackRect:trackRect value:0.0f];
        
        CGFloat newValue =((self.maximumValue - self.minimumValue) * (currentTouchPoint.x - self.startingX)) / (trackRect.size.width - thumbRect.size.width);
        
        [self setValue:newValue animated:NO];
        [self setNeedsLayout];
        
        // Send UIControl action
        if (self.continuous) {
            [self sendActionsForControlEvents:UIControlEventValueChanged];
        }
    }
    return self.isTracking;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
	
	self.currentSpeedPositionIndex = 0;
	
	// because [UISlider endTrackingWithTouch:withEvent:] interfere with our code
	// we can't call super, but we should at least set the 'tracking' property to NO
	[self setValue:@(NO) forKey:@"tracking"];

	// Move value to new value
    [super setValue:self.effectiveValue animated:NO];
    [self setNeedsLayout];
	
	// check if the value was changed
	if( self.effectiveValue != self.beginTrackingValue ) {
		[self sendActionsForControlEvents:UIControlEventValueChanged];
	}
	
	// UIControl cleanup
	self.highlighted = NO;
}

#pragma mark - UISlider Rect methods

- (CGRect)thumbRectForBounds:(CGRect)bounds trackRect:(CGRect)rect value:(float)value {
    CGRect thumbRect;
    if (self.isTracking) {
        // If sliding, use the effective value to place the thumb
        thumbRect = [super thumbRectForBounds:bounds trackRect:rect value:self.effectiveValue];
    } else {
        // Otherwise, use the true value
        thumbRect = [super thumbRectForBounds:bounds trackRect:rect value:self.value];
    }
    return thumbRect;
}

#pragma mark - Other Helpers

- (NSUInteger)scrubbingSpeedPositionForVerticalDownrange:(CGFloat)downrange {
    // Ignore negative downranges if specified
    if (self.ignoreDraggingAboveSlider) {
        downrange = MAX(downrange, 0);
    }
    
    return [self.scrubbingSpeedPositions indexOfObjectWithOptions:NSEnumerationReverse passingTest:^BOOL(NSNumber *obj, NSUInteger idx, BOOL *stop){
        if (downrange >= [obj floatValue]) {
            return YES;
        }
        return NO;
    }];
}

- (float)currentScrubbingSpeed {
    return [[self.scrubbingSpeeds objectAtIndex:self.currentSpeedPositionIndex] floatValue];
}

- (NSUInteger)currentScrubbingSpeedPosition {
    return self.currentSpeedPositionIndex;
}

@end
