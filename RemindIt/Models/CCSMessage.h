//
//  CCSMessage.h
//  CCSMobilePay
//
//  Created by Scott Penrose on 6/20/11.
//  Copyright (c) 2011 Cash Cycle Solutions. All rights reserved.
//

#import <RestKit/RestKit.h>
#import <RestKit/CoreData/CoreData.h>


@interface CCSMessage : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString* message;
@property (nonatomic, retain) NSNumber* messageID;
@property (nonatomic, retain) NSNumber* priority;
@property (nonatomic, retain) NSDate* date;
@property (nonatomic, retain) NSNumber* unread;
@property (nonatomic, retain) NSNumber* linkID;
@property (nonatomic, retain) NSNumber* linkedItemTypeID;

- (NSString*)fuzzyDate;
- (NSString*)linkResourcePath;

@end
