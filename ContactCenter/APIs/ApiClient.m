//
//  ApiClient.m
//  ContactCenter
//
//  Created by Paul Ardeleanu on 22/05/2019.
//  Copyright © 2019 Nexmo. All rights reserved.
//

#import "ApiClient.h"
#import "Constants.h"


@interface ApiClient ()

@property NSURLSession *session;

@end

@implementation ApiClient

+ (id)shared {
    static ApiClient *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[self alloc] init];
    });
    return shared;
}

- (id)init {
    if (self = [super init]) {
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        queue.qualityOfService = NSOperationQualityOfServiceBackground;
        self.session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:queue];
        
    }
    return self;
}

- (void)tokenFor:(NSString*)username successHandler:(ApiSuccessCallbackWithObject _Nullable)successHandler errorHandler:(ApiErrorCallback _Nullable)errorHandler {
    NSString *url = [NSString stringWithFormat:@"%@/api/jwt", kApiServerURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSData *requestData = [[NSString stringWithFormat:@"{\"user_name\": \"%@\", \"mobile_api_key\": \"%@\"}", username, kApiKey] dataUsingEncoding:NSUTF8StringEncoding];
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[requestData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody: requestData];
    
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (data == nil) {
            errorHandler(error);
        } else {
            NSString *jsonString = [NSString stringWithUTF8String:[data bytes]];
            NSLog(@"JSON: %@", jsonString);
            NSError *jsonError;
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
            if (jsonError != nil) {
                errorHandler(error);
            } else {
                NexmoUser *user = [NexmoUser from:json];
                if (user == nil) {
                     errorHandler(error);
                } else {
                    successHandler(user);
                }
            }
        }
    }];
    [task resume];
    
    
    
    
    
}
@end
