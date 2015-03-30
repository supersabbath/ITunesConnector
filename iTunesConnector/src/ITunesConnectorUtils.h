//
//  ITunesConnectorUtils.h
//  iTunesConnector
//
//  Created by Fernando Canon on 29/03/15.
//  Copyright (c) 2015 Fernando Canon. All rights reserved.
//
// This class was inspired in Facebooks XCToolsUtils.


#import <Foundation/Foundation.h>

/**
    Common tasks presented as functions
 
 */

NSDictionary *LaunchTaskAndCaptureOutput(NSTask *task, NSString *description);

NSString *ProcessDataFromStoutPut(NSFileHandle *stOut);

NSString *XcodeDeveloperDirPath(void);

