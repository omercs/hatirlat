//
//  CCSSignUpTableViewController.h
//  CCSMobilePay
//
//  Created by Scott Penrose on 6/8/11.
//  Copyright 2011 Cash Cycle Solutions. All rights reserved.
//

#import <Three20/Three20.h>
#import <Three20/Three20+Additions.h>
#import <RestKit/Three20/Three20.h>
#import "CCSUser.h"

#define CCSUserPasswordsMatchAlertViewTag     10

@interface CCSSignUpTableViewController : TTTableViewController <UITextFieldDelegate> {
    UITextField* _emailTextField;
    UITextField* _usernameTextField;
    UITextField* _passwordTextField;
    UITextField* _passwordConfirmTextField;
    UITextField* _passwordQuestionTextField;
    UITextField* _passwordAnswerTextField;
    
    NSUInteger _textFieldIndex;
    NSArray* _textFieldOrder;
}

- (void)dismiss;

@end
