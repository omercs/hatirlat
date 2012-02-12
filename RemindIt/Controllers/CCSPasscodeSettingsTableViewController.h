//
//  CCSPasscodeSettingsTableViewController.h
//  CCSMobilePay
//
//  Created by Scott Penrose on 9/14/11.
//  Copyright (c) 2011 Cash Cycle Solutions. All rights reserved.
//

#import <Three20/Three20.h>
#import "CCSLoadLockScreenViewController.h"

@interface CCSPasscodeSettingsTableViewController : TTTableViewController <CCSLockScreenViewControllerDelegate> {
    UISwitch* _eraseData;
    BOOL _passcodeSuccess;
    
    NSString* _setPasscode;
    NSString* _setPasscodeRetype;
    
    UIView* _clearOverlayView;
}

@end
