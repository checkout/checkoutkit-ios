//
//  CardTokenResponse.m
//  checkoutObjC
//
//  Created by Nicolas on 30/03/2016.
//  Copyright © 2016 checkout.com. All rights reserved.
//

#import "CardTokenResponse.h"

@implementation CardTokenResponse


- (instancetype)initWithDictionary:(NSDictionary*)dictionary {
    if (self = [super init]) {
        self.cardToken = dictionary[@"id"];
        self.created = dictionary[@"created"];
        self.liveMode = dictionary[@"liveMode"];
        self.used = dictionary[@"used"];
    }
    return self;
}

@end
