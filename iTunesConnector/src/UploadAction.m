//
//  UploadAction.m
//  iTunesConnector
//
//  Created by Fernando Canon on 29/03/15.
//  Copyright (c) 2015 Fernando Canon. All rights reserved.
//

#import "UploadAction.h"
#import "Options.h"
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
                       description:@"PATH local path for .ipa file"
                         paramName:@"PATH"
                             mapTo:@selector(setIpaPath:)]
  
      ];
}
/**
 iTMSTransporter -m upload -f [path to App Store Package] -u [iTunes Connect user name] -p [iTunes Connect password]
 */

- (PMKPromise*) performActionWithOptions:(Options *)options
{
    UploadAction * __weak weakSelf = self;
    
    return [PMKPromise new:^(PMKFulfiller fulfill, PMKRejecter reject) {
        
        NSMutableArray *arguments = [@[@"-m",[UploadAction name]] mutableCopy];
        
        [arguments addObjectsFromArray:[weakSelf generateArgumentsForCommand]];
        
        [arguments addObjectsFromArray:[options concatArgumentsForITMSTransporter]];
        
      
        
        if (RunITMSTransporterCommand(arguments, @"lookupMetadata", @"Metadata")){
#warning fer ojo
            fulfill(@"success");
        }else{
            reject(nil);
        }
        
    }];
}

-(NSArray *) generateArgumentsForCommand {
    
    NSArray *arguments = nil;
    if (self.ipaPath != nil )
    {
        arguments =@[@"-f",self.ipaPath];
    
    } else {
        NSLog(@"ITunesConnector Should have password and user");
        abort();
    }
    
    return arguments;
}


@end
