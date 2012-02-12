//
//  CCSMessage.m
//  CCSMobilePay
//
//  Created by Scott Penrose on 6/20/11.
//  Copyright (c) 2011 Cash Cycle Solutions. All rights reserved.
//

#import "CCSMessage.h"
#import "NSDate+FuzzyTime.h"

@implementation CCSMessage
@dynamic message;
@dynamic messageID;
@dynamic priority;
@dynamic date;
@dynamic unread;
@dynamic linkID;
@dynamic linkedItemTypeID;

- (NSString*)fuzzyDate {
    if (nil != self.date) {
        NSLog(@"Message Date: %@, current date: %@", self.date, [NSDate date]);
        return [[NSDate date] prettyPrintTimeIntervalSinceDate:self.date];
    }
    return @"";
}

- (NSString*)linkResourcePath {
    switch ([self.linkedItemTypeID intValue]) {
        case 1: return [NSString stringWithFormat:@"ccs://account/%@", self.linkID]; //account
        case 2: return [NSString stringWithFormat:@"ccs://schedule/%@", self.linkID]; // schedule
        case 3: return [NSString stringWithFormat:@"ccs://message/%@", self.linkID]; // notification change
        default:
            return @"";
    }
}

@end
