//
//  CheckoutKitObjC.m
//  checkoutObjC
//
//  Created by Nicolas on 22/03/2016.
//  Copyright © 2016 checkout.com. All rights reserved.
//

#define SANDBOX @"https://sandbox.checkout.com/api2/v2/"
#define LIVE @"https://api2.checkout.com/v2/"

#import "CheckoutKitObjC.h"

@import UIKit;

@implementation CheckoutKitObjC

@synthesize publicKey;
@synthesize environment;


static CheckoutKitObjC *sharedCheckoutKit = nil;

+ (id)checkoutKitInstance {
    static CheckoutKitObjC *myCheckoutKitInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        myCheckoutKitInstance = [[self alloc] init];
    });
    return myCheckoutKitInstance;
}

- (id)init {
    if ( (self = [super init]) ) {
        environment = LIVE;
    }
    return self;
}

- (void) setPublicKey:(NSString *)publicKeyParam
{
    publicKey = publicKeyParam;
}

- (void) setEnvironment:(NSString *)environmentParam
{
    if ([environmentParam isEqualToString:@"SANDBOX"])
    {
        environment = SANDBOX;
    }
    else
    {
        environment = LIVE;
    }
}


- (void)dealloc {

}


- (void)createCardToken:(Card*) card success : (void (^)(CardTokenResponse *responseDict))success failure:(void(^)(NSError* error))failure{
    
    NSError *e = nil;

    NSData *postBody = [NSJSONSerialization dataWithJSONObject:[card getJson] options:NSUTF8StringEncoding error: &e];

    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    sessionConfiguration.HTTPAdditionalHeaders = @{
                                                   @"Content-Type"       : @"application/json",
                                                   @"AUTHORIZATION"      : publicKey
                                                   };
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
    NSURL *url = [NSURL URLWithString:[environment stringByAppendingString:@"tokens/card"]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPBody = postBody;
    request.HTTPMethod = @"POST";
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        // The server answers with an error because it doesn't receive the params
        if (!error) {
            NSHTTPURLResponse *httpResp = (NSHTTPURLResponse*) response;
            if (httpResp.statusCode == 200) {
                // 3
                
                NSError *jsonError;
                NSDictionary *responseJSON = [NSJSONSerialization
                                         JSONObjectWithData:data
                                         options:0
                                         error:&jsonError];
                
                CardTokenResponse *cardTokenResponse = [[CardTokenResponse alloc] initWithDictionary:responseJSON];
                
                success(cardTokenResponse);
                
            } else {
                NSError *jsonError;
                NSDictionary *responseJSON = [NSJSONSerialization
                                              JSONObjectWithData:data
                                              options:0
                                              error:&jsonError];
                failure(jsonError);
            }
        } else {
            failure(error);
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        });
    }];
    [postDataTask resume];
}


- (void)getCardProviders: (void (^)(CardProviderResponse *responseDict))success failure:(void(^)(NSError* error))failure{
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    sessionConfiguration.HTTPAdditionalHeaders = @{
                                                   @"Content-Type"       : @"application/json",
                                                   @"AUTHORIZATION"      : publicKey
                                                   };
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
    NSURL *url = [NSURL URLWithString:[environment stringByAppendingString:@"providers/cards"]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"GET";
    NSURLSessionDataTask *getDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            NSHTTPURLResponse *httpResp = (NSHTTPURLResponse*) response;
            if (httpResp.statusCode == 200) {
                
                NSError *jsonError;
                NSDictionary *responseJSON = [NSJSONSerialization
                                              JSONObjectWithData:data
                                              options:0
                                              error:&jsonError];
                
                CardProviderResponse *cardProviderResponse = [[CardProviderResponse alloc] initWithDictionary:responseJSON];
                
                success(cardProviderResponse);
                
            } else {
                NSError *jsonError;
                NSDictionary *responseJSON = [NSJSONSerialization
                                              JSONObjectWithData:data
                                              options:0
                                              error:&jsonError];
                failure(jsonError);
            }
        } else {
            failure(error);
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        });
        
    }];
    [getDataTask resume];
}

@end
