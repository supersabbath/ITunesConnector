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
                           aliases:@[@"i",@"ipa"]
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
    if (options == nil)
    {
        return [super performActionWithOptions:nil];
    }
    
    return [PMKPromise new:^(PMKFulfiller fulfill, PMKRejecter reject) {
        
       __block NSMutableArray * arguments = [@[@"-m",[UploadAction name]] mutableCopy];
        
        [options concatArgumentsForITMSTransporter].then(^(NSMutableArray *moreArgs){
            
            [arguments addObjectsFromArray:moreArgs];
            return [self generateArgumentsForCommand];
            
        }).then(^(NSMutableArray* evenMoreArgs){
            
            [arguments addObjectsFromArray:evenMoreArgs];
            
            if (RunITMSTransporterCommand(arguments, @"upload"))
            {
                NSString *__strong message =[NSString stringWithFormat:@"%@ succeded uploading %@",[UploadAction name],self.ipaPath];
                fulfill(message);
                
            }else{
                reject(nil);
            }
            
        }).catch(^(NSError* error) {
            
            reject(error);
        });
    }];
}



-(PMKPromise*) generateArgumentsForCommand
{

    return [PMKPromise new:^(PMKFulfiller fulfill, PMKRejecter reject) {

        NSArray *arguments = nil;
        if (self.ipaPath != nil )
        {
            arguments =@[@"-f",self.ipaPath];
            fulfill(arguments);
        }
        else
        {
            NSError *error =  [NSError errorWithDomain:@"UploadErrorDomain" code:missing_parameter_error userInfo:@{@"output_message":@"Upload command needs a ipa"}];
 
            reject(error);
        } }];
}

/* TODO:
 Executes this command :
 iTMSTransporter -m verify -f [path to App Store Package] -u [iTunes Connect user name] -p [iTunes Connect password]
 */

@end
