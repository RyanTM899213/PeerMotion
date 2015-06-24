//
//  CMDisplayView.m
//  DemoCoreMotion
//
//  Created by Yuanzhu Chen on 3/2/14.
//  Copyright (c) 2014 Yuanzhu Chen. All rights reserved.
//

#import "CMDisplayView.h"

@implementation CMDisplayView
{
    CGFloat _accX, _accY, _accZ;
    double _rotPitch, _rotRoll, _rotYaw;
}

@synthesize viewAccX, viewAccY, viewAccZ;
@synthesize viewRotX, viewRotY, viewRotZ;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
*/
- (void)drawRect:(CGRect)rect
{
    // Acceleration
    float scale = 100;
    NSArray *rulers = [NSArray arrayWithObjects:self.viewAccX, self.viewAccY, self.viewAccZ, nil];
    CGFloat acc[3] = {_accX, _accY, _accZ};
    for (int i = 0; i<3; i++)
    {
        UIView *v = [rulers objectAtIndex:i];
        CGRect frame = v.frame;
        if (acc[i]>=0)
        {
            frame.size.width = acc[i]*scale;
            frame.origin.x = 160;
        }
        else
        {
            frame.origin.x = 160 + acc[i]*scale;
            frame.size.width = -acc[i]*scale;
        }
        v.frame = frame;
    }
    // Rotation
    scale = 50;
    rulers = [NSArray arrayWithObjects:self.viewRotX, self.viewRotY, self.viewRotZ, nil];
    CGFloat rot[] = {_rotPitch, _rotRoll, _rotYaw};
    for (int i = 0; i<3; i++)
    {
        UIView *v = [rulers objectAtIndex:i];
        CGRect frame = v.frame;
        if (rot[i]>=0)
        {
            frame.size.width = rot[i]*scale;
            frame.origin.x = 160;
        }
        else
        {
            frame.origin.x = 160 + rot[i]*scale;
            frame.size.width = -rot[i]*scale;
        }
        v.frame = frame;
    }
}

- (void)refreshUIforCMDataWithX:(CGFloat)x
                              y:(CGFloat)y
                              z:(CGFloat)z
                          pitch:(double)pitch
                           roll:(double)roll
                            yaw:(double)yaw
{
    _accX = x;
    _accY = y;
    _accZ = z;
    _rotPitch = pitch;
    _rotRoll = roll;
    _rotYaw = yaw;
    [self setNeedsDisplay];
}

@end
