//
//  CCSLoginTableViewController.m
//  CCSMobilePay
//
//  Created by Scott Penrose on 6/3/11.
//  Copyright 2011 Cash Cycle Solutions. All rights reserved.
//

#import "CCSLoginTableViewController.h"
#import "CCSApplicationService.h"
#import "CCSBarButtonItem.h"
#import "CCSTableControlCell.h"
#import "CCSActivityLabel.h"
#import "CCSTableTextItemCell.h"

////////////////////////////////////////////////////////////////////////
@interface CCSLoginTableViewDataSource : TTSectionedDataSource {
}
@end

@implementation CCSLoginTableViewDataSource

- (Class)tableView:(UITableView *)tableView cellClassForObject:(id)object {
    if([object isKindOfClass:[TTTableControlItem class]]) {
        return [CCSTableControlCell class];
    } else if ([object isKindOfClass:[TTTableTextItem class]]) {
        return [CCSTableTextItemCell class];
    } else {
        return [super tableView:tableView cellClassForObject:object];
    }
}

@end

////////////////////////////////////////////////////////////////////////
@implementation CCSLoginTableViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(failedLogin:) 
                                                     name:kCCSFailedHandshakeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLogin:) 
                                                     name:KCCSDismissLoginModalNotification object:nil];
    
        self.navigationItem.leftBarButtonItem = [CCSBarButtonItem backButton];
        self.tableViewStyle = UITableViewStyleGrouped;
        
        _usernameTextField = [UITextField new];
        _passwordTextField = [UITextField new];
        
        _textFieldIndex = 0;
        _textFieldOrder = [[NSArray arrayWithObjects:_usernameTextField, _passwordTextField, nil] retain];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kCCSFailedHandshakeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KCCSDismissLoginModalNotification object:nil];
    [_usernameTextField release];
    [_passwordTextField release];
    [_textFieldOrder release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)failedLogin:(NSNotification*)noficiation {
    [CCSActivityLabel hideActivityLabelInView:self.tableView];
    NSError* error = noficiation.object;
    [CCSErrorHelper displayAlertViewForError:error];
}

- (void)didLogin:(NSNotification*)notification {
    NSLog(@"Dismiss login view");
    [self.navigationController dismissModalViewControllerAnimated:NO];
    [CCSActivityLabel hideActivityLabelInView:self.tableView];
}

- (void)cancel {
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Sign In";
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background_without_status_bar.png"]];
    self.tableView.backgroundColor = [UIColor clearColor];
    
    _usernameTextField.returnKeyType = UIReturnKeyNext;
    _usernameTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _usernameTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    _usernameTextField.delegate = self;
    _passwordTextField.returnKeyType = UIReturnKeyDone;
    _passwordTextField.secureTextEntry = YES;
    _passwordTextField.delegate = self;
       
    if ([[CCSUser currentUser] rememberUsername]) {
        _usernameTextField.text = [CCSUser currentUser].userName;
    }
    
    // Only add cancel button if it is shown as modal view
    BOOL isModal = (self == [[[self navigationController] viewControllers] objectAtIndex:0]);
    if(isModal) {
        CCSBarButtonItem* cancelButtonItem = [[CCSBarButtonItem alloc] initWithTitle:@"Cancel" target:self action:@selector(cancel)];
        self.navigationItem.leftBarButtonItem = cancelButtonItem;
        [cancelButtonItem release];
    }
    
    // Add an Continue Button to the navigation item
	CCSBarButtonItem* continueButtonItem = [[CCSBarButtonItem alloc] initWithTitle:@"Continue" 
                                                                          target:self
                                                                          action:@selector(login)];
	self.navigationItem.rightBarButtonItem = continueButtonItem;
    self.navigationItem.rightBarButtonItem.enabled = NO;
	[continueButtonItem release];
    
    TTTableControlItem* usernameItem = [TTTableControlItem itemWithCaption:@"Username" control:_usernameTextField];
    TTTableControlItem* passwordItem = [TTTableControlItem itemWithCaption:@"Password" control:_passwordTextField];
    
    TTTableTextItem* forgotPasswordItem;
    if (((CCSApplicationService*)[CCSApplicationService findFirstByAttribute:@"key" withValue:@"PasswordReset"]).value &&
        ![((CCSApplicationService*)[CCSApplicationService findFirstByAttribute:@"key" withValue:@"PasswordReset"]).value isEqualToString:@""]) {
        forgotPasswordItem = [TTTableTextItem itemWithText:@"Forgot your password?" URL:((CCSApplicationService*)[CCSApplicationService findFirstByAttribute:@"key" withValue:@"PasswordReset"]).value];
        
    } else {
        forgotPasswordItem = nil;    
    }
    
    self.dataSource = [CCSLoginTableViewDataSource dataSourceWithObjects:
                       @"",
                       usernameItem,
                       passwordItem,
                       @"",
                       forgotPasswordItem,
                       nil];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark Button Selectors

- (void)login {
    NSLog(@"Continue with username: %@, password: %@", _usernameTextField.text, _passwordTextField.text);
    [CCSUser loginWithUsername:_usernameTextField.text password:_passwordTextField.text];
}

- (void)enableDoneButton {
    if ([_usernameTextField.text length] > 0 &&
        [_passwordTextField.text length] > 0) {
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
//original
//        [textField resignFirstResponder];
//        [CCSActivityLabel showActivityLabelWithText:@"Loading..." inView:self.tableView];
//        [self login];
//        return YES;
        
        //modified by Danny 2011-12-22
        if ([_usernameTextField.text length] > 0 &&
            [_passwordTextField.text length] > 0) {
            [textField resignFirstResponder];
            [CCSActivityLabel showActivityLabelWithText:@"Loading..." inView:self.tableView];
            [self login];
            return YES;
        } else {
            return NO;
        }
    }
    
    [[_textFieldOrder objectAtIndex:++_textFieldIndex] becomeFirstResponder];
    [self.tableView scrollFirstResponderIntoView];
    return YES;
}

@end
