//
//  Options.m
//  iTunesConnector
//
//  Created by Fernando Canon on 29/03/15.
//  Copyright (c) 2015 Fernando Canon. All rights reserved.
//

#import "Options.h"
#import "UploadAction.h"

@implementation Options
- (id)init
{
    if (self = [super init])
    {
        self.actions = [NSMutableArray array];
    }
    return self;
}


+ (NSArray *)options
{
    return
    @[[Action actionOptionWithName:@"help"
                           aliases:@[@"h", @"usage"]
                       description:@"show help"
                           setFlag:@selector(setShowHelp:)],
    
      [Action actionOptionWithName:@"user"
                           aliases:nil
                       description:@"Apple User ID"
                         paramName:@"USER_ID"
                             mapTo:@selector(setUser:)],
      
      [Action actionOptionWithName:@"password"
                           aliases:nil
                       description:@"itunnes password"
                         paramName:@"PASSWD"
                             mapTo:@selector(setPasswd:)]
      ];
}

+(NSArray*) actionClasses
{

 return   @[[UploadAction class]];
    
}

- (NSUInteger)consumeArguments:(NSMutableArray *)arguments errorMessage:(NSString **)errorMessage
{
    NSMutableDictionary *verbToClass = [NSMutableDictionary dictionary];
    for (Class actionClass in [Options actionClasses]) {
        NSString *actionName = [actionClass name];
        verbToClass[actionName] = actionClass;
    }
    
    NSUInteger consumed = 0;
    
    NSMutableArray *argumentList = [NSMutableArray arrayWithArray:arguments];
    while (argumentList.count > 0) {
        consumed += [super consumeArguments:argumentList errorMessage:errorMessage];
        
        if (argumentList.count == 0) {
            break;
        }
        
        NSString *argument = argumentList[0];
        [argumentList removeObjectAtIndex:0];
        consumed++;
        
        if (verbToClass[argument]) {
            Action *action = [[verbToClass[argument] alloc] init];
            consumed += [action consumeArguments:argumentList errorMessage:errorMessage];
            [self.actions addObject:action];
        } else {
            *errorMessage = [NSString stringWithFormat:@"Unexpected action: %@", argument];
            break;
        }
    }
    
    return consumed;
}

-(NSArray*) concatArgumentsForITMSTransporter
{
    return @[];
}

@end
