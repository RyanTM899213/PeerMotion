//
//  CMDisplayView.h
//  DemoCoreMotion
//
//  Created by Yuanzhu Chen on 3/2/14.
//  Copyright (c) 2014 Yuanzhu Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CMDisplayView : UIView

- (void)refreshUIforCMDataWithX:(CGFloat)x y:(CGFloat)y z:(CGFloat)z pitch:(double)pitch roll:(double)roll yaw:(double)yaw;

@property (nonatomic, strong) UIView *viewAccX;
@property (nonatomic, strong) UIView *viewAccY;
@property (nonatomic, strong) UIView *viewAccZ;
@property (nonatomic, strong) UIView *viewRotX;
@property (nonatomic, strong) UIView *viewRotY;
@property (nonatomic, strong) UIView *viewRotZ;

@end
