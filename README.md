## Description

CPSlider is a drop-in, subclass replacement for UISlider that allows varying scrubbing speeds as the user drags away from the slider thumb, emulating the slider used in the iOS iPod music player. It also includes delegate callbacks to allow an object to be notified of scrubbing speed changes.

CPSlider was created because the only other implementation I could find, Ole Begemann's [OBSlider](https://github.com/ole/OBSlider), while top notch, had trouble with my strange use case of starting with a fine scrubbing speed and increasing back to 1.0x as the user dragged down. I also was interested to see if there was a different method by which this could be implemented, without performing the position calculations based on the various thumb and track frames.

## Usage

### General

Create a CPSlider like you would a normal UISlider:

```objective-c
CPSlider *slider = [[CPSlider alloc] initWithFrame:CGRectMake(18, 166, 284, 23)];
slider.minimumValue = 0.0f;
slider.maximumValue = 1.0f;
[self.view addSubview:slider]
[self.slider addTarget:self action:@selector(sliderValueDidChange:) forControlEvents:UIControlEventValueChanged];
```

Then you need to set an array containing the Y positions at which the scrubbing speed should change. These are Y positions, measured in points away from the centerline of the slider's frame (positive or negative). They should be sequentially increasing and wrapped in NSNumber objects.

```objective-c
slider.scrubbingSpeedPositions = [NSArray arrayWithObjects:
                                   [NSNumber numberWithInt:0],
                                   [NSNumber numberWithInt:50], 
                                   [NSNumber numberWithInt:125],
                                   [NSNumber numberWithInt:175], nil];
```

The slider scrubbing speeds should then be set in a similar fashion. These are the rate at which the slider will move relative to the change in X position of the user's touch point. Typical values will be 0.0 to 1.0, although greater than 1.0 is possible. Again, these should be wrapped in an NSNumber.

```objective-c
slider.scrubbingSpeeds = [NSArray arrayWithObjects:
                           [NSNumber numberWithFloat:1.0f],
                           [NSNumber numberWithFloat:0.5f],
                           [NSNumber numberWithFloat:0.25f],
                           [NSNumber numberWithFloat:0.1f], nil];
```

The delegate can be set if desired, along with the two external options.

```objective-c
slider.delegate = self;
slider.accelerateWhenReturning = YES;  // Defaults to YES, see CPSlider.h for info
slider.ignoreDraggingAboveSlider = YES; // Defaults to YES, see CPSlider.h for info
```

And one or both of the delegate methods can be implemented.

```objective-c
- (void)slider:(CPSlider *)slider didChangeToSpeed:(CGFloat)speed whileTracking:(BOOL)tracking {
    // Do something with the speed change
    // 'tracking' is YES during touch and changes to NO on touch up
}

- (void)slider:(CPSlider *)slider didChangeToSpeedIndex:(NSUInteger)index whileTracking:(BOOL)tracking {
    // This version reports the index of the speed entry
}

```

## Todo
- Any ideas?

## About

Charles Powell
- [GitHub](http://github.com/cbpowell)
- [Twitter](http://twitter.com/seventhcolumn)

Give me a shout if you're using this in your project!