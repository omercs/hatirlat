//
//  AppDelegate.m
//  RemindIt
//
//  Created by Omer Cansizoglu on 2/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import <Three20/Three20.h>
#import <RestKit/RestKit.h>
#import <RestKit/CoreData/CoreData.h>

#import "UAirship.h"
#import "UAPush.h"

#import "MessagesController.h"
#import "SchedulesController.h"
#import "AccountController.h"
#import "ContactsController.h"
#import "CCSWebController.h"
#import "CCSWelcomeViewController.h"
#import "CCSLoadingViewController.h"
#import "CCSLoadLockScreenViewController.h"

@interface AppDelegate ()

@property (nonatomic, assign) CCSTabBarController* tabBarController;
- (void)setupTabBarTabs;

@end

@implementation CCSMobilePayAppDelegate

@synthesize tabBarController;

#pragma mark Shared Delegate

+(CCSMobilePayAppDelegate *) sharedApplicationDelegate {
	return (CCSMobilePayAppDelegate *)[UIApplication sharedApplication].delegate;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Customize Status bar and background
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
    [TTNavigator navigator].window.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background_with_status_bar.png"]];
    
    // Controllers setup
    _credentialObserver = [[CCSCredentialObserver alloc] init];
    
    
    // Setup RestKit
    [self setupRestKit];
    
    // Navigator Setup
    TTNavigator *sharedNavigator        = [TTNavigator navigator];
    sharedNavigator.delegate            = self;
    TTURLMap *navigationMap        = sharedNavigator.URLMap;
    // Tab Bar setup
    self.tabBarController = [CCSTabBarController sharedTabBarController];
    self.tabBarController.delegate = self;
    [self setupTabBarTabs];
    
    [navigationMap from:@"ccs://tabbar" toSharedViewController:self.tabBarController]; 
    
    [navigationMap from:@"ccs://welcome" toModalViewController:[CCSWelcomeViewController class]];
    
    [navigationMap from:@"ccs://loading" toViewController:[CCSLoadingViewController class]];

    //launch testflight sdk remove for production
    [TestFlight takeOff:@"e99520fb83714504b89d6522355b187e_NjE3OTAyMDEyLTAyLTExIDIzOjQ1OjA1Ljk1OTgzMQ"];
    
    //setup Urban Airship
    
    //Init Airship launch options
    NSMutableDictionary *takeOffOptions = [[[NSMutableDictionary alloc] init] autorelease];
    [takeOffOptions setValue:launchOptions forKey:UAirshipTakeOffOptionsLaunchOptionsKey];
    
    NSMutableDictionary *airshipConfigOptions = [[[NSMutableDictionary alloc] init] autorelease];
    //Development urban codes
    [airshipConfigOptions setValue:@"devappkey" forKey:@"DEVELOPMENT_APP_KEY"];
    [airshipConfigOptions setValue:@"devappsecret" forKey:@"DEVELOPMENT_APP_SECRET"];
    [airshipConfigOptions setValue:@"pr" forKey:@"PRODUCTION_APP_KEY"];
    [airshipConfigOptions setValue:@"19Q" forKey:@"PRODUCTION_APP_SECRET"];
   
    
#ifdef DEBUG
    [airshipConfigOptions setValue:@"NO" forKey:@"APP_STORE_OR_AD_HOC_BUILD"];
#else
    [airshipConfigOptions setValue:@"YES" forKey:@"APP_STORE_OR_AD_HOC_BUILD"];
#endif
    
    [takeOffOptions setValue:airshipConfigOptions forKey:UAirshipTakeOffOptionsAirshipConfigKey];
    
    // Create Airship singleton that's used to talk to Urban Airship servers.
    // Please populate AirshipConfig.plist with your info from http://go.urbanairship.com
    [UAirship takeOff:takeOffOptions];
    
    //zero badge on startup
    [[UAPush shared] resetBadge];
    
    // Register for notifications through UAPush for notification type tracking
    [[UAPush shared] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                         UIRemoteNotificationTypeSound |
                                                         UIRemoteNotificationTypeAlert)];
    
    TTOpenURL(@"ccs://loading");
    
    // Try and see if we should autoLogout
    BOOL autoLogout = [[CCSUser currentUser] performAutoLogout];
    
    if (!autoLogout) {
        // Show passcode screen
        if ([CCSPasscode passcodeOn] &&
            [[[CCSUser currentUser] getStoredPassword] length] > 0) {
            CCSLoadLockScreenViewController* lockScreen = (CCSLoadLockScreenViewController*)TTOpenURL(@"ccs://lockScreen");
            lockScreen.view.tag = kCCSPasscodeStartUpTag;
            lockScreen.title = @"Passcode";
            [lockScreen setPromptText:@"Enter Passcode"];
            lockScreen.delegate = self;
        } else {
            [self resumeSession];
        }
    }
    
    return TRUE;
}

