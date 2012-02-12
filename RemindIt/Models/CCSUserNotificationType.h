//
//  CCSUserNotificationType.h
//  CCSMobilePay
//
//  Created by Omer Cansizoglu on 1/11/12.
//  Copyright (c) 2012 Cash Cycle Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>
#import <RestKit/CoreData/CoreData.h>

@interface CCSUserNotificationType : NSManagedObject
{
    NSNumber* _typeID;
    NSString* _label;
    NSNumber* _orderRank;
    NSNumber* _hasEmail;
    NSNumber* _hasSms;
    NSNumber* _hasVoice;
    NSNumber* _hasPush;
}

@property (nonatomic, retain) NSNumber* typeID;
@property (nonatomic, retain) NSString* label;
@property (nonatomic, retain) NSNumber* orderRank;
@property (nonatomic, retain) NSNumber* hasEmail;
@property (nonatomic, retain) NSNumber* hasSms;
@property (nonatomic, retain) NSNumber* hasVoice;
@property (nonatomic, retain) NSNumber* hasPush;

@end
