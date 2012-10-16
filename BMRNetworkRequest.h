//
//  BMRNetworkRequest.h
//
//  Created by Brendan Ragan on 10/10/12.
//  Copyright (c) 2012 Brendan Ragan. All rights reserved.
//

#ifndef BMRNETWORKREQUEST_H
#define BMRNETWORKREQUEST_H

#import <Foundation/Foundation.h>


@class BMRNetworkRequest;
@protocol BMRNetworkRequestDelegate
-(void)errorWithRequestForLoader:(BMRNetworkRequest*)request error:(NSError*)error;
-(void)completedRequestForLoader:(BMRNetworkRequest*)request data:(NSData*)data;

@optional
-(void)progressRequestForLoader:(BMRNetworkRequest*)request bytes:(NSUInteger)bytes;
-(void)progressPercentageRequestForLoader:(BMRNetworkRequest*)request bytes:(NSUInteger)bytes total:(NSUInteger)total percentage:(float)percentage;

@end

@interface BMRNetworkRequest : NSObject


@property (nonatomic, readonly) BOOL active;
@property (nonatomic, weak) NSObject<BMRNetworkRequestDelegate> *delegate;
@property (nonatomic, strong) NSObject *identifier;
@property (nonatomic, strong) NSDictionary *headers;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) NSString *method;
@property (nonatomic) NSUInteger buffer;
@property (nonatomic) NSUInteger httpStatus;

-(NSError*)activate;
-(NSError*)activateWithData:(NSData*)data;
-(NSError*)activateWithURL:(NSURL*)url
                identifier:(NSObject*)identifier
                    method:(NSString*)method
                   headers:(NSDictionary*)headers
                  delegate:(NSObject<BMRNetworkRequestDelegate>*)delegate
                      data:(NSData*)data;

+(BMRNetworkRequest*)request;

+(BMRNetworkRequest*)requestWithURL:(NSURL*)url
                         identifier:(NSObject*)identifier
                             method:(NSString*)method
                            headers:(NSDictionary*)headers
                           delegate:(NSObject<BMRNetworkRequestDelegate>*)delegate;

@end

extern NSString *BMRNetworkLoadStart;
extern NSString *BMRNetworkLoadNetworkError;
extern NSString *BMRNetworkLoadComplete;
extern NSString *BMRNetworkLoadProgressWithPercentage;
extern NSString *BMRNetworkLoadProgress;

#endif
