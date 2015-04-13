//
//  UploadAction.m
//  iTunesConnector
//
//  Created by Fernando Canon on 29/03/15.
//  Copyright (c) 2015 Fernando Canon. All rights reserved.
//

#import "UploadAction.h"
#import "Options.h"
#import "NSData+MD5.h"

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

-(void) setIpaPath:(NSString *)ipaPath
{
    NSString *currentPath = [[NSFileManager defaultManager] currentDirectoryPath];
    _ipaPath  = [currentPath stringByAppendingPathComponent:ipaPath];
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
        
        dispatch_promise(^{
            
           return [self createDirAndMetaData];
            
        }).then(^(NSString *itmspPath){
            
            [arguments addObjectsFromArray:@[@"-f",itmspPath]];
            
            [options concatArgumentsForITMSTransporter].then(^(NSMutableArray *moreArgs){
                
                [arguments addObjectsFromArray:moreArgs];
             
                return [self copyIPAToPackageInPath:itmspPath];
            
            }).then(^{
                
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
            
        });
    }];
}


-(PMKPromise*) copyIPAToPackageInPath:(NSString*) path
{
    return [PMKPromise new:^(PMKFulfiller fulfill, PMKRejecter reject) {
        
        NSError *error = nil;
        NSString *finalPath = [path stringByAppendingPathComponent:[self.ipaPath lastPathComponent]];
        
        if (self.ipaPath != nil )
        {
           NSFileManager *fileManager = [NSFileManager defaultManager];
            
           BOOL success = [fileManager copyItemAtPath:self.ipaPath toPath:finalPath error:&error];
            if (success) {
                
                fulfill(nil);
            }else{
                reject(error);
            }
        }
        else
        {
             error = [NSError errorWithDomain:@"UploadErrorDomain" code:missing_parameter_error userInfo:@{@"output_message":@"Upload command needs a ipa"}];
            
            reject(error);
        } }];
}

-(PMKPromise*) createDirAndMetaData
{
    
    return [PMKPromise new:^(PMKFulfiller fulfill, PMKRejecter reject) {
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *currentPath = [[NSFileManager defaultManager] currentDirectoryPath];
        NSString *packageDir =[currentPath stringByAppendingPathComponent:@"Package.itmsp"];
        NSError *error = nil ;
        
        if ([fileManager fileExistsAtPath:packageDir]) {
            
            BOOL success = [[NSFileManager defaultManager] removeItemAtPath:packageDir error:&error];
            if (!success) {
                reject(error);
            }
        }

        [[NSFileManager defaultManager] createDirectoryAtPath:packageDir withIntermediateDirectories:NO attributes:nil error:&error];
        
        if (error) {
            reject(error);
        }else {
            
            NSData *ipaData = [NSData dataWithContentsOfFile:self.ipaPath];
            NSString *checkSum = [ipaData md5CheckSum];
           
            NSNumber *filesSize = nil;
            if ([fileManager fileExistsAtPath:self.ipaPath]) {
                
                NSDictionary *attributes = [fileManager attributesOfItemAtPath:self.ipaPath error:&error];
                filesSize = attributes[NSFileSize];
                
                NSString *xml =[self xmlStringForFile:self.ipaPath checkSum:checkSum andSize:[filesSize stringValue]];
                NSData *outTxt =[xml dataUsingEncoding:NSUTF8StringEncoding];
                
                NSString *xmlFile = [packageDir stringByAppendingPathComponent:@"metadata.xml"];
                
               BOOL succes = [[NSFileManager defaultManager] createFileAtPath:xmlFile contents:outTxt attributes:nil];
                
                if (succes) {
                    fulfill(packageDir);
                }else{
                    reject(error);
                }
                
            }
        }
    }];
    
}


-(NSString *) xmlStringForFile:(NSString*)fileName checkSum:(NSString*) checkSum andSize:(NSString*)fileSize {
    
    return [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<package version=\"software4.7\" xmlns=\"http://apple.com/itunes/importer\">\n      <software_assets apple_id=\"%@\">\n         <asset type=\"bundle\">\n               <data_file>\n                   <file_name>%@</file_name>\n                 <checksum type=\"md5\">%@</checksum>\n                  <size>%@</size>\n               </data_file>\n            </asset>\n      </software_assets>\n</package>",@"962284784",fileName,checkSum,fileSize];
    
}
/* TODO:
 Executes this command :
 iTMSTransporter -m verify -f [path to App Store Package] -u [iTunes Connect user name] -p [iTunes Connect password]
 */

@end