- (void)setupRestKit {
    //RKLogConfigureByName("RestKit/ObjectMapping", RKLogLevelTrace)
    RKLogConfigureByName("RestKit/Network", RKLogLevelDebug)
    
    // RestKit setup
    RKObjectManager* objectManager = [RKObjectManager objectManagerWithBaseURL:kCCSBaseURL];
    [RKRequestQueue sharedQueue].showsNetworkActivityIndicatorWhenBusy = YES;
    objectManager.serializationMIMEType = RKMIMETypeJSON;
    objectManager.objectStore = [RKManagedObjectStore objectStoreWithStoreFilename:@"ccs.sqlite" usingSeedDatabaseName:nil managedObjectModel:nil delegate:nil];
    objectManager.objectStore.managedObjectCache = [[CCSManagedObjectCache new] autorelease];
    NSLog(@"Path to sql: %@", objectManager.objectStore.pathToStoreFile);
    CCSMappingProvider* mappingProvider = [[CCSMappingProvider alloc] init];
    objectManager.mappingProvider = mappingProvider;
    
    RKParserRegistry* parserRegistery = [RKParserRegistry sharedRegistry];
    [parserRegistery setParserClass:[RKJSONParserJSONKit class] forMIMEType:@"text/plain"];
    
    // Setup headers
    if (![kCCSVersionNumber isEqualToString:@""]) {
        [[RKObjectManager sharedManager].client.HTTPHeaders setValue:kCCSVersionNumber forKey:@"version"];        
    }
    
    // RestKit Router
    // /authorization
	[objectManager.router routeClass:[CCSCredential class] toResourcePath:@"/authorization/" forMethod:RKRequestMethodPOST];
	[objectManager.router routeClass:[CCSCredential class] toResourcePath:@"/authorization/" forMethod:RKRequestMethodPUT];
    
    // /user
    [objectManager.router routeClass:[CCSUser class] toResourcePath:@"/user/" forMethod:RKRequestMethodPOST];
    [objectManager.router routeClass:[CCSUser class] toResourcePath:@"/user/" forMethod:RKRequestMethodPUT];
    [objectManager.router routeClass:[CCSUser class] toResourcePath:@"/user/" forMethod:RKRequestMethodDELETE];
    
    // /billers
    [objectManager.router routeClass:[CCSBiller class] toResourcePath:@"/billers/" forMethod:RKRequestMethodPOST];
    [objectManager.router routeClass:[CCSBiller class] toResourcePath:@"/billers/(billerID)" forMethod:RKRequestMethodPUT];
    [objectManager.router routeClass:[CCSBiller class] toResourcePath:@"/billers/(billerID)" forMethod:RKRequestMethodDELETE];
    
    // /billing_accounts
    [objectManager.router routeClass:[CCSBillingAccount class] toResourcePath:@"/billing_accounts/" forMethod:RKRequestMethodPOST];
    [objectManager.router routeClass:[CCSBillingAccount class] toResourcePath:@"/billing_accounts/(billingAccountID)" forMethod:RKRequestMethodDELETE];
    
    // /biller sync
    [objectManager.router routeClass:[CCSBillerSync class] toResourcePath:@"/billersync/" forMethod:RKRequestMethodPOST];
    
    // /funding_accounts
    [objectManager.router routeClass:[CCSFundingAccount class] toResourcePath:@"/funding_accounts/" forMethod:RKRequestMethodPOST];
    [objectManager.router routeClass:[CCSFundingAccount class] toResourcePath:@"/funding_accounts/(fundingAccountID)" forMethod:RKRequestMethodDELETE];
}

