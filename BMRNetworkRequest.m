//
//  BMRNetworkRequest.m
//
//  Created by Brendan Ragan on 10/10/12.
//  Copyright (c) 2012 Brendan Ragan. All rights reserved.
//

#import "BMRNetworkRequest.h"

// TODO: add GZIP handling stuffs?

#define DEFAULTBUFFER 1024 * 10

@implementation BMRNetworkRequest {
    NSMutableData *_data;
    NSUInteger _buffer;
    NSURL *_url;
    NSObject<BMRNetworkRequestDelegate> *_delegate;
    NSObject *_identifier;
    NSURLConnection *_connection;
    NSUInteger _contentsize;
    NSDictionary *_headers;
}

NSString *BMRNetworkLoadStart = @"BMRNetworkLoadStart";
NSString *BMRNetworkLoadNetworkError = @"BMRNetworkLoadNetworkError";
NSString *BMRNetworkLoadComplete = @"BMRNetworkLoadComplete";
NSString *BMRNetworkLoadProgressWithPercentage = @"BMRNetworkLoadProgressWithPercentage";
NSString *BMRNetworkLoadProgress = @"BMRNetworkLoadProgress";


-(id)init {
	self = [super init];
	_data = nil;
	_active = NO;
	_buffer = 0;
	return self;
}

-(id)initWithURL:(NSURL*)url
	  identifier:(NSObject*)identifier
          method:(NSString*)method
         headers:(NSDictionary*)headers
		delegate:(NSObject<BMRNetworkRequestDelegate>*)delegate {
	self = [super init];
	_data = nil;
	_url = url;
	_delegate = delegate;
	_identifier = identifier;
	_active = NO;
	_buffer = 0;
    _headers = headers;
	return self;
}

+(BMRNetworkRequest*)request {
	BMRNetworkRequest *loader = [[BMRNetworkRequest alloc] init];
	
	return loader;
}

+(BMRNetworkRequest*)requestWithURL:(NSURL*)url
                         identifier:(NSObject*)identifier
                             method:(NSString *)method
                            headers:(NSDictionary*)headers
                           delegate:(NSObject<BMRNetworkRequestDelegate>*)delegate {
    
	BMRNetworkRequest *loader = [[BMRNetworkRequest alloc] initWithURL:url
                                                            identifier:identifier
                                                                method:method
                                                               headers:headers
                                                              delegate:delegate];
    
	return loader;
}

-(NSError*)goWithData:(NSData*)data {
	_active = YES;
    _httpStatus = 0;
    
	if ((_url == nil) || (_identifier == nil)) {
		if (_url == nil) {
			NSLog(@"SFNetworkLoader: URL not set!");
            
        }
		
        if (_identifier == nil) {
			NSLog(@"SFNetworkLoader: identifier not set!");
        }
        
        return [NSError errorWithDomain:@"BMRNetworkRequest" code:100 userInfo:nil];
	}
    
	if (_buffer == 0)
		_data = [[NSMutableData alloc] initWithCapacity:DEFAULTBUFFER];
	else
		_data = [[NSMutableData alloc] initWithCapacity:_buffer];
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:_url];
	[request setCachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData];
	[request setValue:@"gzip,deflate" forHTTPHeaderField:@"Accept-Encoding"];
    if (_headers != nil) {
        for (NSString *key in [_headers allKeys]) {
            [request setValue:_headers[key] forHTTPHeaderField:key];
        }
    }
    
    if (_method != nil) {
        [request setHTTPMethod:_method];
    }
    
    if (data != nil) {
        [request setHTTPBody:data];
    }
    
    _connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:BMRNetworkLoadStart
														object:_identifier];
    
    return nil;
}

-(NSError*)activate {
	if (_active) {
		NSLog(@"SFNetworkLoader - Already Active!");
		return [NSError errorWithDomain:@"BMRNetworkRequest" code:100 userInfo:nil];
	}
	
    return [self goWithData:nil];
}

-(NSError*)activateWithData:(NSData*)data {
	if (_active) {
		NSLog(@"SFNetworkLoader - Already Active!");
		return [NSError errorWithDomain:@"BMRNetworkRequest" code:100 userInfo:nil];
	}
	
    return [self goWithData:data];
}

