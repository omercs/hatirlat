//
//  CCSSettingsTableViewController.m
//  CCSMobilePay
//
//  Created by Scott Penrose on 6/9/11.
//  Copyright 2011 Cash Cycle Solutions. All rights reserved.
//

#import "CCSSettingsTableViewController.h"
#import "CCSSettingsTableCell.h"
#import "CCSSettingsImageTableCell.h"
#import "CCSApplicationService.h"

////////////////////////////////////////////////////////////////////////
@interface CCSSettingsTableViewDataSource : TTSectionedDataSource {}
@end

@implementation CCSSettingsTableViewDataSource

- (Class)tableView:(UITableView *)tableView cellClassForObject:(id)object {
    if ([object isKindOfClass:[TTTableImageItem class]]) {
        return [CCSSettingsImageTableCell class];
    } else if ([object isKindOfClass:[TTTableTextItem class]]) {
        return [CCSSettingsTableCell class];
    } else {
        return [super tableView:tableView cellClassForObject:object];
    }
}

@end

////////////////////////////////////////////////////////////////////////
@interface CCSSettingsTableViewDelegate : TTTableViewVarHeightDelegate {}
@end

@implementation CCSSettingsTableViewDelegate
@end

////////////////////////////////////////////////////////////////////////
@implementation CCSSettingsTableViewController

- (id)init {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.title = @"Settings";
    }
    return self;
}

- (void)dealloc {
    [super dealloc];
}

#pragma mark UIViewController

-(void) loadView {
	[super loadView];
    
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 8, 0);
    self.tableView.backgroundColor = [UIColor clearColor];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background_without_status_bar.png"]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self invalidateModel];
}

-(NSString *) tabImageName {
	return @"settings";
}

#pragma mark - TTTableViewController

- (void)createModel {
    // Data source
    NSMutableArray* actionsSection = [NSMutableArray arrayWithCapacity:3];
    [actionsSection addObject:[TTTableImageItem itemWithText:@"Personal Profile" imageURL:@"bundle://account_settings.png" URL:@"ccs://accountSettings"]];
    [actionsSection addObject:[TTTableImageItem itemWithText:@"Payment Accounts" imageURL:@"bundle://payment_options.png" URL:@"ccs://fundingAccounts"]];
    [actionsSection addObject:[TTTableImageItem itemWithText:@"Security Settings" imageURL:@"bundle://passcode.png" URL:@"ccs://settings/security"]];
    [actionsSection addObject:[TTTableImageItem itemWithText:@"Notifications" imageURL:@"bundle://push_notifications.png" URL:@"ccs://settings/notifications"]];
    
    NSMutableArray* docsSection = [NSMutableArray arrayWithCapacity:2];
    [docsSection addObject:[TTTableTextItem itemWithText:@"FAQ/About" URL:((CCSApplicationService*)[CCSApplicationService findFirstByAttribute:@"key" withValue:@"FAQ"]).value]];
    [docsSection addObject:[TTTableTextItem itemWithText:@"Help" URL:((CCSApplicationService*)[CCSApplicationService findFirstByAttribute:@"key" withValue:@"Help"]).value]];
    if (((CCSApplicationService*)[CCSApplicationService findFirstByAttribute:@"key" withValue:@"Privacy"]).value &&
        ![((CCSApplicationService*)[CCSApplicationService findFirstByAttribute:@"key" withValue:@"Privacy"]).value isEqualToString:@""]) {
        [docsSection addObject:[TTTableTextItem itemWithText:@"Privacy" URL:((CCSApplicationService*)[CCSApplicationService findFirstByAttribute:@"key" withValue:@"Privacy"]).value]];
    }
    if (((CCSApplicationService*)[CCSApplicationService findFirstByAttribute:@"key" withValue:@"Term"]).value &&
        ![((CCSApplicationService*)[CCSApplicationService findFirstByAttribute:@"key" withValue:@"Term"]).value isEqualToString:@""]) {
        [docsSection addObject:[TTTableTextItem itemWithText:@"Terms" URL:((CCSApplicationService*)[CCSApplicationService findFirstByAttribute:@"key" withValue:@"Terms"]).value]];
    }

    self.dataSource = [CCSSettingsTableViewDataSource dataSourceWithArrays:
                       @"",
                       actionsSection,
                       @"",
                       docsSection,
                       nil];
}

@end
