//
//  CCSSecuritySettingsTableViewController.m
//  CCSMobilePay
//
//  Created by Scott Penrose on 9/20/11.
//  Copyright (c) 2011 Cash Cycle Solutions. All rights reserved.
//

#import "CCSSecuritySettingsTableViewController.h"
#import "CCSPasscodeTableItem.h"
#import "CCSPasscodeTableCell.h"
#import "CCSTableControlCell.h"
#import "CCSSettingsTableCell.h"
#import "CCSSettingsImageTableCell.h"
#import "CCSPasscode.h"
#import "CCSApplicationService.h"
#import "CCSBarButtonItem.h"
#import "CCSUser.h"

////////////////////////////////////////////////////////////////////////
@interface CCSSecuritySettingsTableViewDataSource : TTSectionedDataSource {}
@end

@implementation CCSSecuritySettingsTableViewDataSource

- (Class)tableView:(UITableView *)tableView cellClassForObject:(id)object {
    if ([object isKindOfClass:[CCSPasscodeTableItem class]]) {
        return [CCSPasscodeTableCell class];
    }else if ([object isKindOfClass:[TTTableImageItem class]]) {
        return [CCSSettingsImageTableCell class];
    } else if ([object isKindOfClass:[TTTableTextItem class]]) {
        return [CCSSettingsTableCell class];
    } else if ([object isKindOfClass:[TTTableControlItem class]]) {
        return [CCSTableControlCell class];
    } else {
        return [super tableView:tableView cellClassForObject:object];
    }
}

@end

////////////////////////////////////////////////////////////////////////
@interface CCSSecuritySettingsTableViewDelegate : TTTableViewVarHeightDelegate {}
@end

@implementation CCSSecuritySettingsTableViewDelegate

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (section == 1) {
        NSString* timeout = ((CCSApplicationService*)[CCSApplicationService findFirstByAttribute:@"key" withValue:@"Timeout"]).value;
        
        UIView* view = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 50)] autorelease];
        UILabel* label = [[[UILabel alloc] initWithFrame:CGRectMake(20, 0, tableView.frame.size.width - 40, 50)] autorelease];
        label.text = [NSString stringWithFormat:@"You will be automatically logged out after %@ minutes", timeout];
        label.lineBreakMode = UILineBreakModeWordWrap;
        label.numberOfLines = 2;
        label.font = [UIFont systemFontOfSize:14];
        label.textAlignment = UITextAlignmentCenter;
        label.textColor = RGBACOLOR(119, 119, 119, 1);
        label.backgroundColor = [UIColor clearColor];
        [view addSubview:label];
        return view;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 1) {
        return 30;
    }
    return 0;
}

@end

////////////////////////////////////////////////////////////////////////
@implementation CCSSecuritySettingsTableViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Settings";
        self.tableViewStyle = UITableViewStyleGrouped;
        _autoLogout = [UISwitch new];
        _passcodeLabel = [UILabel new];
        _rememberUsername = [UISwitch new];
    }
    return self;
}

- (void)dealloc {
    [_autoLogout release];
    [_passcodeLabel release];
    [_rememberUsername release];
    [super dealloc];
}

#pragma mark UIViewController

-(void) loadView {
	[super loadView];
    
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 8, 0);
    self.tableView.backgroundColor = [UIColor clearColor];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background_without_status_bar.png"]];
    
    self.navigationItem.leftBarButtonItem = [CCSBarButtonItem backButton];
    
    _autoLogout.on = [[CCSUser currentUser] autoLogout];
    [_autoLogout addTarget:self action:@selector(autoLogoutSwitchTouched:) forControlEvents:UIControlEventValueChanged];
    _rememberUsername.on = [[CCSUser currentUser] rememberUsername];
    [_rememberUsername addTarget:self action:@selector(rememberUsernameSwitchTouched:) forControlEvents:UIControlEventValueChanged];
    _passcodeLabel.text = @"Yes";
}

-(NSString *) tabImageName {
	return @"settings";
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self invalidateModel];
}

#pragma mark - TTTableViewController

- (void)createModel {
    // Data source
    NSMutableArray* actionsSection = [NSMutableArray arrayWithCapacity:2];
    [actionsSection addObject:[CCSPasscodeTableItem itemWithCaption:@"Passcode" passcodeActive:[CCSPasscode passcodeOn] URL:@"ccs://settings/passcode"]];
    [actionsSection addObject:[TTTableControlItem itemWithCaption:@"Remember Username" control:_rememberUsername]];
    
    self.dataSource = [CCSSecuritySettingsTableViewDataSource dataSourceWithArrays:
                       @"",
                       actionsSection,
                       @"",
                       [NSArray arrayWithObject:[TTTableControlItem itemWithCaption:@"Auto Log Out" control:_autoLogout]],
                       nil];
}

- (id<UITableViewDelegate>)createDelegate {
    return [[[CCSSecuritySettingsTableViewDelegate alloc] initWithController:self] autorelease];
}

#pragma mark - Button methods

- (void)autoLogoutSwitchTouched:(id)sender {
    [[CCSUser currentUser] setAutoLogout:_autoLogout.on];
}

- (void)rememberUsernameSwitchTouched:(id)sender {
    [[CCSUser currentUser] setRememberUsername:_rememberUsername.on];
}

@end
