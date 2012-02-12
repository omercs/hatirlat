//
//  CCSLockScreenCancelViewController.m
//  CCSMobilePay
//
//  Created by Scott Penrose on 9/14/11.
//  Copyright (c) 2011 Cash Cycle Solutions. All rights reserved.
//

#import "CCSLockScreenCancelViewController.h"

@implementation CCSLockScreenCancelViewController

#pragma mark - UIViewController

- (void)loadView {
    [super loadView];
    
    CCSBarButtonItem* cancel = [[[CCSBarButtonItem alloc] initWithTitle:@"Cancel" target:self action:@selector(cancelButtonPressed)] autorelease];
    self.navigationItem.rightBarButtonItem = cancel;
}

#pragma mark - Button Actions

- (void)cancelButtonPressed {
    if ([self.delegate respondsToSelector:@selector(lockScreenViewControllerDidCancel:)]) {
        [self dismissModalViewControllerAnimated:YES];
        [self.delegate lockScreenViewControllerDidCancel:self];
    }
}

@end
