//
//  CMDisplayViewController.m
//  DemoCoreMotion
//
//  Created by Yuanzhu Chen on 3/2/14.
//  Copyright (c) 2014 Yuanzhu Chen. All rights reserved.
//

#import "CMDisplayViewController.h"
#import "CMDisplayView.h"
#import <CoreMotion/CMMotionManager.h>
#import "RemoteDisplayViewController.h"

@interface CMDisplayViewController ()
{
    int _filterMode;
    float _avgX, _avgY, _avgZ;
    float _varX, _varY, _varZ;
}

@property (nonatomic, strong) CMMotionManager *motman;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) CMDisplayView *myView;

- (void)addAcceleration:(CMAcceleration)acc;

@end

@implementation CMDisplayViewController

@synthesize motman, timer, myView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _filterMode = kFILTERMODENO;
        _avgX = _avgY = _avgZ = 0.0;
        _varX = _varY = _varZ = 0.0;
        self.myView = (CMDisplayView *)self.view;
        
        // Add UISegentedControl with 3 buttons
        
        UISegmentedControl *segment = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"low-pass", @"no filter", @"high-pass", nil]];
        segment.frame = CGRectMake(10.0, 210.0, 300.0, 44.0);
        [self.view addSubview:segment];
        [segment addTarget:self action:@selector(segmentValueChaged:) forControlEvents:UIControlEventValueChanged];
        
        // Add 3 views for acceleration display
        CGRect rect = CGRectMake(160, 80, 1, 10);
        UIView *v = [[UIView alloc] initWithFrame:rect];
        v.backgroundColor = [UIColor redColor];
        self.myView.viewAccX = v;
        [self.view addSubview:v];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(155, 57, 20, 20)];
        label.text = @"x";
        [self.view addSubview:label];
        
        rect = CGRectMake(160, 130, 1, 10);
        v = [[UIView alloc] initWithFrame:rect];
        v.backgroundColor = [UIColor redColor];
        self.myView.viewAccY = v;
        [self.view addSubview:v];
        label = [[UILabel alloc] initWithFrame:CGRectMake(155, 107, 20, 20)];
        label.text = @"y";
        [self.view addSubview:label];
        
        rect = CGRectMake(160, 180, 1, 10);
        v = [[UIView alloc] initWithFrame:rect];
        v.backgroundColor = [UIColor redColor];
        self.myView.viewAccZ = v;
        [self.view addSubview:v];
        label = [[UILabel alloc] initWithFrame:CGRectMake(155, 157, 20, 20)];
        label.text = @"z";
        [self.view addSubview:label];
        
        int kRotationOffset = 240;
        // Add 3 views for rotation display
        rect = CGRectMake(160, 80+kRotationOffset, 1, 10);
        v = [[UIView alloc] initWithFrame:rect];
        v.backgroundColor = [UIColor greenColor];
        self.myView.viewRotX = v;
        [self.view addSubview:v];
        label = [[UILabel alloc] initWithFrame:CGRectMake(142, 57+kRotationOffset, 60, 20)];
        label.text = @"pitch";
        [self.view addSubview:label];
        
        rect = CGRectMake(160, 130+kRotationOffset, 1, 10);
        v = [[UIView alloc] initWithFrame:rect];
        v.backgroundColor = [UIColor greenColor];
        self.myView.viewRotY = v;
        [self.view addSubview:v];
        label = [[UILabel alloc] initWithFrame:CGRectMake(148, 107+kRotationOffset, 60, 20)];
        label.text = @"roll";
        [self.view addSubview:label];
        
        rect = CGRectMake(160, 180+kRotationOffset, 1, 10);
        v = [[UIView alloc] initWithFrame:rect];
        v.backgroundColor = [UIColor greenColor];
        self.myView.viewRotZ = v;
        [self.view addSubview:v];
        label = [[UILabel alloc] initWithFrame:CGRectMake(145, 157+kRotationOffset, 60, 20)];
        label.text = @"yaw";
        [self.view addSubview:label];
        
        
        self.motman = [CMMotionManager new];
        if ((self.motman.accelerometerAvailable)&&(self.motman.gyroAvailable))
            // alternative: self.motman.deviceMotionAvailable == YES iff both accelerometer and gyros are available.
        {
            [self startMonitoringMotion];
        }
        else
            NSLog(@"Oh well, accelerometer or gyro unavailable...");
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.myView refreshUIforCMDataWithX:0 y:0 z:0 pitch:0 roll:0 yaw:0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - service methods
- (void)startMonitoringMotion
{
    self.motman.accelerometerUpdateInterval = 1.0/kMOTIONUPDATEINTERVAL;
    self.motman.gyroUpdateInterval = 1.0/kMOTIONUPDATEINTERVAL;
    self.motman.showsDeviceMovementDisplay = YES;
    [self.motman startAccelerometerUpdates];
    [self.motman startGyroUpdates];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:self.motman.accelerometerUpdateInterval
                                                  target:self selector:@selector(pollMotion:)
                                                userInfo:nil
                                                 repeats:YES];
}

- (void)stopMonitoringMotion
{
    [self.motman stopAccelerometerUpdates];
    [self.motman stopGyroUpdates];
}

#pragma mark - UI event handlers
- (IBAction) segmentValueChaged:(UISegmentedControl *)sender
{
    switch (sender.selectedSegmentIndex) {
        case 0:
            _filterMode = kFILTERMODELOWPASS;
            break;
        case 1:
            _filterMode = kFILTERMODENO;
            break;
        case 2:
            _filterMode = kFILTERMODEHIGHPASS;
            break;
    }
}

- (void)pollMotion:(NSTimer *)timer
{
    CMAcceleration acc = self.motman.accelerometerData.acceleration;
    CMRotationRate rot = self.motman.gyroData.rotationRate;
    float x, y, z;
    [self addAcceleration:acc];
    switch (_filterMode) {
        case kFILTERMODENO:
            x = acc.x;
            y = acc.y;
            z = acc.z;
            break;
        case kFILTERMODELOWPASS:
            x = _avgX;
            y = _avgY;
            z = _avgZ;
            break;
        case kFILTERMODEHIGHPASS:
            x = _varX;
            y = _varY;
            z = _varZ;
            break;
    }  // we just want to send data to remotedisplayviewcontroller (no receiving here)
    [self.myView refreshUIforCMDataWithX:x y:y z:z pitch:rot.x roll:rot.y yaw:rot.z];
    NSString *data = [NSString stringWithFormat:@"%f^%f^%f^%f^%f^%f", x, y, z, rot.x, rot.y, rot.z];  // separate string with '^'
    [session sendData:[data dataUsingEncoding:NSASCIIStringEncoding] toPeers:session.connectedPeers withMode:MCSessionSendDataUnreliable error:nil];  // send data
}

#pragma mark - helpers
- (void)addAcceleration:(CMAcceleration)acc
{
    float alpha = 0.1;
    _avgX = alpha*acc.x + (1-alpha)*_avgX;
    _avgY = alpha*acc.y + (1-alpha)*_avgY;
    _avgZ = alpha*acc.z + (1-alpha)*_avgZ;
    _varX = acc.x - _avgX;
    _varY = acc.y - _avgY;
    _varZ = acc.z - _avgZ;
}

@end
