//
//  CCSTabBarController.m
//  RemindIt
//
//  Created by Omer Cansizoglu on 2/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
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
