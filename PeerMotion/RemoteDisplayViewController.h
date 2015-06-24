//
//  RemoteDisplayViewController.h
//  PeerMotion
//
//  Created by Ryan Martin on 2015-03-28.
//  Copyright (c) 2015 Ryan Martin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>

#define kMOTIONUPDATEINTERVAL 15.0

#define SERVICE_TYPE @"PeerMotion"

extern MCSession *session;  // gloabl variable

@interface RemoteDisplayViewController : UIViewController <MCSessionDelegate, MCBrowserViewControllerDelegate>

@end