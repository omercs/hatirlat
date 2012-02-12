//
//  CCSLogoutTableViewController.m
//  CCSMobilePay
//
//  Created by Scott Penrose on 9/1/11.
//  Copyright (c) 2011 Cash Cycle Solutions. All rights reserved.
//

#import "CCSLogoutTableViewController.h"
#import "CCSUser.h"
#import "CCSBarButtonItem.h"

@implementation CCSLogoutTableViewController

- (id)init {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.title = @"Log out";
    }
    return self;
}

-(NSString *) tabImageName {
	return @"logout";
}

@end
