//
//  CCSLockScreenViewController.h
//  CCSMobilePay
//
//  Created by Scott Penrose on 9/12/11.
//  Copyright (c) 2011 Cash Cycle Solutions. All rights reserved.
//

#import <Three20/Three20.h>
#import "CCSLockView.h"

@protocol CCSLockScreenViewControllerDelegate;

@interface CCSLockScreenViewController : TTTableViewController <UITextFieldDelegate> {
    CCSLockView* _lockView;
    NSObject<CCSLockScreenViewControllerDelegate>* _delegate;
    NSString* _promptText;
    UIBarButtonItem* _cancelButton;
    NSInteger _failedAttempts;
}

@property (nonatomic, assign) NSObject<CCSLockScreenViewControllerDelegate>* delegate;
@property (nonatomic, assign) NSInteger failedAttempts;

// The cancel button should not have a target or action as they will be overridden.
// When this button is pressed the view controller will be dismissed and 
// lockScreenViewControllerDidCancel: will be invoked on the delegate (if implemented).
//- (void)setCancelButton:(UIBarButtonItem*)cancelButton;
- (void)setPromptText:(NSString*)text;

- (void)clearPasscode;
- (void)clearErrorMessage;

// Display feedback to the user indicating that an invalid passcode was submitted
// Clear current passcode text.
- (void)invalidPasscodeSubmittedWithErrorText:(NSString*)errorText;

- (void)verifyPasscode:(NSString*)passcode;

@end

@protocol CCSLockScreenViewControllerDelegate <NSObject>
@optional

- (void)lockScreenViewController:(CCSLockScreenViewController*)lockScreenViewController didSubmitPasscode:(NSString*)passcode;
- (void)lockScreenViewControllerDidCancel:(CCSLockScreenViewController*)lockScreenViewController;

@end