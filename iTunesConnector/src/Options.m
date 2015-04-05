//
//  Options.m
//  iTunesConnector
//
//  Created by Fernando Canon on 29/03/15.
//  Copyright (c) 2015 Fernando Canon. All rights reserved.
//

#import "Options.h"
#import "UploadAction.h"
#import "LookupMetadataAction.h"
#import "ReportDownloadAction.h"

#import <PromiseKit/Promise.h>

NSString *const kOptionsErrorDomain =@"OptionsErrorDomain";

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
                           aliases:@[@"u", @"user"]
                       description:@"Apple User ID"
                         paramName:@"USER_ID"
                             mapTo:@selector(setUser:)],
      
      [Action actionOptionWithName:@"password"
                           aliases:@[@"p", @"password"]
                       description:@"itunnes password"
                         paramName:@"PASSWD"
                             mapTo:@selector(setPasswd:)]
      ];
}


+(NSArray*) actionClasses
{

 return   @[[UploadAction class],[LookupMetadataAction class],[ReportDownloadAction class]];
    
}

/** This method wraps the call to consumeArguments: errorMesage in a promesy style
 
 See more info at: [direct hyperlinks](http://promisekit.org/sealing-your-own-promises/)
 
 @param arguments An array with the command line options
 @param errorMessage Memory address for the error message

 */
-(PMKPromise*) processArguments:(NSMutableArray *)arguments
{
    Options * __weak options = self;

    return [PMKPromise new:^(PMKFulfiller fulfill, PMKRejecter reject) {
        
        NSString *errorMessage = nil;
        [options consumeArguments:arguments errorMessage:&errorMessage];
        
        if (errorMessage != nil) {
           
            _error = [options errorForMessage:errorMessage andCode:unexpected_action];
            reject(_error); // The promise failed
        
        }else{
        
            fulfill(options.actions);
        }
        
    }];
}

/** This method is inherited from Facebook XCTool
 
will be cover with a promise wraper method to use it under promises architecture
 
 */
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


-(PMKPromise *) concatArgumentsForITMSTransporter
{
    Options *__weak weakSelf = self;
    
    return [PMKPromise new:^(PMKFulfiller fulfill, PMKRejecter reject) {
        
        NSArray *itmsArgs = nil;
        if (_passwd != nil && _user != nil)
        {
            itmsArgs = @[@"-u", self.user, @"-p", self.passwd];
            fulfill(itmsArgs);
        }
        else
        {
            reject([weakSelf errorForMessage:@"ITunesConnector Should have password and user" andCode:missing_parameter_error]);
        }}];
}
//
//-(NSArray*) concatArgumentsForITMSTransporter
//{
//    NSArray *itmsArgs = nil;
//    
//    if (self.passwd != nil && self.user != nil)
//    {
//        itmsArgs = @[@"-u", self.user, @"-p", self.passwd];
//    }
//    else {
//        NSLog(@"ITunesConnector Should have password and user");
//        abort();
//    }
//    return itmsArgs;
//}

-(NSError *) errorForMessage:(NSString *)message andCode:(NSUInteger)code{

    return  [NSError errorWithDomain:kOptionsErrorDomain code:code userInfo:@{@"output_message":message}];
}

@end
