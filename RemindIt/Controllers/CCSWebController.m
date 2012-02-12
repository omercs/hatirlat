//
//  CCSWebController.m
//  CCSMobilePay
//
//  Created by Jeremy Ellison on 7/29/11.
//  Copyright 2011 Cash Cycle Solutions. All rights reserved.
//

#import "CCSWebController.h"
#import "CCSBarButtonItem.h"
#import <Three20/Three20+Additions.h>

@implementation CCSWebController

- (void)loadView {
    [super loadView];
    [_toolbar removeFromSuperview];
    self.navigationItem.leftBarButtonItem = [[[CCSBarButtonItem alloc]initWithTitle:@"Close" target:self action:@selector(dismiss)] autorelease];
}

- (void)updateToolbarWithOrientation:(UIInterfaceOrientation)interfaceOrientation {
    _webView.height = self.view.height;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dismiss {
    [[[TTNavigator navigator].topViewController navigationController] popViewControllerAnimated:YES];
}


@end
