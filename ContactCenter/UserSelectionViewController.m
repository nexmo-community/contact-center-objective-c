//
//  UserSelectionViewController.m
//  ContactCenter
//
//  Created by Paul Ardeleanu on 22/05/2019.
//  Copyright © 2019 Nexmo. All rights reserved.
//

#import "UserSelectionViewController.h"
#import "MainViewController.h"
#import "ApiClient.h"
#import "NexmoUser.h"

@interface UserSelectionViewController ()
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@property (weak, nonatomic) IBOutlet UILabel *activityLabel;
@property (weak, nonatomic) IBOutlet UIButton *loginJaneButton;
@property (weak, nonatomic) IBOutlet UIButton *loginJoeButton;

@end

@implementation UserSelectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.activityIndicatorView stopAnimating];
    self.activityLabel.text = @"Please select a user";
    self.loginJaneButton.alpha = 1;
    self.loginJoeButton.alpha = 1;
}

- (IBAction)logInAsJane:(id)sender {
    [self getTokenFor:@"Jane"];
    
}
- (IBAction)logInAsJoe:(id)sender {
    [self getTokenFor:@"Joe"];
}

- (void)getTokenFor:(NSString *)username {
    [self.activityIndicatorView startAnimating];
    self.activityLabel.text = @"Logging in...";
    self.loginJaneButton.alpha = 0;
    self.loginJoeButton.alpha = 0;
    [ApiClient.shared tokenFor:username successHandler:^(NexmoUser * _Nullable user) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"🎟🎟🎟 TOKEN RETRIEVED: %@", user.token);
            [self performSegueWithIdentifier:@"showMain" sender:user];
        });
    } errorHandler:^(NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.activityIndicatorView stopAnimating];
            self.activityLabel.text = @"Could not retrieve token. Please try selecting a user again...";
            self.loginJaneButton.alpha = 1;
            self.loginJoeButton.alpha = 1;
        });
    }];
    
}

- (void)logout {
    [self.activityIndicatorView stopAnimating];
    self.activityLabel.text = @"Please select a user";
    self.loginJaneButton.alpha = 1;
    self.loginJoeButton.alpha = 1;
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showMain"]) {
        MainViewController *destination = (MainViewController *)segue.destinationViewController;
        NexmoUser *user = (NexmoUser *)sender;
        destination.user = user;
        destination.userSelectionVC = self;
    }
}

@end
