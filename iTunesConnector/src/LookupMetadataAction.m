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
                           aliases:@[@"pa",@"path"]
                       description:@"OUTPATH where the itmsp created archive will be placed."
                         paramName:@"OUTPATH"
                             mapTo:@selector(setOutPutPath:)],
      [Action actionOptionWithName:@"vendor_id"
                           aliases:@[@"v",@"vendor_id"]
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
    if (options == nil) // security check also used for returning a done nothing promise
    {
        return [super performActionWithOptions:nil];
    }
    
    return [PMKPromise new:^(PMKFulfiller fulfill, PMKRejecter reject) {
        
        NSMutableArray *arguments = [@[@"-m",[LookupMetadataAction name]] mutableCopy];

        [options concatArgumentsForITMSTransporter].then(^(NSMutableArray *moreArgs){
            
            [arguments addObjectsFromArray:moreArgs];
            
            return [self generateArgumentsForCommand];
            
        }).then(^(NSMutableArray* evenMoreArgs){
            
            [arguments addObjectsFromArray:evenMoreArgs];
            if (RunITMSTransporterCommand(arguments, @"lookupMetadata"))
            {
                NSString *message =[NSString stringWithFormat:@"%@ succeded file at: %@",[LookupMetadataAction name], self.outPutPath];
                fulfill(message);
                
            }else{
                reject(nil);
            }
        }).catch(^(NSError* error) {
            
            reject(error);
        });
    }];
}



-(PMKPromise *) generateArgumentsForCommand
{
    
    return [PMKPromise new:^(PMKFulfiller fulfill, PMKRejecter reject) {
        
        NSArray *arguments = nil;

        if (self.appSKU != nil && self.outPutPath != nil)
        {
            arguments =@[@"-vendor_id",self.appSKU,@"-destination",self.outPutPath];
            fulfill(arguments);
        }else {
            
            NSError *error = [NSError errorWithDomain:@"LookupMetadaErrorDomain" code:missing_parameter_error userInfo:@{@"output_message":@"ITunesConnector lookupMetadata  needs vendor and destination path"}];
      
            reject(error);
        }
    }];
}
@end
