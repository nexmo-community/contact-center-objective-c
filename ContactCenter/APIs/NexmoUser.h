//
//  NexmoUser.h
//  ContactCenter
//
//  Created by Paul Ardeleanu on 22/05/2019.
//  Copyright © 2019 Nexmo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NexmoUser : NSObject

@property NSString *userId;
@property NSString *name;
@property NSString *token;
@property NSString *tokenExpiryDate;

+ (NexmoUser * _Nullable)from:(NSDictionary *)json;

@end

NS_ASSUME_NONNULL_END
