//
//  CCSSignUpTableViewController.m
//  CCSMobilePay
//
//  Created by Scott Penrose on 6/8/11.
//  Copyright 2011 Cash Cycle Solutions. All rights reserved.
//

#import "CCSSignUpTableViewController.h"
#import "CCSBarButtonItem.h"
#import "CCSUser.h"
#import "CCSTableControlCell.h"
#import "CCSActivityLabel.h"

////////////////////////////////////////////////////////////////////////
@interface CCSSignUpTableViewDataSource : TTSectionedDataSource {
}
@end

@implementation CCSSignUpTableViewDataSource

- (Class)tableView:(UITableView *)tableView cellClassForObject:(id)object {
    if([object isKindOfClass:[TTTableControlItem class]])
        return [CCSTableControlCell class];
    else
        return [super tableView:tableView cellClassForObject:object];
}

@end

////////////////////////////////////////////////////////////////////////

@implementation CCSSignUpTableViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.navigationItem.leftBarButtonItem = [CCSBarButtonItem backButton];
        self.tableViewStyle = UITableViewStyleGrouped;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(failedLogin:) 
                                                     name:kCCSFailedHandshakeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLogin:) 
                                                     name:KCCSDismissLoginModalNotification object:nil];
        
        _emailTextField = [UITextField new];
        _usernameTextField = [UITextField new];
        _passwordTextField = [UITextField new];
        _passwordConfirmTextField = [UITextField new];
        _passwordQuestionTextField = [UITextField new];
        _passwordAnswerTextField = [UITextField new];
        
        _textFieldIndex = 0;
        _textFieldOrder = [[NSArray arrayWithObjects:_emailTextField, _usernameTextField, _passwordTextField, _passwordConfirmTextField, _passwordQuestionTextField, _passwordAnswerTextField, nil] retain];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kCCSFailedHandshakeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KCCSDismissLoginModalNotification object:nil];
    [_emailTextField release];
    [_usernameTextField release];
    [_passwordTextField release];
    [_passwordConfirmTextField release];
    [_passwordQuestionTextField release];
    [_passwordAnswerTextField release];
    [_textFieldOrder release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)loadView {
    [super loadView];
    self.title = @"Sign Up";
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background_without_status_bar.png"]];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.autoresizesForKeyboard = YES;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _emailTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _emailTextField.delegate = self;
    _emailTextField.returnKeyType = UIReturnKeyNext;
    
    _usernameTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _usernameTextField.delegate = self;
    _usernameTextField.returnKeyType = UIReturnKeyNext;
    
    _passwordTextField.secureTextEntry = YES;
    _passwordTextField.delegate = self;
    _passwordTextField.returnKeyType = UIReturnKeyNext;
    
    _passwordConfirmTextField.secureTextEntry = YES;
    _passwordConfirmTextField.delegate = self;
    _passwordConfirmTextField.returnKeyType = UIReturnKeyNext;
    
    _passwordQuestionTextField.delegate = self;
    _passwordQuestionTextField.returnKeyType = UIReturnKeyNext;
    
    _passwordAnswerTextField.delegate = self;
    _passwordAnswerTextField.returnKeyType = UIReturnKeyDone;
    
    self.dataSource = [CCSSignUpTableViewDataSource dataSourceWithObjects:
                       @"",
                       [TTTableControlItem itemWithCaption:@"Email" control:_emailTextField],
                       [TTTableControlItem itemWithCaption:@"Username" control:_usernameTextField],
                       [TTTableControlItem itemWithCaption:@"Password" control:_passwordTextField],
                       [TTTableControlItem itemWithCaption:@"Retype Password" control:_passwordConfirmTextField],
                       @"",
                       [TTTableControlItem itemWithCaption:@"Security Question" control:_passwordQuestionTextField],
                       [TTTableControlItem itemWithCaption:@"Security Answer" control:_passwordAnswerTextField],
                       nil];
  
    // Add an Continue Button to the navigation item
	UIBarButtonItem* continueButtonItem = [[CCSBarButtonItem alloc] initWithTitle:@"Continue" 
                                                                          target:self
                                                                          action:@selector(signUp)];
    continueButtonItem.enabled = NO;
	self.navigationItem.rightBarButtonItem = continueButtonItem;
    self.navigationItem.rightBarButtonItem.enabled = NO;
	[continueButtonItem release];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dismiss {
    [self.view endEditing:YES];
    [CCSActivityLabel hideActivityLabelInView:self.tableView];
    [self.navigationController popViewControllerAnimated:NO];
}

#pragma mark - Notification callbacks

- (void)failedLogin:(NSNotification*)noficiation {
    [CCSActivityLabel hideActivityLabelInView:self.tableView];
    NSError* error = noficiation.object;
    [CCSErrorHelper displayAlertViewForError:error];
}

- (void)didLogin:(NSNotification*)notification {
    [self dismiss];
}

#pragma mark Button Selectors

- (void)signUp { 
    NSLog(@"Sign up with username: %@, email: %@, security question: %@", _usernameTextField.text, _emailTextField.text, _passwordQuestionTextField.text);
    NSString* username = _usernameTextField.text;
    NSString* password = _passwordTextField.text;
    NSString* passwordConfirm = _passwordConfirmTextField.text;
    NSString* email = _emailTextField.text;
    NSString* securityQuestion = _passwordQuestionTextField.text;
    NSString* securityAnswer = _passwordAnswerTextField.text;
    
    // Make sure passwords are the same
    if(![password isEqualToString:passwordConfirm]) {
        [CCSActivityLabel hideActivityLabelInView:self.tableView];
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Passwords Do Not Match" 
                                                            message:@"" 
                                                           delegate:self 
                                                  cancelButtonTitle:@"Ok" 
                                                  otherButtonTitles:nil];
        alertView.tag = CCSUserPasswordsMatchAlertViewTag;
        [alertView show];
        [alertView release];
        return;
    }
    
    [CCSUser createWithUsername:username password:password confirmPassword:passwordConfirm email:email securityQuestion:securityQuestion securityAnswer:securityAnswer];
}

- (void)enableDoneButton {
    if ([_emailTextField.text length] > 0 &&
        [_usernameTextField.text length] > 0 &&
        [_passwordTextField.text length] > 0 &&
        [_passwordConfirmTextField.text length] > 0 &&
        [_passwordQuestionTextField.text length] > 0 &&
        [_passwordAnswerTextField.text length] > 0) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    } else {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
}

#pragma mark - UITextFieldDelegate Methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    [self performSelector:@selector(enableDoneButton) withObject:nil afterDelay:0.0];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    _textFieldIndex = [_textFieldOrder indexOfObject:textField];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {    
    if (textField.returnKeyType == UIReturnKeyDone) {
        [textField resignFirstResponder];
        [CCSActivityLabel showActivityLabelWithText:@"Loading..." inView:self.tableView];
        [self signUp];
        return YES;
    }
    
    [[_textFieldOrder objectAtIndex:++_textFieldIndex] becomeFirstResponder];
    [self.tableView scrollFirstResponderIntoView];
    return YES;
}

@end
