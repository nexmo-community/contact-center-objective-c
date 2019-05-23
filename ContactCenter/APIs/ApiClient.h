//
//  ApiClient.h
//  ContactCenter
//
//  Created by Paul Ardeleanu on 22/05/2019.
//  Copyright © 2019 Nexmo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NexmoUser.h"

NS_ASSUME_NONNULL_BEGIN


typedef void(^ApiSuccessCallbackWithObject)(NexmoUser * _Nullable user);
typedef void(^ApiErrorCallback)(NSError * _Nullable error);

@interface ApiClient : NSObject

+ (id)shared;

- (void)tokenFor:(NSString*)username successHandler:(ApiSuccessCallbackWithObject _Nullable)successHandler errorHandler:(ApiErrorCallback _Nullable)errorHandler;

@end

NS_ASSUME_NONNULL_END
