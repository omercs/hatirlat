//
//  CCSUser.m
//  CCSMobilePay
//
//  Created by Scott Penrose on 6/20/11.
//  Copyright (c) 2011 Cash Cycle Solutions. All rights reserved.
//

#import "CCSUser.h"
#import "SFHFKeychainUtils.h"
#import "SXYSHAHash.h"


#import "CCSMessage.h"
#import "UAirship.h"
#import "UAPush.h"

@implementation CCSUser

@dynamic userName;
@dynamic email;
@dynamic homePhone;
@dynamic address;
@dynamic city;
@dynamic state;
@dynamic zipCode;
@dynamic companyName;
@dynamic companyID;
@dynamic userID;
@dynamic country;
@dynamic firstName;
@dynamic middleName;
@dynamic lastName;
@dynamic passwordQuestion;
@dynamic passwordAnswer;
@dynamic userTimeZone;


@synthesize password = _password;
@synthesize confirmPassword = _confirmPassword;
@synthesize createPassword = _createPassword;

+ (CCSUser*)currentUser {
    return [CCSUser findFirst];
}

+ (void)loginWithUsername:(NSString*)username password:(NSString*)password {
   
    //Clear previous messages
    [CCSMessage truncateAll];
    

    // Post DidBeginLogin notification
    [[NSNotificationCenter defaultCenter] postNotificationName:kCCSDidBeginLoginNotification object:self];
    NSLog(@"Login username: %@, password: %@", username, password);
    CCSCredential* credential = [[CCSCredential alloc] init];
    credential.userName = username;
    credential.password = password;
    credential.clientKey = [CCSUser getHashedUDID];
    [credential startHandshake];
}

+ (void)createWithUsername:(NSString*)username password:(NSString*)password confirmPassword:(NSString*)confirmPassword email:(NSString*)email securityQuestion:(NSString*)securityQuestion securityAnswer:(NSString*)securityAnswer {
    NSLog(@"Create username: %@, email: %@", username, email);
    CCSCredential* credential = [[CCSCredential alloc] init];
    credential.userName = username;
    credential.password = password;
    credential.confirmPassword = confirmPassword;
    credential.email = email;
    credential.securityQuestion = securityQuestion;
    credential.securityAnswer = securityAnswer;
    credential.clientKey = [CCSUser getHashedUDID];
    [credential startHandshake];
}

+ (BOOL)resumeSession {
    CCSUser* currentUser = [CCSUser currentUser];
    if(nil != currentUser) {        
        // See if we have the password in keychain
        NSString* password = [currentUser getStoredPassword];
        // We have password so login
        if([password length] > 0) {
            NSLog(@"Found password in keychain %@, continue with login", password);
            [CCSUser loginWithUsername:currentUser.userName password:password];
            return YES;
        }
    }
    
    // Don't have password
    return NO;
}

+ (void)clearUserData {
    [CCSUser truncateAll];
    [CCSMessage truncateAll];
    NSError* saveError = nil;
    [[RKObjectManager sharedManager].objectStore.managedObjectContext save:&saveError];
    NSAssert([CCSUser count:nil] == 0, @"Truncate all users didn't work");
    
    if (nil != saveError) {
        // TODO: handle save error
        NSLog(@"Error saving MOC: %@", saveError);
    }   
}

- (void)logout {
    NSLog(@"Logging out");
    NSError* error = nil;
    [CCSMessage truncateAll];
    [SFHFKeychainUtils deleteItemForUsername:self.userName andServiceName:kCCSKeychainIdentifier error:&error];
    if(nil != error) {
        NSLog(@"Error deleting password from keychain: %@", error);
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kCCSDidLogOutNotification object:nil];
    
    //user is logged out, unalias him from this device token
    [[UAPush shared] updateAlias:nil];
}

- (NSString*)getStoredPassword {
    NSError* error = nil;
    NSString* password = [SFHFKeychainUtils getPasswordForUsername:self.userName andServiceName:kCCSKeychainIdentifier error:&error];
    if (error) {
        NSLog(@"Error finding password in keychain: %@", error);
    }
    return password;
}

+ (NSString*)getHashedUDID {    
    return [SXYSHAHash getSHA256Hash:[[UIDevice currentDevice]uniqueIdentifier]];
}

- (BOOL)performAutoLogout {
    BOOL autoLogout = [self autoLogout];
    if (autoLogout) {
        // Check to see if you have been background longer than allowed time
        NSDate* backgroundedAt = [[NSUserDefaults standardUserDefaults] objectForKey:kCCSUserDefaultsBackgroundedAt];
        NSLog(@"Backgrounded at: %@", backgroundedAt);
        
        NSCalendar *calendar = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
        NSDateComponents *components = [calendar components:NSMinuteCalendarUnit | NSSecondCalendarUnit
                                                   fromDate:backgroundedAt
                                                     toDate:[NSDate date]
                                                    options:0];
        
        NSInteger timeout = kCCSAutoLogoutTimeout;
        CCSApplicationService* applicationService = [CCSApplicationService findFirstByAttribute:@"key" withValue:@"Timeout"];
        if (nil != applicationService && nil != applicationService.value) {
            timeout = [applicationService.value integerValue];
        }
        NSLog(@"Timeout: %d, minutes since backgrounding: %d", timeout, components.minute);
        if (components.minute > timeout) {
            [self logout];
            return YES;
        }
    }
    return NO;
}

- (BOOL)rememberUsername {
    return [[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"%@-%@", self.userName, kCCSUserDefaultsRememberUsername]];
}

- (void)setRememberUsername:(BOOL)rememberUsername {
    [[NSUserDefaults standardUserDefaults] setBool:rememberUsername forKey:[NSString stringWithFormat:@"%@-%@", self.userName, kCCSUserDefaultsRememberUsername]];
}

- (BOOL)autoLogout {
    return [[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"%@-%@", self.userName, kCCSUserDefaultsAutoLogout]];
}

- (void)setAutoLogout:(BOOL)autoLogout {
    [[NSUserDefaults standardUserDefaults] setBool:autoLogout forKey:[NSString stringWithFormat:@"%@-%@", self.userName, kCCSUserDefaultsAutoLogout]];
}

#pragma mark Validation

- (BOOL)passwordsMatch {
    if ([self.password isEqualToString:self.confirmPassword]) {
        return YES;
    }
    return NO;
}

#pragma mark Urban Airship helpers

- (void)aliasTokenToUserID {
    NSLog(@"User id: %@", self.userID);
    [[UAPush shared] updateAlias:[self.userID stringValue]];
}

+ (void)setLastFailedObjectLoader:(RKObjectLoader*)objectLoader {
    [lastFailedObjectLoader release];
    lastFailedObjectLoader = nil;
    lastFailedObjectLoader = objectLoader;
}

+ (RKObjectLoader*)lastFailedObjectLoader {
    return lastFailedObjectLoader;
}

@end
