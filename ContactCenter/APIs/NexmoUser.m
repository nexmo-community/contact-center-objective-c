//
//  NexmoUser.m
//  ContactCenter
//
//  Created by Paul Ardeleanu on 22/05/2019.
//  Copyright © 2019 Nexmo. All rights reserved.
//

#import "NexmoUser.h"

@implementation NexmoUser


+ (NexmoUser * _Nullable)from:(NSDictionary *)json {
    NexmoUser *user = [[NexmoUser alloc] init];
    user.userId = json[@"user_id"];
    user.name = json[@"user_name"];
    user.token = json[@"jwt"];
    user.tokenExpiryDate = json[@"expires_at"];
    if(user.token == nil) {
        return nil;
    }
    return user;
}
@end
