//
//  CCSLockScreenViewController.m
//  CCSMobilePay
//
//  Created by Scott Penrose on 9/12/11.
//  Copyright (c) 2011 Cash Cycle Solutions. All rights reserved.
//

#import "CCSLockScreenViewController.h"

@interface CCSLockScreenViewController (Private)
- (void)passcodeChanged;
@end

@implementation CCSLockScreenViewController

@synthesize delegate = _delegate;
@synthesize failedAttempts = _failedAttempts;

#pragma mark - NSObject

- (void)dealloc {
    [_lockView release];
    [_promptText release];
    [_cancelButton release];
    [super dealloc];
}

#pragma mark - UIViewController

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = [UIColor clearColor];
    
    _lockView = [[CCSLockView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 200)];
    
    [_lockView.passcodeTextField becomeFirstResponder];
    _lockView.passcodeTextField.delegate = self;
    
    _failedAttempts = 0;
    
    [self.view addSubview:_lockView];
}

#pragma mark - Setters

//- (void)setCancelButton:(UIBarButtonItem*)cancelButton {
//    [cancelButton setTarget:self];
//    [cancelButton setAction:@selector(cancelButtonPressed)];
//    self.navigationItem.rightBarButtonItem = cancelButton;
//}

- (void)setPromptText:(NSString*)text {
    [_promptText release];
    _promptText = [text retain];
    _lockView.promptTextLabel.text = _promptText;
}

#pragma mark - State

- (void)clearPasscode {
    _lockView.passcodeTextField.text = @"";
    [self passcodeChanged];
}

- (void)clearErrorMessage {
    _lockView.invalidTextLabel.text = @"";
}

- (void)invalidPasscodeSubmittedWithErrorText:(NSString*)errorText {
    [self clearPasscode];
    _lockView.invalidTextLabel.text = errorText;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (range.location > 3) {
        return NO;
    }
    [self performSelector:@selector(passcodeChanged) withObject:nil afterDelay:0.0];
    return YES;
}

- (void)passcodeChanged {
    NSString* passcode = _lockView.passcodeTextField.text;
    _lockView.boxImageView1.image = _lockView.emptyBoxImage;
    _lockView.boxImageView2.image = _lockView.emptyBoxImage;
    _lockView.boxImageView3.image = _lockView.emptyBoxImage;
    _lockView.boxImageView4.image = _lockView.emptyBoxImage;
    
    if ([passcode length] == 1) {
        _lockView.boxImageView1.image = _lockView.filledBoxImage;
    } else if ([passcode length] == 2) {
        _lockView.boxImageView1.image = _lockView.filledBoxImage;
        _lockView.boxImageView2.image = _lockView.filledBoxImage;
    } else if ([passcode length] == 3) {
        _lockView.boxImageView1.image = _lockView.filledBoxImage;
        _lockView.boxImageView2.image = _lockView.filledBoxImage;
        _lockView.boxImageView3.image = _lockView.filledBoxImage;
    } else if ([passcode length] == 4) {
        _lockView.boxImageView1.image = _lockView.filledBoxImage;
        _lockView.boxImageView2.image = _lockView.filledBoxImage;
        _lockView.boxImageView3.image = _lockView.filledBoxImage;
        _lockView.boxImageView4.image = _lockView.filledBoxImage;
        
        [self performSelector:@selector(verifyPasscode:) withObject:passcode afterDelay:0.2];
    }
}

#pragma mark - Passcode

- (void)verifyPasscode:(NSString*)passcode {
    _failedAttempts++;
    if ([self.delegate respondsToSelector:@selector(lockScreenViewController:didSubmitPasscode:)]) {
        [self.delegate lockScreenViewController:self didSubmitPasscode:passcode];
    }
}

//- (void)cancelButtonPressed {
//    NSLog(@"Cancel button pressed");
//    if ([self.delegate respondsToSelector:@selector(lockScreenViewControllerDidCancel:)]) {
//        [self.delegate lockScreenViewControllerDidCancel:self];
//    }
//}

@end
