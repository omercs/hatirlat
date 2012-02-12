//
//  CCSTabBarController.m
//  CCSMobilePay
//
//  Created by Scott Penrose on 8/18/11.
//  Copyright (c) 2011 Cash Cycle Solutions. All rights reserved.
//

#import "CCSTabBarController.h"

static CCSTabBarController* _controller;

@implementation CCSTabBarController

+ (CCSTabBarController*)sharedTabBarController {
    if (!_controller) {
        _controller = [[self alloc] init];
    }
    return _controller;
}

- (id)init {
    self = [super initWithStyle:TBKTabBarStyleDefault];
    if (self) {     
       
    }
    return self;
}

@end
