//
//  CCSNotificationTypeDetailTableViewController.m
//  CCSMobilePay
//
//  Created by Omer Cansizoglu on 1/19/12.
//  Copyright (c) 2012 Cash Cycle Solutions. All rights reserved.
//

#import "CCSNotificationTypeDetailTableViewController.h"
#import "CCSPickerTableControlCell.h"
#import "CCSPickerTableControlItem.h"
#import "CCSActivityLabel.h"
#import "CCSTableTextItemCell.h"
#import "CCSTableButtonItem.h"
#import "CCSBarButtonItem.h"
#import "CCSBlankTableCell.h"
#import "CCSBlankTableItem.h"
#import "CCSTableControlCell.h"
#import "CCSBarButtonItem.h"
#import "CCSCustomField.h"
 
#import "CCSLockedTableControlCell.h"
#import "CCSLockedTableControlItem.h"
#import "CCSTabBarController.h"

#import "CCSNotificationSetting.h"
#import "CCSUserNotificationType.h"

static const NSInteger kCCSMonthPickerTag = 402;



////////////////////////////////////////////////////////////////////////
@interface CCSNotificationTypeDetailTableViewDataSource : TTSectionedDataSource {}
@end

@implementation CCSNotificationTypeDetailTableViewDataSource

- (Class)tableView:(UITableView *)tableView cellClassForObject:(id)object {
    if ([object isKindOfClass:[CCSLockedTableControlItem class]]) {
        return [CCSLockedTableControlCell class];
    } else if([object isKindOfClass:[TTTableControlItem class]]) {
        return [CCSTableControlCell class];
    } else {
        return [super tableView:tableView cellClassForObject:object];
    }
}
@end

@interface CCSNotificationTypeDetailTableViewDelegate : TTTableViewVarHeightDelegate {}
@end


@implementation CCSNotificationTypeDetailTableViewDelegate



- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 20;
}



@end

@implementation CCSNotificationTypeDetailTableViewController

@synthesize item=_item, hasSms=_hasSms,hasEmail=_hasEmail,hasPush=_hasPush,hasVoice=_hasVoice;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {        
        [self commonInit];
    }
    return self;
}

- (id)initWithTypeID:(NSNumber*)itemID {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {        
        _notificationTypeID = [itemID retain];
        [self commonInit];
    }
    return self;
}

- (void)itemUpdate{
    _item = (CCSUserNotificationType*)[[CCSUserNotificationType findFirstByAttribute:@"typeID" withValue:_notificationTypeID] retain];

}

- (void)commonInit{
    [self itemUpdate];
    
    self.tableViewStyle = UITableViewStyleGrouped;
     _hasEmail = [UISwitch new];
     _hasPush = [UISwitch new];
     _hasVoice = [UISwitch new];
     _hasSms = [UISwitch new];
}
- (void)dealloc {

    [_hasSms release];
    [_hasEmail release];
    [_hasVoice release];
    [_hasPush release];
    [_item release];
    [super dealloc];
}


- (void)loadView {
    [super loadView];    
    
    self.title = @"Payment Account";
    //back button with action
    CCSBarButtonItem* savebutton = [[[CCSBarButtonItem alloc] initWithTitle:@"Back" target:self action:@selector(saveAccountSettings) backButton:TRUE]  autorelease];
   // self.navigationItem.leftBarButtonItem = savebutton;
    self.navigationItem.leftBarButtonItem = [CCSBarButtonItem backButton];
        self.tableView.backgroundColor = [UIColor clearColor];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background_without_status_bar.png"]];
    
    self.autoresizesForKeyboard = YES;
    
    [_hasEmail addTarget:self action:@selector(optionSwitchTouched) forControlEvents:UIControlEventValueChanged];
    [_hasPush addTarget:self action:@selector(optionSwitchTouched) forControlEvents:UIControlEventValueChanged];
    [_hasVoice addTarget:self action:@selector(optionSwitchTouched) forControlEvents:UIControlEventValueChanged];
    [_hasSms addTarget:self action:@selector(optionSwitchTouched) forControlEvents:UIControlEventValueChanged];
    
     [self setupDataSource];
}


- (void)viewDidUnload {
    [super viewDidUnload];
    [[RKRequestQueue sharedQueue] cancelRequestsWithDelegate:self];
}

- (void)setupDataSource{
    _hasEmail.on = _item.hasEmail.boolValue;
    _hasPush.on = _item.hasPush.boolValue;
    _hasVoice.on = _item.hasVoice.boolValue;
    _hasSms.on = _item.hasSms.boolValue;
    
             self.dataSource = [CCSNotificationTypeDetailTableViewDataSource dataSourceWithObjects:
                      @"",
                   [TTTableControlItem itemWithCaption:@"Email" control:    _hasEmail],
                   [TTTableControlItem itemWithCaption:@"Sms" control:    _hasSms],
                   [TTTableControlItem itemWithCaption:@"Voice" control:    _hasVoice],
                       [TTTableControlItem itemWithCaption:@"Push" control:    _hasPush],
                       nil];
    
}

- (void)loadData {
   //do nothing for now
   
}

- (void)dismiss {
    [CCSActivityLabel hideActivityLabelInView:self.tableView];
    [self dismissModalViewControllerAnimated:YES];
}

- (void)optionSwitchTouched {
    _item.hasEmail =  [NSNumber numberWithBool:_hasEmail.on] ;
    _item.hasSms = [NSNumber numberWithBool:_hasSms.on];
    _item.hasVoice = [NSNumber numberWithBool:_hasVoice.on];
    _item.hasPush = [NSNumber numberWithBool:_hasPush.on];
    NSError* error = nil;
    
     
    [[_item managedObjectContext] save:&error];
    if (nil != error) {
        NSLog(@"Error saving notification type context: %@", error);
    }
    NSLog(@"option update");
    
}

#pragma mark - TTTableView methods

- (id<UITableViewDelegate>)createDelegate {
    return [[[CCSNotificationTypeDetailTableViewDelegate alloc] initWithController:self] autorelease];
}

#pragma mark - RKObjectLoaderDelegate Methods

- (void)objectLoader:(RKObjectLoader*)objectLoader didFailWithError:(NSError*)error {
    [CCSErrorHelper displayAlertViewForError:error];
    [CCSActivityLabel hideActivityLabelInView:self.tableView];
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didLoadObjects:(NSArray*)objects {    
    // Billing account successfully deleted. Delete core data object
  
            NSLog(@"calling didLoadObjects");
         }

@end
