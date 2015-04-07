//
//  ITCAction+Action.h
//  iTunesConnector
//
//  Created by Fernando Canon on 02/04/15.
//  Copyright (c) 2015 Fernando Canon. All rights reserved.
//

/**  This Clas category add methods to Facebook's Action
*/

#import <Foundation/Foundation.h>
#import <PromiseKit/Promise.h>
#include "Action.h"
#import "ITunesConnectorUtils.h"



typedef enum : NSUInteger {
    unexpected_error,
    missing_parameter_error,
    Download_error
} ActionErrorCode;

@class Options;

@interface Action (itunesconnector)
/**  This method returns a promise that performs the acction for the Action Class.
 
 Could be overide in the subclases UploadAction, LookupMetaDataAction
 
 @param options Options for the itmstransporter comman
 @return A promise
 */
- (PMKPromise*) performActionWithOptions:(Options *)options;
-(NSError *) errorForMessage:(NSString *)message andCode:(NSUInteger)code;

 
@end


