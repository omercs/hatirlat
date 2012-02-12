//
//  AppDelegate.h
//  RemindIt
//
//  Created by Omer Cansizoglu on 2/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Three20/Three20.h"
#import "TabBarKit.h"
@interface AppDelegate : UIResponder <UIApplicationDelegate, TTNavigatorDelegate,TBKTabBarControllerDelegate,UIAlertViewDelegate>
{
    UIImageView* _backgroundImageView;
    BOOL _resumeSession;
}



+(AppDelegate*) sharedApplicationDelegate;
- (void)setupRestKit;
- (void)resumeSession;


@end


 
 