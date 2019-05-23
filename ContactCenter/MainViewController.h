//
//  MainViewController.h
//  ContactCenter
//
//  Created by Paul Ardeleanu on 22/05/2019.
//  Copyright © 2019 Nexmo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserSelectionViewController.h"
#import "NexmoUser.h"

NS_ASSUME_NONNULL_BEGIN


typedef NS_ENUM(NSInteger, CallStatus) {
    CallStatusReady,
    CallStatusInitiated,
    CallStatusInProgress,
    CallStatusError,
    CallStatusRejected,
    CallStatusCompleted
};


@interface MainViewController : UIViewController

@property (weak) UserSelectionViewController *userSelectionVC;
@property NexmoUser *user;

@end

NS_ASSUME_NONNULL_END
