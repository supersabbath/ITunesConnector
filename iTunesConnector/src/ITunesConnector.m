//
//  ITunesConnector.m
//  iTunnesConnector
//
//  Created by Fernando Canon on 28/03/15.
//  Copyright (c) 2015 Fernando Canon. All rights reserved.
//

#import "ITunesConnector.h"
#import "NSFileHandle+Print.h"
#import "ITunesConnectorUtils.h"
#import <PromiseKit/PromiseKit.h>


#import "Options.h"

@interface ITunesConnector (Private)

-(void) declareEnvironmentVarForITMSTransporter;

@end

@implementation ITunesConnector

- (id)init
{
    if (self = [super init]) {
        _exitStatus = 0;
        _standardOutput = [NSFileHandle fileHandleWithStandardOutput];
        _standardError = [NSFileHandle fileHandleWithStandardError];
    }
    return self;
}


-(void) run
{
    
    [_standardOutput printString:@"ITunesConnector rocks! \n"];
    
    Options *options = [[Options alloc] init];

    NSString *errorMessage = nil;

    [options consumeArguments:[NSMutableArray arrayWithArray:self.arguments] errorMessage:&errorMessage];
    
    if (errorMessage != nil) {
        [_standardError printString:@"ERROR: %@\n", errorMessage];
        _exitStatus = 1;
        return;
    }
    
    if (options.showHelp) {
        [self printUsage];
        _exitStatus = 1;
        return;
    }
    
    
    for (Action *action in options.actions) {
    
        BOOL succeeded = [action performActionWithOptions:options xcodeSubjectInfo:nil];
        
        if (!succeeded) {
            _exitStatus = 1;
            break;
        }
    }
    

//    [self startITMSTransporter].then(^{
//        [_standardOutput printString:@"TEst"];
//    });
}



- (void)printUsage
{
    [_standardError printString:@"usage: itunesconnetor [BASE OPTIONS] [ACTION [ACTION ARGUMENTS]] ...\n\n"];
    
    [_standardError printString:@"Examples:\n"];
    for (Class actionClass in [Options actionClasses]) {
        NSString *actionName = [actionClass name];
        NSArray *options = [actionClass options];
        
        NSMutableString *buffer = [NSMutableString string];
        
        for (NSDictionary *option in options) {
            if (option[kActionOptionParamName]) {
                [buffer appendFormat:@" [-%@ %@]", option[kActionOptionName], option[kActionOptionParamName]];
            } else {
                [buffer appendFormat:@" [-%@]", option[kActionOptionName]];
            }
        }
        
        [_standardError printString:@"    itunesconnector [BASE OPTIONS] %@%@", actionName, buffer];
        [_standardError printString:@"\n"];
    }
    
    [_standardError printString:@"\n"];
    
    [_standardError printString:@"Base Options:\n"];
    [_standardError printString:@"%@", [Options actionUsage]];
    
    [_standardError printString:@"\n"];
 

    
    for (Class actionClass in [Options actionClasses]) {
        NSString *actionName = [actionClass name];
        NSString *actionUsage = [actionClass actionUsage];
        
        if (actionUsage.length > 0) {
            [_standardError printString:@"\n"];
            [_standardError printString:@"Options for '%@' action:\n", actionName];
            [_standardError printString:@"%@", actionUsage];
        }
    }
    
    [_standardError printString:@"\n"];
}



-(PMKPromise*) startITMSTransporter
{
 
   return  [PMKPromise new:^(PMKFulfiller fulfill, PMKRejecter reject) {
        
    
    NSString *xcodePath = XcodeDeveloperDirPath();
    
    NSTask *transporterTask = [[NSTask alloc] init];

    [transporterTask setLaunchPath:[xcodePath stringByAppendingPathComponent:@"Applications/Application Loader.app/Contents/MacOS/itms/bin/iTMSTransporter"]];
    [transporterTask setArguments:@[@"-version"]];
    
    NSDictionary *output = LaunchTaskAndCaptureOutput(transporterTask,@"Initializing iTMSTrasporter");
    
    NSString *stdoutString = output[@"stdout"];
    
    NSString *stdErrorString = output[@"stderror"];
    
    stdoutString = [stdoutString stringByTrimmingCharactersInSet:
            [NSCharacterSet newlineCharacterSet]];
    
   
      [_standardError printString:@"%@",stdErrorString];
  
      [_standardOutput printString:@"%@",stdoutString];
    
  
    }];
    
}

@end