- (void)setupTabBarTabs {
    UINavigationController* settingsNavController = [[[UINavigationController alloc] initWithRootViewController:[[[CCSSettingsTableViewController alloc] init] autorelease]] autorelease];
    UINavigationController* messagesNavController = [[[UINavigationController alloc] initWithRootViewController:[[[CCSMessagesTableViewController alloc] init] autorelease]] autorelease];
    UINavigationController* billsNavController = [[[UINavigationController alloc] initWithRootViewController:[[[CCSBillsTableViewController alloc] init] autorelease]] autorelease];
    UINavigationController* logoutNavController = [[[UINavigationController alloc] initWithRootViewController:[[[CCSLogoutTableViewController alloc] init] autorelease]] autorelease];
    
    // Set nav bar backgrounds for iOS5
#ifdef __IPHONE_5_0
    if ([billsNavController.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]) {
        [billsNavController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navbar_no_shadow.png"] forBarMetrics:UIBarMetricsDefault];
        [messagesNavController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navbar_no_shadow.png"] forBarMetrics:UIBarMetricsDefault];
        [settingsNavController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navbar_no_shadow.png"] forBarMetrics:UIBarMetricsDefault];
    }
#endif
    
    [self.tabBarController setViewControllers:[NSArray arrayWithObjects:
                                               billsNavController,
                                               messagesNavController,
                                               settingsNavController,
                                               logoutNavController,
                                               nil]];
}

- (void)resumeSession {
    // Login if we have credentials
    BOOL resumeSession = [CCSUser resumeSession];
    if (NO == resumeSession) {
        // Display Welcome screen because we couldn't find a password
        NSLog(@"Could not resume session. Display welcome screen.");
        TTOpenURL(@"ccs://welcome");
    }
}

- (void)didLogin:(NSNotification*)notification {
    if ([CCSUser lastFailedObjectLoader] != nil) {
        NSLog(@"Login complete after failed request");
        [[CCSUser lastFailedObjectLoader] send];
    } else {
        NSLog(@"Login completed. Opening tab bar.");
        [[TTNavigator navigator] removeAllViewControllers];
        TTOpenURL(@"ccs://tabbar");
        [tabBarController setSelectedIndex:0];
        NSLog(@"Current user: %@", [CCSUser currentUser]);
        
        // start message polling
        _messagesController = [[CCSMessagesController alloc] init];
        
        // Load Application services
        _applicationServiceController = [[CCSApplicationServiceController alloc] init];
        [_applicationServiceController loadData];
    }
}

- (void)didLogout:(NSNotification*)notification {
    [[TTNavigator navigator] removeAllViewControllers];
    [CCSMessagesController setBadgeCount:[NSNumber numberWithInteger:0]];
    
    [_messagesController release];
    [_applicationServiceController release];
    
    [self setupTabBarTabs];
    
    TTOpenURL(@"ccs://welcome");
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
    NSLog(@"Set Backgrouned at: %@", [NSDate date]);
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:kCCSUserDefaultsBackgroundedAt];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
    // Display image
    _backgroundImageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Default.png"]] autorelease];
    [[TTNavigator navigator].window addSubview:_backgroundImageView];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
    BOOL autoLogout = [[CCSUser currentUser] performAutoLogout];
    if ([CCSPasscode passcodeOn] && 
        !autoLogout &&
        [[[CCSUser currentUser] getStoredPassword] length] > 0 &&
        ![[[TTNavigator navigator] topViewController] isKindOfClass:[CCSLoadLockScreenViewController class]]) {
        CCSLoadLockScreenViewController* lockScreen = (CCSLoadLockScreenViewController*)[[TTNavigator navigator] openURLAction:
                                                                                         [[TTURLAction actionWithURLPath:@"ccs://lockScreen"]
                                                                                          applyAnimated:YES]];
        lockScreen.view.tag = kCCSPasscodeResumeTag;
        lockScreen.title = @"Passcode";
        [lockScreen setPromptText:@"Enter Passcode"];
        lockScreen.delegate = self;
    }
    [_backgroundImageView removeFromSuperview];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
    
    //safely exit urban airship
    [UAirship land];
}

-(BOOL) application:(UIApplication *)application handleOpenURL:(NSURL *)aURL {
    TTOpenURL([aURL absoluteString]);
	return NO;
}

#pragma mark <UITabBarControllerDelegate>

-(BOOL) tabBarController:(UITabBarController *)tbc shouldSelectViewController:(UIViewController *)viewController {
    viewController = [((UINavigationController*)viewController) topViewController];
    if ([viewController isKindOfClass:[CCSLogoutTableViewController class]]) {
        if ([viewController isKindOfClass:[CCSLogoutTableViewController class]]) {
            UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Confirm Logout"
                                                              message:@"Are you sure?"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                                    otherButtonTitles:@"Logout", nil];
            [message show];
        }
        return NO;
    }
    return YES;
}

-(void) tabBarController:(UITabBarController *)tbc willBeginCustomizingViewControllers:(NSArray *)viewControllers {
    
}

-(void) tabBarController:(UITabBarController *)tbc willEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed {
    
}

-(void) tabBarController:(UITabBarController *)tbc didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed {
    
}

#pragma mark - CCSLockScreenViewControllerDelegate

- (void)lockScreenViewController:(CCSLockScreenViewController *)lockScreenViewController didSubmitPasscode:(NSString *)passcode {
    if ([CCSPasscode correctPasscode:passcode]) {
        [lockScreenViewController dismissModalViewControllerAnimated:YES];
        if (lockScreenViewController.view.tag == kCCSPasscodeStartUpTag) {
            [self resumeSession];
        }
    } else if ([CCSPasscode eraseDataAfterSoManyFailedAttempts] &&
               lockScreenViewController.failedAttempts >= kCCSPasscodeAttemptsAllowed) {
        [lockScreenViewController dismissModalViewControllerAnimated:NO];
        [CCSPasscode removePasscode];
        [[CCSUser currentUser] logout];
        [CCSUser clearUserData];
    } else if ([CCSPasscode eraseDataAfterSoManyFailedAttempts]) {
        [lockScreenViewController invalidPasscodeSubmittedWithErrorText:[NSString stringWithFormat:@"%d failed %@.", lockScreenViewController.failedAttempts, lockScreenViewController.failedAttempts > 1 ? @"attempts" : @"attempt"]];
    } else {
        [lockScreenViewController invalidPasscodeSubmittedWithErrorText:@"Invalid passcode. Try again."];
    }
}

#pragma mark - Push Notifications

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Updates the device token and registers the token with UA
    [[UAPush shared] registerDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    UALOG(@"Received remote notification: %@", userInfo);
    
    [[UAPush shared] handleNotification:userInfo applicationState:application.applicationState];
}

#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [[CCSUser currentUser] logout];
    }
}

#pragma mark -

-(void) dealloc {
	self.tabBarController = nil;
    [_credentialObserver release];
    [_messagesController release];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kCCSDidHandshakeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kCCSDidLogOutNotification object:nil];
	[super dealloc];
}

@end
