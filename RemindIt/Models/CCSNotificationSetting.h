//
//  CCSNotificationSetting.h
//  CCSMobilePay
//
//  Created by Omer Cansizoglu on 1/11/12.
//  Copyright (c) 2012 Cash Cycle Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <RestKit/RestKit.h> 
#import <RestKit/CoreData/CoreData.h> 

@interface CCSNotificationSetting : NSObject{
    NSNumber* _messageLifeTime;
    NSArray* _usernotificationTypes;
}

@property (nonatomic, retain) NSNumber* messageLifeTime;
@property (nonatomic, retain) NSArray* usernotificationTypes;


@end

 