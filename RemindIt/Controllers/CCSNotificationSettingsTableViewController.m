//
//  CCSNotificationSettingsTableViewController.m
//  CCSMobilePay
//
//  Created by Omer Cansizoglu on 1/15/12.
//  Copyright (c) 2012 Cash Cycle Solutions. All rights reserved.
//

#import "CCSNotificationSettingsTableViewController.h"
 
#import "CCSPickerTableControlCell.h"
#import "CCSPickerTableControlItem.h"
#import "CCSActivityLabel.h"
#import "CCSTableTextItemCell.h"
#import "CCSTableButtonItem.h"
#import "CCSBarButtonItem.h"
#import "CCSBlankTableCell.h"
#import "CCSBlankTableItem.h"
#import "CCSNotificationSetting.h"
#import "CCSUserNotificationType.h"

static const NSInteger kCCSMonthPickerTag = 402;



////////////////////////////////////////////////////////////////////////
@interface CCSNotificationSettingsTableViewDataSource : TTSectionedDataSource {}
@end

@implementation CCSNotificationSettingsTableViewDataSource

- (Class)tableView:(UITableView *)tableView cellClassForObject:(id)object {
    if ([object isKindOfClass:[CCSBlankTableItem class]]) {
        return [CCSBlankTableCell class];
    } else if ([object isKindOfClass:[TTTableTextItem class]]) {
        return [CCSTableTextItemCell class];
    } else if ([object isKindOfClass:[CCSPickerTableControlItem class]]) {
        return [CCSPickerTableControlCell class];
    } else if ([object isKindOfClass:[TTTableControlItem class]]) {
        return [CCSTableControlCell class];

    } else {
        return [super tableView:tableView cellClassForObject:object];
    }
}

@end

@interface CCSNotificationSettingsTableViewDelegate : TTTableViewVarHeightDelegate {}
@end


@implementation CCSNotificationSettingsTableViewDelegate

 

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 20;
}

 

@end





///////////////////////////////////////////////////

@implementation CCSNotificationSettingsTableViewController
@synthesize notifications=_notifications,notificationSetup=_notificationSetup;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
         [self commonInit];
    }
    
    return self;
}

- (void)commonInit{
     self.tableViewStyle = UITableViewStyleGrouped;
    
    _monthPicker = [[TWTPickerControl alloc] initWithFrame:CGRectZero];
    _monthPicker.delegate = self;
    _monthPicker.tag = kCCSMonthPickerTag;
}

- (void)loadView {
    [super loadView];    
    
    self.title = @"Notifications";
    self.navigationItem.leftBarButtonItem = [CCSBarButtonItem backButton];
    self.navigationItem.rightBarButtonItem = [[[CCSBarButtonItem alloc] initWithTitle:@"Save" target:self action:@selector(doneButtonTouched)] autorelease];
    
    self.tableView.backgroundColor = [UIColor clearColor];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background_without_status_bar.png"]];
    
    [self setupPickerData];
    [self loadData];
}

- (void)setupPickerData {
    NSMutableArray* monthFields = [NSMutableArray arrayWithCapacity:12];
    for (int month = 01; month <= 12; month++) {
        [monthFields addObject:[NSString stringWithFormat:@"%02d", month]];
    }
    TWTPickerDataSource* expirationDateDataSource = [[TWTPickerDataSource alloc] initWithComponents:[NSArray arrayWithObjects:monthFields, nil]];
    _monthPicker.dataSource = expirationDateDataSource;
    _monthPicker.textLabel.textAlignment = UITextAlignmentRight;
    _monthPicker.selection = [NSMutableArray arrayWithObjects:[monthFields objectAtIndex:0],  nil];
    _monthPicker.showsToolbar = NO;
    _monthPicker.frame = CGRectMake(0,0,100,40);
   
}



-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];    
}

- (void)viewDidUnload {
    [super viewDidUnload];
    [[RKRequestQueue sharedQueue] cancelRequestsWithDelegate:self];
}


- (void)loadObjectsFromDataStore {
     
    _notifications = [_notificationSetup.usernotificationTypes retain];
    
    NSMutableArray* fundingAccountItems = [NSMutableArray arrayWithCapacity:[_notifications count]];
    for (CCSUserNotificationType* ntype in _notifications) {
        //NSLog(@"typeid %@ label %@", [ntype.typeID stringValue],ntype.label);
        
        [fundingAccountItems addObject:[TTTableTextItem itemWithText:ntype.label URL:[NSString stringWithFormat:@"ccs://notificationDetailPage/%@", ntype.typeID]]];
    }
    
    // Default seperatorColor
    //NSLog(@"UIColor: %@", self.tableView.separatorColor);
    
    self.tableView.separatorColor = [UIColor colorFromRGBIntegers:202 green:202 blue:202 alpha:1];
    
    if ([fundingAccountItems count] == 0) {
        [fundingAccountItems addObject:[CCSBlankTableItem itemWithText:@""]];
        self.tableView.separatorColor = [UIColor clearColor];
    }
    
    //find selected value
    NSArray* expirationMonthArray = [_monthPicker.dataSource.components objectAtIndex:0];
    NSUInteger expirationMonthSelectedIndex = NSNotFound;
    for (int i = 0; i < [expirationMonthArray count]; i++) {
        NSString* month = [expirationMonthArray objectAtIndex:i];
        NSString* lookingForMonth = [NSString stringWithFormat:@"%02d", [_notificationSetup.messageLifeTime intValue]];
        if ([month isEqualToString: lookingForMonth]) {
            expirationMonthSelectedIndex = i;
            break;
        }
    }
    //set selected lifetime value
    if (expirationMonthSelectedIndex != NSNotFound) {
        _monthPicker.selection = [NSMutableArray arrayWithObjects:[[_monthPicker.dataSource.components objectAtIndex:0] objectAtIndex:expirationMonthSelectedIndex], nil];
    } 
     NSArray* commonItems = nil;
    commonItems = [NSArray arrayWithObjects:
                    [CCSPickerTableControlItem itemWithCaption:@"Message Life Time" control:_monthPicker],
                   nil];
    
    
        
    self.dataSource = [CCSNotificationSettingsTableViewDataSource dataSourceWithArrays:
                       @"",
                       fundingAccountItems,
                       @"",
                      commonItems,
                       nil];
    
}

