//
//  UploadAction.m
//  iTunesConnector
//
//  Created by Fernando Canon on 29/03/15.
//  Copyright (c) 2015 Fernando Canon. All rights reserved.
//

#import "UploadAction.h"

@implementation UploadAction
+ (NSString *)name
{

    return @"upload";
}

+ (NSArray *)options
{
    return
    @[
      [Action actionOptionWithName:@"ipa"
                           aliases:nil
                       description:@"PATH where created archive will be placed."
                         paramName:@"PATH"
                             mapTo:@selector(setIpaPath:)],
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
