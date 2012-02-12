//
//  CCSLoginTableViewController.h
//  CCSMobilePay
//
//  Created by Scott Penrose on 6/3/11.
//  Copyright 2011 Cash Cycle Solutions. All rights reserved.
//

#import <Three20/Three20.h>
#import <Three20/Three20+Additions.h>
#import <RestKit/Three20/Three20.h>
#import "CCSUser.h"

@interface CCSLoginTableViewController : TTTableViewController <UITextFieldDelegate> {
    UITextField* _usernameTextField;
    UITextField* _passwordTextField;
    
    NSUInteger _textFieldIndex;
    NSArray* _textFieldOrder;
}

@end
