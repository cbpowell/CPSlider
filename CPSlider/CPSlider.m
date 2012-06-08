//
//  CPSlider.m
//  CPSlider
//
//  Created by Charles Powell on 6/6/12.
//  Copyright (c) 2012 Charles Powell. All rights reserved.
//

#import "CPSlider.h"

@interface CPSlider ()

@property (nonatomic) float currentSpeed;
@property (nonatomic) NSUInteger currentSpeedPositionIndex;
@property (nonatomic) float effectiveValue;
@property (nonatomic) float verticalChangeAdjustment;
@property (nonatomic) BOOL isSliding;
// NOTE: just using self.tracking causes order-of-occurance problems! I already tried it :)

@end

@implementation CPSlider

@synthesize delegate;
@synthesize scrubbingSpeeds;
@synthesize scrubbingSpeedPositions;
@synthesize ignoreDraggingAboveSlider;

@synthesize currentSpeed;
@synthesize currentSpeedPositionIndex = _currentSpeedPositionIndex;
@synthesize effectiveValue;
@synthesize verticalChangeAdjustment;
@synthesize isSliding;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
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
    }
    return self;
}

#pragma mark - Custom UISlider getters/setters

- (void)setValue:(float)value animated:(BOOL)animated {
    if (self.isSliding) {
        float scrubbingSpeed = [[self.scrubbingSpeeds objectAtIndex:self.currentSpeedPositionIndex] floatValue];
        float effectiveDifference = (value - [super value]) * scrubbingSpeed;
        self.effectiveValue += (effectiveDifference + self.verticalChangeAdjustment);
        self.verticalChangeAdjustment = 0.0f;
    } else {
        self.effectiveValue = value;
    }
    
    [super setValue:value animated:animated];
}

- (float)value {
    if (self.isSliding) {
        return self.effectiveValue;
    } else {
        return [super value];
    }
}

#pragma mark - Custom getters/setters

- (void)setCurrentSpeedPositionIndex:(NSUInteger)currentSpeedPositionIndex {
    if (_currentSpeedPositionIndex == currentSpeedPositionIndex) {
        return;
    }
    
    if (currentSpeedPositionIndex == NSNotFound) {
        currentSpeedPositionIndex = self.scrubbingSpeedPositions.count;
    }
    _currentSpeedPositionIndex = currentSpeedPositionIndex;
    
    // Notify delegates
    if ([self.delegate respondsToSelector:@selector(slider:didChangeToSpeedIndex:)]) {
        [self.delegate slider:self didChangeToSpeedIndex:_currentSpeedPositionIndex];
    }
    if ([self.delegate respondsToSelector:@selector(slider:didChangeToSpeed:)] && _currentSpeedPositionIndex != NSNotFound) {
        [self.delegate slider:self didChangeToSpeed:[[self.scrubbingSpeeds objectAtIndex:_currentSpeedPositionIndex] floatValue]];
    }
}

#pragma mark - Touch handlers

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    self.isSliding = YES;
    self.currentSpeedPositionIndex = 0;
    return [super beginTrackingWithTouch:touch withEvent:event];
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    BOOL continueTracking = [super continueTrackingWithTouch:touch withEvent:event];
    
    if (self.isSliding) {
        CGPoint previousTouchPoint = [touch previousLocationInView:self];
        CGPoint currentTouchPoint = [touch locationInView:self];
        
        self.currentSpeedPositionIndex = [self scrubbingSpeedPositionForVerticalDownrange:currentTouchPoint.y];
        
        // Check if vertical offset adjustment is needed if the touch is returning to the slider
        float maxDownrange = [[self.scrubbingSpeedPositions lastObject] floatValue];
        if (fabsf(currentTouchPoint.y < fabsf(previousTouchPoint.y)) && 
            fabsf(currentTouchPoint.y) < maxDownrange &&
            ![self pointInside:currentTouchPoint withEvent:nil]) 
        {
            CGFloat verticalDownrange = MAX(fabsf(currentTouchPoint.y - CGRectGetMidY([self trackRectForBounds:self.bounds])), 0);
            float adjustmentRatio = powf((1 - (verticalDownrange/maxDownrange)), 4);
            self.verticalChangeAdjustment = ([super value] - self.effectiveValue) * adjustmentRatio;
            
            // Force thumb update
            [self setNeedsLayout];
        }
    }
    return continueTracking;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [super endTrackingWithTouch:touch withEvent:event];
    self.isSliding = NO;
    self.value = self.effectiveValue;
}

#pragma mark - Thumb position

- (CGRect)thumbRectForBounds:(CGRect)bounds trackRect:(CGRect)rect value:(float)value {
    CGRect thumbRect;
    if (self.isSliding) {
        thumbRect = [super thumbRectForBounds:bounds trackRect:rect value:self.effectiveValue];
    } else {
        thumbRect = [super thumbRectForBounds:bounds trackRect:rect value:self.value];
    }
    return thumbRect;
}


#pragma mark - Other Helpers

- (NSUInteger)scrubbingSpeedPositionForVerticalDownrange:(CGFloat)downrange {
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

@end
