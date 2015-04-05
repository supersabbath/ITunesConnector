//
//  ITunesConnector.h
//  iTunesConnector
//
//  Created by Fernando Canon on 28/03/15.
//  Copyright (c) 2015 Fernando Canon. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSString *const kStdoutnotification;
FOUNDATION_EXPORT NSString *const kStderrornotification;

@class Options;

@interface ITunesConnector : NSObject

@property (nonatomic, strong) Options *options;
@property (nonatomic, strong) NSFileHandle *standardOutput;
@property (nonatomic, strong) NSFileHandle *standardError;
@property (nonatomic, strong) NSArray *arguments;
@property (nonatomic, assign) int exitStatus;


-(id) initWithArguments:(NSArray*)args;
-(void) run;
@end


@class PMKPromise;
/*
 Interface declaration only for Testing
 */
@interface ITunesConnector (private)
-(PMKPromise*) showHelpIfNeeded:(Options*) options;
-(void) printUsage;
-(void) manageError:(NSError*) error;
-(void) outputMessageToStdout:(NSNotification *) notification;
@end