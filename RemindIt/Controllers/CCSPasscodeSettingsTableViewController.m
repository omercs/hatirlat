//
//  CCSPasscodeSettingsTableViewController.m
//  CCSMobilePay
//
//  Created by Scott Penrose on 9/14/11.
//  Copyright (c) 2011 Cash Cycle Solutions. All rights reserved.
//

#import "CCSPasscodeSettingsTableViewController.h"
#import "CCSTableTextItemCell.h"
#import "CCSPasscodeTableButtonItem.h"
#import "CCSPasscodeTableTextItemCell.h"
#import "CCSTableControlCell.h"
#import "CCSBarButtonItem.h"
#import "CCSPasscode.h"
#import "CCSLockScreenViewController.h"
#import "CCSPasscodeTableControlCell.h"

static const NSInteger kCCSPasscodeUnlockTag = 100;
static const NSInteger kCCSPasscodeToggleOffTag = 101;
static const NSInteger kCCSPasscodeSetTag = 102;
static const NSInteger kCCSPasscodeSetRetypeTag = 103;
static const NSInteger kCCSPasscodeChangeTag = 104;

////////////////////////////////////////////////////////////////////////
@interface CCSPasscodeSettingsTableViewDataSource : TTSectionedDataSource {}
@end

@implementation CCSPasscodeSettingsTableViewDataSource

- (Class)tableView:(UITableView *)tableView cellClassForObject:(id)object {
    if ([object isKindOfClass:[CCSPasscodeTableButtonItem class]]) {
        return [CCSPasscodeTableTextItemCell class];
    } else if ([object isKindOfClass:[TTTableTextItem class]]) {
        return [CCSTableTextItemCell class];
    } else if ([object isKindOfClass:[TTTableControlItem class]]) {
        return [CCSPasscodeTableControlCell class];
    } else {
        return [super tableView:tableView cellClassForObject:object];
    }
}

@end

////////////////////////////////////////////////////////////////////////
@interface CCSPasscodeSettingsTableViewDelegate : TTTableViewDelegate {}
@end

@implementation CCSPasscodeSettingsTableViewDelegate

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (section == 2) {
        UIView* view = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 50)] autorelease];
        UILabel* label = [[[UILabel alloc] initWithFrame:CGRectMake(20, 0, tableView.frame.size.width - 40, 50)] autorelease];
        label.text = @"Log out and erase all data on this iPhone after 5 failed passcode attempts.";
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
    if (section == 2) {
        return 30;
    }
    return 0;
}

@end

////////////////////////////////////////////////////////////////////////
@interface CCSPasscodeSettingsTableViewController (Private)
- (void)setPasscode:(CCSLockScreenViewController*)lockScreenViewController;
- (void)setPasscodeRetype:(CCSLockScreenViewController*)lockScreenViewController;
- (void)changePasscode;
- (void)togglePasscode;
@end

@implementation CCSPasscodeSettingsTableViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Passcode";
        self.tableViewStyle = UITableViewStyleGrouped;
        _eraseData = [UISwitch new];
    }
    return self;
}

- (void)dealloc {
    [_eraseData release];
    [_setPasscode release];
    [_setPasscodeRetype release];
    [_clearOverlayView release];
    [super dealloc];
}

#pragma mark UIViewController

-(void) loadView {
	[super loadView];

    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 8, 0);
    self.tableView.backgroundColor = [UIColor clearColor];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background_without_status_bar.png"]];
    
    self.navigationItem.leftBarButtonItem = [CCSBarButtonItem backButton];
    
    _eraseData.on = [CCSPasscode eraseDataAfterSoManyFailedAttempts];
    [_eraseData addTarget:self action:@selector(eraseDataSwitchTouched) forControlEvents:UIControlEventValueChanged];
    
    _clearOverlayView = [[UIView alloc] initWithFrame:self.view.frame];
    [self.tableView addSubview:_clearOverlayView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ([CCSPasscode passcodeOn] && !_passcodeSuccess) {
        CCSLockScreenViewController* lockScreen = (CCSLockScreenViewController*)TTOpenURL(@"ccs://lockScreenCancelable");
        lockScreen.view.tag = kCCSPasscodeUnlockTag;
        lockScreen.title = @"Passcode";
        [lockScreen setPromptText:@"Enter Passcode"];
        lockScreen.delegate = self;
    } else {
        [_clearOverlayView removeFromSuperview];
    }
}

#pragma mark - TTTableViewController

- (id<UITableViewDelegate>)createDelegate {
    return [[[CCSPasscodeSettingsTableViewDelegate alloc] initWithController:self] autorelease];
}

