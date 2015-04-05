//
//  UploadAction.h
//  iTunesConnector
//
//  Created by Fernando Canon on 29/03/15.
//  Copyright (c) 2015 Fernando Canon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ITCAction+Action.h"


@interface UploadAction : Action

@property (nonatomic,strong) NSString *ipaPath;

@end


@class PMKPromise;

@interface UploadAction (private) // header for testing
- (PMKPromise*) performActionWithOptions:(Options *)options;

@end