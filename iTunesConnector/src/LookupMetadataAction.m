//
//  LookupMetadataAction.m
//  iTunesConnector
//
//  Created by Fernando Canon on 30/03/15.
//  Copyright (c) 2015 Fernando Canon. All rights reserved.
//

#import "LookupMetadataAction.h"

@implementation LookupMetadataAction


+ (NSString *)name
{
    
    return @"lookupMetadata";
}

+ (NSArray *)options
{
    return
    @[
      [Action actionOptionWithName:@"lookupMetadata"
                           aliases:nil
                       description:@"OUTPATH where the itmsp created archive will be placed."
                         paramName:@"OUTPATH"
                             mapTo:@selector(setOutPutPath:)],
      ];
}


- (BOOL)performActionWithOptions:(Options *)options xcodeSubjectInfo:(XcodeSubjectInfo *)xcodeSubjectInfo
{
    //    NSArray *arguments = [options concatArgumentsForITMSTransporter]
    //
    //
    //    return RunXcodebuildAndFeedEventsToReporters(arguments,
    //                                                 @"build",
    //                                                 [options scheme],
    //                                                 [options reporters]);
    
    return YES;
}

@end
