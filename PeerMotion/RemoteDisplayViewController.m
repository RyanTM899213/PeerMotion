//
//  RemoteDisplayViewController.m
//  PeerMotion
//
//  Created by Ryan Martin on 2015-03-28.
//  Copyright (c) 2015 Ryan Martin. All rights reserved.
//
//  ** Readme **
//
//  This project allows the connection between two devices and the showing of motion information
//  on another device. The motion shown includes gyro and accelerometer information which gets
//  shown real-time on the other connected device. Firstly, you must switch tabs along the bottom
//  to the "remote" tab then click the "connect" button to connect to another device. After pressing
//  connect, you are shown another view (and view controller) which allows you to connect (either
//  via bluetooth or wifi) to another device. Upon connecting to another device, you need to press
//  "done" at the top then from the "remote" tab, you will see the other device's motion information
//  displayed on your device. Note that this project also shows local motion information by switching
//  to the "local" tab. Also note that the only feature missing from this project submission is the
//  3D displaying of the other device's motion information; every other feature is included and
//  functions properly.
//

#import "CMDisplayView.h"
#import "RemoteDisplayViewController.h"
#import "CMDisplayViewController.h"

@interface RemoteDisplayViewController() {
    float _rAvgX, _rAvgY, _rAvgZ;
    float _rVarX, _rVarY, _rVarZ;
}

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) CMDisplayView *myView;
@property (strong, nonatomic) MCAdvertiserAssistant *assistant;
@property (strong, nonatomic) MCBrowserViewController *browserVC;
@property (weak, nonatomic) IBOutlet UIButton *connectButton;  // buttons in remotedisplayviewcontroller
@property (weak, nonatomic) IBOutlet UIButton *disconnectButton;

@end

@implementation RemoteDisplayViewController

@synthesize timer, myView;
MCSession *session;  // global var

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _rAvgX = _rAvgY = _rAvgZ = 0.0;
        _rVarX = _rVarY = _rVarZ = 0.0;
        self.myView = (CMDisplayView *)self.view;
        
        
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
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    MCPeerID *myPeerID = [[MCPeerID alloc] initWithDisplayName:[[UIDevice currentDevice] name]];
    session = [[MCSession alloc] initWithPeer:myPeerID];
    session.delegate = self;
    self.assistant = [[MCAdvertiserAssistant alloc] initWithServiceType:SERVICE_TYPE discoveryInfo:nil session:session];
    [self.assistant start];
    
    [self.myView refreshUIforCMDataWithX:0 y:0 z:0 pitch:0 roll:0 yaw:0];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)connectButton:(UIButton *)sender {
    
    self.browserVC = [[MCBrowserViewController alloc] initWithServiceType:SERVICE_TYPE session:session];
    self.browserVC.delegate = self;
    [self presentViewController:self.browserVC animated:YES completion:nil];
    [self setUIToConnectedState];
}

- (IBAction)disconnectButton:(UIButton *)sender {
    
    [session disconnect];
    [self setUIToNotConnectedState];
}

#pragma mark
#pragma mark <MCSessionDelegate> methods
// Remote peer changed state
- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state {
    
    if (state == MCSessionStateConnected) [self setUIToConnectedState];
    else if (state == MCSessionStateNotConnected) [self setUIToNotConnectedState];
}

// Received data from remote peer
- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID {
    
    // receive data from cmdisplayviewcontroller here and set variables
    NSString *str = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    NSArray *values = [str componentsSeparatedByString:@"^"];
    NSString *sdata = [NSString stringWithFormat:@"%@", values[0]];
    _rAvgX = [sdata doubleValue];
    sdata = [NSString stringWithFormat:@"%@", values[1]];
    _rAvgY = [sdata doubleValue];
    sdata = [NSString stringWithFormat:@"%@", values[2]];
    _rAvgZ = [sdata doubleValue];
    sdata = [NSString stringWithFormat:@"%@", values[3]];
    _rVarX = [sdata doubleValue];
    sdata = [NSString stringWithFormat:@"%@", values[4]];
    _rVarY = [sdata doubleValue];
    sdata = [NSString stringWithFormat:@"%@", values[5]];
    _rVarZ = [sdata doubleValue];
    
    dispatch_async(dispatch_get_main_queue(), ^{ [self.myView refreshUIforCMDataWithX:_rAvgX y:_rAvgY z:_rAvgZ pitch:_rVarX roll:_rVarY yaw:_rVarZ]; });  // * must be done asynchronously *
}

// Received a byte stream from remote peer
- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID {
}

// Start receiving a resource from remote peer
- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress {
}

// Finished receiving a resource from remote peer and saved the content in a temporary location - the app is responsible for moving the file to a permanent location within its sandbox
- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error {
}

- (NSString *)participantID {
    
    return session.myPeerID.displayName;
}

#pragma mark
#pragma mark <MCBrowserViewControllerDelegate> methods

- (void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController {
    
    [self.browserVC dismissViewControllerAnimated:YES completion:nil];
}

- (void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController {
    
    [self setUIToNotConnectedState];
    [self.browserVC dismissViewControllerAnimated:YES completion:nil];
}

- (void)setUIToNotConnectedState {
    
    self.connectButton.enabled = YES;
    self.disconnectButton.enabled = NO;
}

- (void)setUIToConnectedState {
    
    self.connectButton.enabled = NO;
    self.disconnectButton.enabled = YES;
}

@end