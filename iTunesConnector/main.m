//
//  main.m
//  iTunesConnector
//
//  Created by Fernando Canon on 29/03/15.
//  Copyright (c) 2015 Fernando Canon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ITunesConnector.h"


int main(int argc, const char * argv[]) {
    @autoreleasepool {
  
        NSArray *arguments = [[NSProcessInfo processInfo] arguments];
        
        ITunesConnector *connector = [[ITunesConnector alloc] initWithArguments:[arguments subarrayWithRange:NSMakeRange(1, arguments.count - 1)]];
        
        [connector run];
        
        return connector.exitStatus;
    }
    return 0;
}