-(NSError*)activateWithURL:(NSURL*)url
                identifier:(NSObject*)identifier
                    method:(NSString*)method
                   headers:(NSDictionary*)headers
                  delegate:(NSObject<BMRNetworkRequestDelegate>*)delegate
                      data:(NSData*)data {
	if (_active) {
		NSLog(@"SFNetworkLoader - Already Active!");
        return [NSError errorWithDomain:@"BMRNetworkRequest" code:100 userInfo:nil];
	}
	
    if (method != nil)
        _method = method;
    
    if (url != nil)
        _url = url;
	
    if (identifier != nil)
        _identifier = identifier;
	
    if (delegate != nil)
        _delegate = delegate;
    
    if (headers != nil)
        _headers = headers;
	
	return [self goWithData:data];
}

#pragma mark - Properties

-(void)setDelegate:(NSObject<BMRNetworkRequestDelegate> *)delegate {
	if (!_active)
		_delegate = delegate;
}

-(NSObject<BMRNetworkRequestDelegate>*)delegate {
	return _delegate;
}

-(void)setHeaders:(NSDictionary *)headers {
    if (!_active)
        _headers = headers;
}

-(void)setUrl:(NSURL*)url {
	if (!_active) {
		if ([url isKindOfClass:[NSURL class]])
			_url = (NSURL*)url;
		else if ([url isKindOfClass:[NSString class]])
			_url = [NSURL URLWithString:((NSString*)url)];
		else {
			NSLog(@"SFNetworkLoader: Warning, unrecognized type: %@ passed", [url class]);
			_url = nil;
		}
	}
}


-(void)setIdentifier:(NSObject *)identifier {
	if (!_active)
		_identifier = identifier;
}


-(void)setBuffer:(NSUInteger)buffer {
	if (!_active)
		_buffer = buffer;
}

-(void)setMethod:(NSString *)method {
    if (!_active)
        _method = method;
}

#pragma mark -
#pragma mark Delegates from NSURLRequest

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	_active = NO;
	_data = nil;
	NSDictionary *object = @{@"identifier": _identifier, @"error": error};
    
    if (_delegate != nil)
        if ([_delegate respondsToSelector:@selector(errorWithRequestForLoader:error:)])
            [_delegate errorWithRequestForLoader:self error:error];
    
	[[NSNotificationCenter defaultCenter] postNotificationName:BMRNetworkLoadNetworkError
														object:object];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[_data appendData:data];
	NSNumber *bytes = [NSNumber numberWithInt:[_data length]];
	if (_contentsize != -1) {
		NSNumber *total = [NSNumber numberWithInt:_contentsize];
		NSNumber *percentage = [NSNumber numberWithFloat:([_data length] / _contentsize)];
		
		NSDictionary *object = @{
            @"identifier": _identifier, @"total": total, @"bytes": bytes, @"percentage": percentage
        };
		
        if (_delegate != nil)
            if ([_delegate respondsToSelector:@selector(progressPercentageRequestForLoader:bytes:total:percentage:)])
                [_delegate progressPercentageRequestForLoader:self bytes:_data.length total:_contentsize percentage:_data.length/_contentsize];
        
		[[NSNotificationCenter defaultCenter] postNotificationName:BMRNetworkLoadProgressWithPercentage
															object:object];
        
	} else {
		NSDictionary *object = @{@"identifier": _identifier, @"bytes": bytes
        };

        if (_delegate != nil)
            if ([_delegate respondsToSelector:@selector(progressRequestForLoader:bytes:)])
                [_delegate progressRequestForLoader:self bytes:_data.length];
        
		[[NSNotificationCenter defaultCenter] postNotificationName:BMRNetworkLoadProgress
															object:object];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	NSNumber *headervalue = [[(NSHTTPURLResponse*)response allHeaderFields] objectForKey:@"Content-Size"];
    if ([response isKindOfClass:NSHTTPURLResponse.class]) {
        NSHTTPURLResponse *httpresponse = (NSHTTPURLResponse*)response;
        _httpStatus = httpresponse.statusCode;
    }
    
	if (headervalue != nil)
		_contentsize = [headervalue intValue];
	else
		_contentsize = -1;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	_active = NO;
	if (_delegate != nil)
        if ([_delegate respondsToSelector:@selector(completedRequestForLoader:data:)])
            [_delegate completedRequestForLoader:self data:_data];
    
	NSDictionary *object = @{@"identifier": _identifier, @"data": _data};
	
	[[NSNotificationCenter defaultCenter] postNotificationName:BMRNetworkLoadComplete object:object];
}


@end
