//
//  Options.h
//  iTunesConnector
//
//  Created by Fernando Canon on 29/03/15.
//  Copyright (c) 2015 Fernando Canon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import  "Action.h"

typedef enum : NSUInteger {
    unexpected_action,
} OptionsErrorCode;

@class PMKPromise;

@interface Options : Action

@property (nonatomic, assign) BOOL showHelp;
@property (nonatomic, strong) NSString* user;
@property (nonatomic, strong) NSString* passwd;
@property (nonatomic, retain) NSMutableArray *actions;


+(NSArray*) actionClasses;
+(NSArray*) options;
-(PMKPromise*) processArguments:(NSMutableArray *)arguments ;
-(NSArray*) concatArgumentsForITMSTransporter;

@end
