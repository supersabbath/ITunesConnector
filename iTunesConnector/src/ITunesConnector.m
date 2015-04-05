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
#import <PromiseKit/Promise.h>
#import <PromiseKit/Promise+When.h>
#import "ITCAction+Action.h"
#import "Options.h"

#import "ReportDownloadAction.h"


NSString *const kStdoutnotification=@"kStdoutnotification";
NSString *const kStderrornotification =@"kStderrornotification";



@implementation ITunesConnector

- (id)initWithArguments:(NSArray*)args
{
    if (self = [super init]) {
        _exitStatus = 0;
        _standardOutput = [NSFileHandle fileHandleWithStandardOutput];
        _standardError = [NSFileHandle fileHandleWithStandardError];
        _arguments = [args copy];
        _options = [[Options alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(outputMessageToStdout:) name:kStdoutnotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(outputMessageToStderror:) name:kStderrornotification object:nil];
        
    }
    return self;
}

-(void) dealloc{

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) run
{
    __block BOOL moreWorkToDo = YES;
    NSRunLoop* runLoop = [NSRunLoop currentRunLoop];
    
    [_standardOutput printString:@"ITunesConnector rocks! \n"];
    
    dispatch_promise(^{
        return [self readUserDataFromDisk]; // background Promise
    }).then(^(NSArray *args){
        
        PMKPromise *readArgumentsPromise =[_options processArguments:[args mutableCopy]];
        
        
        ITunesConnector * __weak weakSelf = self;
        PMKPromise *showHelpPromise = [weakSelf showHelpIfNeeded:_options];
        
        [PMKPromise when:@[readArgumentsPromise,showHelpPromise]].then(^(NSArray *results){
            
            Action *genericAction = nil;
            NSArray *actions = results.firstObject;
            
            if ([actions.firstObject  isKindOfClass:[Action class]]){
                genericAction = (Action*)actions.firstObject;
            }
            
            if ([(NSString*)results.lastObject isEqualToString:@"Stop"] ){
                Action *emptyAction = [[Action alloc] init];
                return [emptyAction performActionWithOptions:nil]; // Go to the super class implementation and do nothing
            } else{
                [_standardOutput printString:@"iTunesConnector will perform %@. It might take several seconds. Please wait" , genericAction.className ];
                return [genericAction  performActionWithOptions:_options];
            }
            
        }).then(^(NSString* outputMessage)
                {
                    [_standardOutput printString:@"%@ \n",outputMessage];
                    _exitStatus = EXIT_SUCCESS;
                    
                }).catch(^(NSError* error){
                
                    NSError *validError = (_options.error)?_options.error:error;
                    [self manageError:validError];
                    _exitStatus = EXIT_FAILURE;
                    
                }).finally(^{
                    
                    moreWorkToDo = NO;
                    
                }) ;
    });// end of then call after dispatch_promise
    
    // wait for the promises to be fulfilled
    while (moreWorkToDo )
    {
        [runLoop runUntilDate:[NSDate date]];
        
    }
    
}
#pragma mark - Promesify Actions

-(PMKPromise*) showHelpIfNeeded:(Options*) options
{
    return  [PMKPromise new:^(PMKFulfiller fulfill, PMKRejecter reject) {
        if (options.showHelp)
        {
            [self printUsage];
            fulfill(@"Stop");
        }else
        {
            fulfill(@"Continue");
        }
    }];
}



-(PMKPromise*) readUserDataFromDisk {
    
    return [PMKPromise new:^(PMKFulfiller fulfill, PMKRejecter reject) {
        
        if ([_arguments containsObject:@"-h"])
        {
              fulfill(_arguments);
            return;
        }
     
        NSFileManager *fm = [NSFileManager defaultManager];
        if ([fm isReadableFileAtPath:@".itc-arg.json"]) {
            NSError *readError = nil;
            NSString *argumentsString = [NSString stringWithContentsOfFile:@".itc-arg.json"
                                                                  encoding:NSUTF8StringEncoding error:&readError];
            
            if (readError)
            {
                [_standardError printString:@"ERROR: Cannot read '.itc-arg' file: %@\n", [readError localizedFailureReason]];
                _exitStatus = EXIT_FAILURE;
                reject([NSError errorWithDomain:@"ITCErrorD" code:1 userInfo:@{@"out_message":@"fail reading"}]);
                return;
            }
            
            NSError *JSONError = nil;
            NSArray *argumentsList = [NSJSONSerialization JSONObjectWithData:[argumentsString dataUsingEncoding:NSUTF8StringEncoding]
                                                                          options:0
                                                                            error:&JSONError];
            if (JSONError)
            {
                [_standardError printString:@"ERROR: couldn't parse json: %@: %@\n", argumentsString, [JSONError localizedDescription]];
                _exitStatus = EXIT_FAILURE;
                reject([NSError errorWithDomain:@"ITCErrorD" code:2 userInfo:@{@"out_message":@"fail parsin"}]);
                return;
            }
            
            [_standardOutput printString:@"ItunesConnector: Parameters taken from disk see .itc-arg.json  \n"];
            
            NSArray *joinedArgs = [argumentsList arrayByAddingObjectsFromArray:_arguments];
            fulfill(joinedArgs);
            
        }else
        {
            if (_arguments.count == 0)
            {
                _arguments =@[@"-h"];
            }
            fulfill(_arguments);
        }
    }];
}

#pragma mark - Print Messages
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
    //Show help for each action
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


- (void) outputMessageToStdout:(NSNotification *) notification
{
    NSString *outputMessage =[notification object];
    [_standardOutput printString:@"%@ \n",outputMessage];
}



- (void) outputMessageToStderror:(NSNotification *) notification
{
    NSString *outputMessage =[notification object];
    [_standardError printString:@"%@ \n",outputMessage];
}


#pragma mark - Error Management

-(void) manageError:(NSError*) error
{
    NSString * errorMenssage = @"--Unknown";
    
    if ([error.domain isEqualToString:kOptionsErrorDomain])
    {
        errorMenssage =[NSString stringWithFormat:@"%@",error.userInfo[@"output_message"]];
    }else
    {
        errorMenssage =[NSString stringWithFormat:@"%@",error.description];
    }
    
    [_standardError printString:@"ERROR: %@\n",errorMenssage];
}

@end