- (void)createModel {   
    self.dataSource = [CCSPasscodeSettingsTableViewDataSource dataSourceWithObjects:
                       @"",
                       [TTTableButton itemWithText:([CCSPasscode passcodeOn] ? @"Turn Passcode Off" : @"Turn Passcode On") delegate:self selector:@selector(togglePasscode)],
                       @"",
                       [CCSPasscodeTableButtonItem itemWithText:@"Change Passcode" delegate:self selector:@selector(changePasscode)],
                       @"",
                       [TTTableControlItem itemWithCaption:@"Erase Data" control:_eraseData],
                       nil];
}

#pragma mark - Controls

- (void)eraseDataSwitchTouched {
    NSLog(@"Erase data switch touched");
    [CCSPasscode setEraseDataAfterSoManyFailedAttempts:_eraseData.on];
}

#pragma mark - Passcode

- (void)togglePasscode {
    if ([CCSPasscode passcodeOn]) {
        NSLog(@"Toggle passcode off");
        CCSLockScreenViewController* lockScreen = (CCSLockScreenViewController*)TTOpenURL(@"ccs://lockScreenCancelable");
        lockScreen.view.tag = kCCSPasscodeToggleOffTag;
        lockScreen.title = @"Passcode";
        [lockScreen setPromptText:@"Enter Passcode"];
        lockScreen.delegate = self;
    } else {
        NSLog(@"Toggle passcode on");
        [self setPasscode:nil];
    }
}

- (void)changePasscode {
    if ([CCSPasscode passcodeOn]) {
        NSLog(@"Change passcode");
        [self setPasscode:nil];
    }
}

- (void)setPasscode:(CCSLockScreenViewController*)lockScreenViewController {
    _setPasscode = @"";
    _setPasscodeRetype = @"";
    
    CCSLockScreenViewController* lockScreen = lockScreenViewController;
    if (nil == lockScreen) {
        lockScreen = (CCSLockScreenViewController*)TTOpenURL(@"ccs://lockScreenCancelable");
    }
    [lockScreen clearPasscode];
    [lockScreen clearErrorMessage];
    lockScreen.view.tag = kCCSPasscodeSetTag;
    lockScreen.title = @"Passcode";
    [lockScreen setPromptText:@"Set Passcode"];
    lockScreen.delegate = self;
}

- (void)setPasscodeRetype:(CCSLockScreenViewController*)lockScreenViewController {
    [lockScreenViewController clearPasscode];
    [lockScreenViewController clearErrorMessage];
    lockScreenViewController.view.tag = kCCSPasscodeSetRetypeTag;
    lockScreenViewController.title = @"Passcode";
    [lockScreenViewController setPromptText:@"Re-type Passcode"];
    lockScreenViewController.delegate = self;
}

#pragma mark - CCSLockScreenViewControllerDelegate

- (void)lockScreenViewController:(CCSLockScreenViewController *)lockScreenViewController didSubmitPasscode:(NSString *)passcode {
    [_clearOverlayView removeFromSuperview];
    if (lockScreenViewController.view.tag == kCCSPasscodeUnlockTag) {
        if ([CCSPasscode correctPasscode:passcode]) {
            _passcodeSuccess = YES;
            [lockScreenViewController dismissModalViewControllerAnimated:YES];
        } else {
            [lockScreenViewController invalidPasscodeSubmittedWithErrorText:@"Invalid passcode. Try again."];
        }
    } else if (lockScreenViewController.view.tag == kCCSPasscodeToggleOffTag) {
        if ([CCSPasscode correctPasscode:passcode]) {
            [CCSPasscode removePasscode];
            [self invalidateModel];
            [lockScreenViewController dismissModalViewControllerAnimated:YES];
            [[self navigationController] popViewControllerAnimated:YES];
        } else {
            [lockScreenViewController invalidPasscodeSubmittedWithErrorText:@"Invalid passcode. Try again."];
        }
    } else if (lockScreenViewController.view.tag == kCCSPasscodeSetTag) {
        _setPasscode = [passcode copy];
        [self setPasscodeRetype:lockScreenViewController];
    } else if (lockScreenViewController.view.tag == kCCSPasscodeSetRetypeTag) {
        if ([_setPasscode isEqualToString:passcode]) {
            _passcodeSuccess = YES;
            [CCSPasscode setPasscode:_setPasscode];
            [self invalidateModel];
            [lockScreenViewController dismissModalViewControllerAnimated:YES];
        } else {
            [lockScreenViewController invalidPasscodeSubmittedWithErrorText:@"Passcodes did not match. Try again."];
        }
    } else if (lockScreenViewController.view.tag == kCCSPasscodeChangeTag) {
        if ([CCSPasscode correctPasscode:passcode]) {
            _passcodeSuccess = YES;
            [self invalidateModel];
            [self setPasscode:lockScreenViewController];
        } else {
            [lockScreenViewController invalidPasscodeSubmittedWithErrorText:@"Invalid passcode. Try again."];
        }
    }
}

- (void)lockScreenViewControllerDidCancel:(CCSLockScreenViewController *)lockScreenViewController {
    [[self navigationController] popViewControllerAnimated:YES];
}

@end
