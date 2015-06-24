//
//  CMDisplayViewController.h
//  DemoCoreMotion
//
//  Created by Yuanzhu Chen on 3/2/14.
//  Copyright (c) 2014 Yuanzhu Chen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import <GameKit/GKPublicProtocols.h>
#import "AppDelegate.h"

#define SERVICE_TYPE @"PeerMotion"

#define kFILTERMODENO       0
#define kFILTERMODELOWPASS  1
#define kFILTERMODEHIGHPASS 2

#define kMOTIONUPDATEINTERVAL 15.0

@interface CMDisplayViewController : UIViewController <MCSessionDelegate, MCBrowserViewControllerDelegate>


- (void)startMonitoringMotion;
- (void)stopMonitoringMotion;

@end
