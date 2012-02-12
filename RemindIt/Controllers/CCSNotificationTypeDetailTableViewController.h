//
//  CCSNotificationTypeDetailTableViewController.h
//  CCSMobilePay
//
//  Created by Omer Cansizoglu on 1/19/12.
//  Copyright (c) 2012 Cash Cycle Solutions. All rights reserved.
//

#import <Three20/Three20.h>
#import <Three20/Three20+Additions.h>
#import "CCSUserNotificationType.h"
#import "TWTPickerControl.h"
#import "TWTDatePickerControl.h"
#import "CCSBarButtonItem.h"

@interface CCSNotificationTypeDetailTableViewController :  TTTableViewController <RKObjectLoaderDelegate>
{
    CCSUserNotificationType* _item;
     NSNumber* _notificationTypeID;
        UISwitch* _hasSms;
        UISwitch* _hasEmail;
        UISwitch* _hasPush;
        UISwitch* _hasVoice;
    
}

@property (nonatomic, retain)  CCSUserNotificationType* item;
@property (nonatomic, retain)  UISwitch* hasSms;
@property (nonatomic, retain)  UISwitch* hasEmail;
@property (nonatomic, retain)  UISwitch* hasPush;
@property (nonatomic, retain)  UISwitch* hasVoice;

@end
