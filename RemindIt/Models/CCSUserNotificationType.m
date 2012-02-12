//
//  CCSUserNotificationType.m
//  CCSMobilePay
//
//  Created by Omer Cansizoglu on 1/11/12.
//  Copyright (c) 2012 Cash Cycle Solutions. All rights reserved.
//

#import "CCSUserNotificationType.h"

@implementation CCSUserNotificationType
@synthesize typeID=_typeID;
@synthesize label= _label;
@synthesize orderRank = _orderRank;
@synthesize hasEmail= _hasEmail,hasSms=_hasSms,hasVoice=_hasVoice,hasPush=_hasPush;

@end
