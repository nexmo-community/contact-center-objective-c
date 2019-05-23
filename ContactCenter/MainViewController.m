//
//  MainViewController.m
//  ContactCenter
//
//  Created by Paul Ardeleanu on 22/05/2019.
//  Copyright © 2019 Nexmo. All rights reserved.
//

#import "MainViewController.h"
#import "Constants.h"
#import <NexmoClient/NexmoClient.h>


@interface MainViewController () <NXMClientDelegate, NXMCallDelegate>
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@property (weak, nonatomic) IBOutlet UILabel *activityLabel;
@property (weak, nonatomic) IBOutlet UIButton *callPhoneButton;

@property (nonatomic) NXMClient *client;
@property (nonatomic) NXMCall *call;
@property (nonatomic) CallStatus callStatus ;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Log out" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    self.client = [[NXMClient alloc] initWithToken:self.user.token];
    [self.client setDelegate:self];
    [self.client login];
}

- (void)cancel {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Logging out" message:@"Are you sure?" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self logout];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:true completion:nil];
}

- (void)logout {
    [self.userSelectionVC logout];
    [self.navigationController popViewControllerAnimated:true];
}


- (IBAction)callPhone:(id)sender {
    if (self.call != nil) {
        [self.call hangup];
        [self updateInterface];
        return;
    }
    self.callStatus = CallStatusInitiated;
    [self updateInterface];
    [self.client call:@[kCalee] callHandler:NXMCallHandlerServer delegate:self completion:^(NSError * _Nullable error, NXMCall * _Nullable call) {
        if (call == nil) {
            NSLog(@"❌❌❌ call not created: %@", error.localizedDescription);
            self.callStatus = CallStatusError;
            self.call = nil;
            [self updateInterface];
            return;
        }
        self.callStatus = CallStatusInitiated;
        [call setDelegate:self];
        self.call = call;
        [self updateInterface];
    }];
}



#pragma mark Interface

- (void)updateInterface {
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(updateInterface) withObject:nil waitUntilDone:YES];
        return;
    }
    [self.activityIndicatorView stopAnimating];
    self.activityLabel.text = @"Ready";
    self.navigationItem.rightBarButtonItem = nil;
    self.callPhoneButton.alpha = 0;
    
    if (self.client == nil) {
        return;
    }
    switch (self.client.connectionStatus) {
        case NXMConnectionStatusDisconnected:
            self.activityLabel.text = @"Disconnected";
            return;
            break;
        case NXMConnectionStatusConnecting:
            [self.activityIndicatorView startAnimating];
            self.activityLabel.text = @"Connecting...";
            return;
            break;
        case NXMConnectionStatusConnected:
            self.activityLabel.text = [NSString stringWithFormat:@"Logged in as %@", self.client.user.name];
    }
    switch (self.callStatus) {
        
        case CallStatusReady:
            self.activityLabel.text = @"Ready";
            [self.callPhoneButton setTitle:@"Call Phone" forState:UIControlStateNormal];
            self.callPhoneButton.alpha = 1;
            break;
        case CallStatusInitiated:
            [self.activityIndicatorView startAnimating];
            self.activityLabel.text = @"Calling...";
            [self.callPhoneButton setTitle:@"End Call" forState:UIControlStateNormal];
            self.callPhoneButton.alpha = 1;
            break;
        case CallStatusInProgress:
            self.activityLabel.text = @"Speaking...";
            [self.callPhoneButton setTitle:@"End Call" forState:UIControlStateNormal];
            self.callPhoneButton.alpha = 1;
            break;
        case CallStatusError:
            self.activityLabel.text = @"Error Calling";
            [self.callPhoneButton setTitle:@"Call Phone" forState:UIControlStateNormal];
            self.callPhoneButton.alpha = 1;
            break;
        case CallStatusRejected:
            self.activityLabel.text = @"Call Rejected";
            [self.callPhoneButton setTitle:@"Call Phone" forState:UIControlStateNormal];
            self.callPhoneButton.alpha = 1;
            break;
        case CallStatusCompleted:
            self.activityLabel.text = @"Call Completed";
            [self.callPhoneButton setTitle:@"Call Phone" forState:UIControlStateNormal];
            self.callPhoneButton.alpha = 1;
            break;
    }
}


#pragma mark NXMClientDelegate
- (void)connectionStatusChanged:(NXMConnectionStatus)status reason:(NXMConnectionStatusReason)reason {
    // handle change in status
    NSLog(@"💬 connectionStatusChanged - status: %ld | reason: %ld", (long)status, (long)reason);
    [self updateInterface];
}

- (void)addedToConversation:(nonnull NXMConversation *)conversation {
    NSLog(@"📣📣📣 added to conversation: %@", conversation);
}

- (void)incomingCall:(nonnull NXMCall *)call {
    // handle an incoming call
    NSLog(@"💬 Incoming Call: %@", call);
    self.call = call;
    [self displayIncomingCallAlert: call];
}

- (void)displayIncomingCallAlert: (NXMCall *)call {
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(displayIncomingCallAlert:) withObject:call waitUntilDone:YES];
        return;
    }
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Incoming call" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Answer" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self answer: call];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Reject" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self reject: call];
    }]];
    [self presentViewController:alert animated:true completion:nil];
}


- (void)answer: (NXMCall *)call {
    self.call = call;
    [self.call setDelegate:self];
    [self.call answer:self completionHandler:^(NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"error answering call: %@", error.localizedDescription);
        }
        self.callStatus = CallStatusInProgress;
        [self updateInterface];
    }];
}

- (void)reject: (NXMCall *)call {
    self.callStatus = CallStatusCompleted;
    [self updateInterface];
    [self.call reject:^(NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"error declining call: %@", error.localizedDescription);
        }
        [self updateInterface];
    }];
}




#pragma mark NXMCallDelegate

- (void)statusChanged:(nonnull NXMCallMember *)callMember {
    
    NSLog(@"🤙🤙🤙 Call Status changed | member: %@ | %@", callMember.user.displayName, callMember.user.userId);
    NSLog(@"🤙🤙🤙 Call Status changed | member status: %ld", (long)callMember.status);
    
    if (self.call == nil) {
        self.callStatus = CallStatusReady;
        [self updateInterface];
        return;
    }
    
    // call completed
    if (callMember == self.call.myCallMember && callMember.status == NXMCallMemberStatusCompleted) {
        self.callStatus = CallStatusCompleted;
        [self.call.myCallMember hangup];
        self.call = nil;
    }
    
    // call ended before it could be answered
    if (callMember == self.call.myCallMember && callMember.status == NXMCallMemberStatusAnswered) {
        NXMCallMember *otherMember = self.call.otherCallMembers.firstObject;
        if (otherMember.status == NXMCallMemberStatusCompleted || otherMember.status == NXMCallMemberStatusCancelled) {
            self.callStatus = CallStatusCompleted;
            [self.call.myCallMember hangup];
            self.call = nil;
        }
    }
    
    // call rejected
    if ([self.call.otherCallMembers containsObject:callMember] && callMember.status == NXMCallMemberStatusCancelled) {
        self.callStatus = CallStatusRejected;
        [self.call.myCallMember hangup];
        self.call = nil;
    }
    
    // call ended
    if ([self.call.otherCallMembers containsObject:callMember] && callMember.status == NXMCallMemberStatusCompleted) {
        self.callStatus = CallStatusCompleted;
        [self.call.myCallMember hangup];
        self.call = nil;
    }
    
    [self updateInterface];
    
}

@end
