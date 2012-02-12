//
//  CCSPasscode.h
//  CCSMobilePay
//
//  Created by Scott Penrose on 9/14/11.
//  Copyright (c) 2011 Cash Cycle Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CCSPasscode : NSObject

+ (NSString*)userPinKey;
+ (BOOL)passcodeOn;
+ (BOOL)setPasscode:(NSString*)passcode;
+ (NSString*)getPasscode;
+ (BOOL)removePasscode;
+ (BOOL)correctPasscode:(NSString*)enteredPasscode;
+ (BOOL)eraseDataAfterSoManyFailedAttempts;
+ (void)setEraseDataAfterSoManyFailedAttempts:(BOOL)eraseData;

@end
