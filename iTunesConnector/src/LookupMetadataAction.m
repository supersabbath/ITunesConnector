//
//  LookupMetadataAction.m
//  iTunesConnector
//
//  Created by Fernando Canon on 30/03/15.
//  Copyright (c) 2015 Fernando Canon. All rights reserved.
//

#import "LookupMetadataAction.h"
#import "Options.h"

@implementation LookupMetadataAction


+ (NSString *)name
{
    
    return @"lookupMetadata";
}

+ (NSArray *)options
{
    return
    @[
      [Action actionOptionWithName:@"path"
                           aliases:nil
                       description:@"OUTPATH where the itmsp created archive will be placed."
                         paramName:@"OUTPATH"
                             mapTo:@selector(setOutPutPath:)],
      [Action actionOptionWithName:@"vendor_id"
                           aliases:nil
                       description:@"VENDOR_ID [App SKU] See ITunnes connect for app sku."
                         paramName:@"VENDOR_ID"
                             mapTo:@selector(setAppSKU:)],
      ]
    ;
}

/*

 iTMSTransporter -m lookupMetadata -u [iTunes Connect username] -p [iTunes Connect password] -vendor_id [App SKU] -destination [destination path for App Store Package]

 @param
 */
- (PMKPromise*) performActionWithOptions:(Options *)options
{
    LookupMetadataAction * __weak weakSelf = self;
    
    return [PMKPromise new:^(PMKFulfiller fulfill, PMKRejecter reject) {
        
        NSMutableArray *arguments = [@[@"-m",[LookupMetadataAction name]] mutableCopy];
        
        [arguments addObjectsFromArray:[options concatArgumentsForITMSTransporter]];
        
        [arguments addObjectsFromArray:[weakSelf generateArgumentsForCommand]];
       
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
    
    if (self.appSKU != nil && self.outPutPath != nil) {
        
        arguments =@[@"-vendor_id",self.appSKU,@"-destination",self.outPutPath];
    } else {
        NSLog(@"ITunesConnector lookupMetadata  needs vendor and destination path");
      //  abort();
    }
    
    return arguments;
}
@end
