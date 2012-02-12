//
//  CCSSecuritySettingsTableViewController.h
//  CCSMobilePay
//
//  Created by Scott Penrose on 9/20/11.
//  Copyright (c) 2011 Cash Cycle Solutions. All rights reserved.
//

#import <Three20/Three20.h>
#import <RestKit/Three20/Three20.h>

@interface CCSSecuritySettingsTableViewController : TTTableViewController{
    UISwitch* _autoLogout;
    UISwitch* _rememberUsername;
    UILabel* _passcodeLabel;
}

@end
