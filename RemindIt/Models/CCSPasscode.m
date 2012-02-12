//
//  CCSPasscode.m
//  CCSMobilePay
//
//  Created by Scott Penrose on 9/14/11.
//  Copyright (c) 2011 Cash Cycle Solutions. All rights reserved.
//

#import "CCSPasscode.h"
#import "CCSUser.h"
#import "SFHFKeychainUtils.h"

@implementation CCSPasscode

+ (NSString*)userPinKey {
    return [NSString stringWithFormat:@"%@-pin", [CCSUser currentUser].userName];
}

+ (BOOL)passcodeOn {
    if ([[CCSPasscode getPasscode] length]) {
        return YES;
    }
    return NO;
}

+ (BOOL)setPasscode:(NSString*)passcode {
    NSError* error = nil;
    [SFHFKeychainUtils storeUsername:[CCSPasscode userPinKey] andPassword:passcode forServiceName:kCCSKeychainIdentifier updateExisting:YES error:&error];
    if(nil != error) {
        NSLog(@"Error setting passcode to keychain: %@", error);
        return NO;
    }
    return YES;
}

+ (NSString*)getPasscode {
    NSError* error = nil;
    NSString* passcode = [SFHFKeychainUtils getPasswordForUsername:[CCSPasscode userPinKey] andServiceName:kCCSKeychainIdentifier error:&error];
    return passcode;
}

+ (BOOL)removePasscode {
    NSError* error = nil;
    [SFHFKeychainUtils deleteItemForUsername:[CCSPasscode userPinKey] andServiceName:kCCSKeychainIdentifier error:&error];
    if(nil != error) {
        NSLog(@"Error deleting passcode from keychain: %@", error);
        return NO;
    }
    [CCSPasscode setEraseDataAfterSoManyFailedAttempts:NO];
    return YES;
}

+ (BOOL)correctPasscode:(NSString*)enteredPasscode {
    NSString* storedPasscode = [CCSPasscode getPasscode];
    if ([storedPasscode isEqualToString:enteredPasscode]) {
        return YES;
    }
    return NO;
}

+ (void)setEraseDataAfterSoManyFailedAttempts:(BOOL)eraseData {
    [[NSUserDefaults standardUserDefaults] setBool:eraseData forKey:kCCSUserDefaultsEraseData];
}

+ (BOOL)eraseDataAfterSoManyFailedAttempts {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kCCSUserDefaultsEraseData];
}

@end
