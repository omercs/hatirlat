//
//  CCSError.h
//  CCSMobilePay
//
//  Created by Scott Penrose on 8/8/11.
//  Copyright (c) 2011 Cash Cycle Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CCSError : NSObject

@property (nonatomic, retain) NSString* code;
@property (nonatomic, retain) NSString* name;
@property (nonatomic, retain) NSNumber* severity;

@end