- (void)loadData {
    [[RKObjectManager sharedManager] loadObjectsAtResourcePath:@"/notification_setup/"   delegate:self];
}

#pragma mark - TTTableView methods

- (id<UITableViewDelegate>)createDelegate {
    return [[[CCSNotificationSettingsTableViewDelegate alloc] initWithController:self] autorelease];
}

#pragma mark - RKObjectLoaderDelegate Methods

- (void)objectLoader:(RKObjectLoader*)objectLoader didFailWithError:(NSError*)error {
    [CCSErrorHelper displayAlertViewForError:error];
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didLoadObjects:(NSArray*)objects {
    NSLog(@"Notification reload: %@", [objectLoader.response bodyAsString]);
    
    if ([objectLoader.resourcePath isEqualToString:@"/notification_setup/"] &&
        objectLoader.method == RKRequestMethodGET)
    {
        if([objects count] > 0)
        {
            _notificationSetup = [[objects objectAtIndex:0] retain];  
            /*NSLog(@"message time: %@", [NSString stringWithFormat:@"%d", _notificationSetup.messageLifeTime])   ;
            if([_notificationSetup.usernotificationTypes count] > 0)
            {
                
                _notifications =[ _notificationSetup.usernotificationTypes retain];
                 NSInteger counti = [_notifications count];
                counti = [CCSUserNotificationType count];
                
            }*/
            
            [self loadObjectsFromDataStore];
            return;
            
        }
    }
    
     [self dismiss];    
    
}

- (void)dismiss {
    [CCSActivityLabel hideActivityLabelInView:self.tableView];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)doneButtonTouched{
    NSLog(@"Done button touched");
    
    
    RKObjectLoader* loader = [[RKObjectManager sharedManager] objectLoaderWithResourcePath:@"/notification_setup/" delegate:self];
    loader.method = RKRequestMethodPUT;
    //test objects
    
    
    NSMutableDictionary* params;
    NSMutableDictionary* paramsSub;     
    NSMutableArray* nestedObjects = [NSMutableArray arrayWithCapacity:4]; 
    NSError *error = nil;
    //get all db items and post those
    NSArray* dbrecordeditems = [CCSUserNotificationType allObjects];
    
    
    NSInteger counti = [dbrecordeditems count];
    for (int i = 0; i < counti; i++) {
        CCSUserNotificationType* nt  = [dbrecordeditems objectAtIndex:i] ;
        NSLog(@"typeid %@ label %@", [nt.typeID stringValue],nt.label);
        
        
        if(nt)
        {
            //parse each setting object value
            paramsSub =[NSMutableDictionary dictionaryWithObjectsAndKeys:
                        nt.typeID,@"TypeId",
                        nt.hasEmail,@"HasEmail",
                        nt.hasSms,@"HasSms",
                        nt.hasVoice,@"HasVoice",
                        nt.hasPush,@"HasPush",
                        nil ];
            [nestedObjects addObject:paramsSub];
            
        }                        
        
    } 
    
    params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
              _monthPicker.selectionText, @"MessageLifeTime",
              nestedObjects, @"NotificationTypesSend",
              
              nil];
    
    
    params = [NSDictionary dictionaryWithObjectsAndKeys:params, @"notificationsettings", nil];
    id<RKParser> parser = [[RKParserRegistry sharedRegistry] parserForMIMEType:@"application/json"];
    
    NSString* string = [parser stringFromObject:params error:&error];
    
    NSLog(@"PArsed string: %@", string);
    if (nil == string) {
        // TODO hand serialization error
        NSLog(@"Error: %@", error);
        return;
    }
    
    [loader.additionalHTTPHeaders setValue:@"application/json" forKey:@"Content-Type"];
    loader.HTTPBody = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    [loader send];
    [CCSActivityLabel showActivityLabelWithText:@"Saving..." inView:self.tableView];
   
}

- (void)picker:(TWTPickerControl*)picker didShowPicker:(UIView*)pickerView {
    self.tableView.frame = UIEdgeInsetsInsetRect(self.view.bounds, UIEdgeInsetsMake(0, 0, pickerView.bounds.size.height, 0));
    [self.tableView scrollFirstResponderIntoView];
}

- (void)picker:(TWTPickerControl*)picker didHidePicker:(UIView*)pickerView {
    UIResponder* responder = [self.tableView.window findFirstResponder];
    if (nil == responder) {
        self.tableView.frame = self.view.bounds;
    }
}

- (void)keyboardWillDisappear:(BOOL)animated withBounds:(CGRect)bounds {
    UIResponder* responder = [self.tableView.window findFirstResponder];
    if (nil == responder) {
        [super keyboardWillDisappear:animated withBounds:bounds];
    }
}

- (void)keyboardDidDisappear:(BOOL)animated withBounds:(CGRect)bounds {
    UIResponder* responder = [self.tableView.window findFirstResponder];
    if (nil == responder) {
        [super keyboardWillDisappear:animated withBounds:bounds];
    }
}

- (void)dealloc {
    NSLog(@"dealloc for main notif type is called");
    [_monthPicker release];
    [_notifications release];
    [_notificationSetup release];
        [super dealloc];
    NSLog(@"dealloc for main notif type is finished");
}

@end
