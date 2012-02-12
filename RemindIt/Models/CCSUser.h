//
//  CCSUser.h
//  CCSMobilePay
//
//  Created by Scott Penrose on 6/20/11.
//  Copyright (c) 2011 Cash Cycle Solutions. All rights reserved.
//

#import <RestKit/RestKit.h>
#import <RestKit/CoreData/CoreData.h>

//last failed ObjectLoader;
RKObjectLoader* lastFailedObjectLoader;

@interface CCSUser : NSManagedObject {
@private
}
// Database
@property (nonatomic, retain) NSString * userName;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * homePhone;
@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSString * state;
@property (nonatomic, retain) NSString * zipCode;
@property (nonatomic, retain) NSString * companyName;
@property (nonatomic, retain) NSNumber * companyID;
@property (nonatomic, retain) NSNumber * userID;
@property (nonatomic, retain) NSString * country;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * middleName;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSString * passwordQuestion;
@property (nonatomic, retain) NSString * passwordAnswer;
@property (nonatomic, retain) NSString * userTimeZone;
 

@property (nonatomic, retain) NSString* password;
@property (nonatomic, retain) NSString* confirmPassword;
@property (nonatomic, retain) NSString* createPassword;

+ (CCSUser*)currentUser;
+ (BOOL)resumeSession;
+ (void)loginWithUsername:(NSString*)username password:(NSString*)password;
+ (void)createWithUsername:(NSString*)username password:(NSString*)password confirmPassword:(NSString*)confirmPassword email:(NSString*)email securityQuestion:(NSString*)securityQuestion securityAnswer:(NSString*)securityAnswer;
+ (NSString*)getHashedUDID;
+ (void)clearUserData;

- (NSString*)getStoredPassword;
- (void)logout;
- (BOOL)performAutoLogout;

- (BOOL)rememberUsername;
- (void)setRememberUsername:(BOOL)rememberUsername;
- (BOOL)autoLogout;
- (void)setAutoLogout:(BOOL)autoLogout;

// Validation
- (BOOL)passwordsMatch;

// UrbanAirship Helpers
- (void)aliasTokenToUserID;

//last failed object loader
+ (void)setLastFailedObjectLoader:(RKObjectLoader*)objectLoader;
+ (RKObjectLoader*)lastFailedObjectLoader;

@end    

