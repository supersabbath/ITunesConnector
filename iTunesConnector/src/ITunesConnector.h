//
//  ITunesConnector.h
//  iTunesConnector
//
//  Created by Fernando Canon on 28/03/15.
//  Copyright (c) 2015 Fernando Canon. All rights reserved.
//

#import <Foundation/Foundation.h>
 

@interface ITunesConnector : NSObject

@property (nonatomic, retain) NSFileHandle *standardOutput;
@property (nonatomic, retain) NSFileHandle *standardError;
@property (nonatomic, copy) NSArray *arguments;
@property (nonatomic, assign) int exitStatus;


-(id) initWithArguments:(NSArray*)args;
-(void) run;
@end


