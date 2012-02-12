//
//  CCSNotificationSettingsTableViewController.h
//  CCSMobilePay
//
//  Created by Omer Cansizoglu on 1/15/12.
//  Copyright (c) 2012 Cash Cycle Solutions. All rights reserved.
//
#import <Three20/Three20.h>
#import <RestKit/Three20/Three20.h>
#import "TWTPickerControl.h"
#import "CCSNotificationSetting.h"
@interface CCSNotificationSettingsTableViewController  : TTTableViewController <RKObjectLoaderDelegate,TWTPickerDelegate>{
    TWTPickerControl* _monthPicker;
    NSArray* _notifications;
    CCSNotificationSetting* _notificationSetup;
     
}

@property (nonatomic, retain) NSArray* notifications;
@property (nonatomic, retain) CCSNotificationSetting* notificationSetup;

- (void)dismiss;
- (void)setupPickerData;
- (void)loadData;
- (void)commonInit;
@end