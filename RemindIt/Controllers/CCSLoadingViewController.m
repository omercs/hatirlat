//
//  CCSLoadingViewController.m
//  CCSMobilePay
//
//  Created by Scott Penrose on 9/15/11.
//  Copyright (c) 2011 Cash Cycle Solutions. All rights reserved.
//

#import "CCSLoadingViewController.h"
#import "CCSActivityLabel.h"

@implementation CCSLoadingViewController

- (void)loadView {
    [super loadView];
    self.view.backgroundColor = [UIColor clearColor];
    [CCSActivityLabel showActivityLabelWithText:@"Loading..." inView:self.view];
}

- (void)dealloc {
    [CCSActivityLabel hideActivityLabelInView:self.view];
    [super dealloc];
}

@end
