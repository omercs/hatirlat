//
//  CCSLoadLockScreenViewController.m
//  CCSMobilePay
//
//  Created by Scott Penrose on 9/13/11.
//  Copyright (c) 2011 Cash Cycle Solutions. All rights reserved.
//

#import "CCSLoadLockScreenViewController.h"
#import "CCSBarButtonItem.h"
#import "CCSPasscode.h"
#import "CCSUser.h"

@implementation CCSLoadLockScreenViewController

#pragma mark - UIViewController

- (void)loadView {
    [super loadView];
    
    self.navigationItem.rightBarButtonItem = [[[CCSBarButtonItem alloc] initWithTitle:@"Forgot?" target:self action:@selector(forgotPasscode)] autorelease];
}

- (void)forgotPasscode {
    [self dismissModalViewControllerAnimated:NO];
    [CCSPasscode removePasscode];
    [[CCSUser currentUser] logout];
    [CCSUser clearUserData];
}

@end
