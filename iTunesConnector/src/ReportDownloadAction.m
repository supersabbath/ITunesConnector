//
//  ReportDownloadAction.m
//  iTunesConnector
//
//  Created by Fernando Canon on 03/04/15.
//  Copyright (c) 2015 Fernando Canon. All rights reserved.
//

#import "ReportDownloadAction.h"
#import "NSData+Compression.h"
#import <PromiseKit/PromiseKit+Foundation.h>
#import "Options.h"

@interface ReportDownloadAction (){
    NSString *user;
    NSString *password;
    NSString *vendor_id;
}

@end


@implementation ReportDownloadAction

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.period = @"Monthly";
    }

    return self;
}

+ (NSString *)name
{
    
    return @"getReport";
}

+ (NSArray *)options
{
    return
    @[
      [Action actionOptionWithName:@"period"
                           aliases:@[@"t",@"period"]
                       description:@"PERIOD  [day | week | month | year] selected time frame to download the report"
                         paramName:@"PERIOD"
                             mapTo:@selector(setPeriod:)],
      [Action actionOptionWithName:@"date"
                           aliases:@[@"d",@"date"]
                       description:@"DATE  yyyy/mm/dd format"
                         paramName:@"DATE"
                             mapTo:@selector(setReportDate:)],
      [Action actionOptionWithName:@"vendor"
                           aliases:@[@"v",@"vendor"]
                       description:@"VENDOR [VENDOR ID] 8xxxxx See ITunnes connect for vendor id."
                         paramName:@"VENDOR"
                             mapTo:@selector(setVendor:)],
      
      ];
}


/**
 iTMSTransporter -m upload -f [path to App Store Package] -u [iTunes Connect user name] -p [iTunes Connect password]
 */
- (PMKPromise*) performActionWithOptions:(Options *)options
{
    if (options == nil) // security check also used for returning a done nothing promise
    {
        return [super performActionWithOptions:nil];
    }
    
    return [PMKPromise new:^(PMKFulfiller fulfill, PMKRejecter reject)
            {
                [options concatArgumentsForITMSTransporter].then(^(NSMutableArray *moreArgs){
                    
                
                    [self setupUserData:moreArgs];
                    NSMutableURLRequest *reportDownloadURLRequest = [self reportDownloadURLRequest];
                    
                    [NSURLConnection promise:reportDownloadURLRequest].then(^(NSData *reportData,NSHTTPURLResponse *response ,NSData *rawData){
                        
                        NSString *errorMessage = [[response allHeaderFields] objectForKey:@"Errormsg"];
                        if (errorMessage)
                        {
                            NSError *error = [self errorForMessage:errorMessage andCode:Download_error];
                            reject(error);
                            return ;
                        }
                        
                        NSString *originalFilename = [[response allHeaderFields] objectForKey:@"Filename"];
                        originalFilename = [originalFilename stringByDeletingPathExtension];
                        
                        NSData *inflatedReportData = [rawData gzipInflate];
                        NSString * cvsReports = [[NSString alloc] initWithData:inflatedReportData encoding:NSUTF8StringEncoding];
                        NSData *outTxt =[cvsReports dataUsingEncoding:NSUTF8StringEncoding];
                        
                        NSString *currentPath = [[NSFileManager defaultManager] currentDirectoryPath];
                        currentPath = [currentPath stringByAppendingPathComponent:originalFilename];
                        BOOL success = [[NSFileManager defaultManager] createFileAtPath:currentPath contents:outTxt attributes:nil];
                        
                        if (success) {
                            NSString *message = [NSString stringWithFormat:@"Report file at %@",currentPath];
                            fulfill (message);
                        }
                    });
                    
                });
                
            }];
}


-(void) setupUserData:(NSMutableArray*) array{
    
    user = [array objectAtIndex:1]; // secure access.. this array is created for sure
    password  = [array objectAtIndex:3];
}


-(PMKPromise *) generateArgumentsForCommand
{
    return [PMKPromise new:^(PMKFulfiller fulfill, PMKRejecter reject) {
        
        NSArray *arguments = nil;
        
        if (self.period != nil && self.reportDate != nil)
        {
            arguments =@[@"-",self.reportDate,@"-destination",self.period];
            fulfill(arguments);
        }else {
            
            NSError *error = [NSError errorWithDomain:@"LookupMetadaErrorDomain" code:missing_parameter_error userInfo:@{@"output_message":@"ITunesConnector lookupMetadata  needs vendor and destination path"}];
            
            reject(error);
        }
    }];
}


#pragma mark HTTP Connection Methods

-(NSMutableURLRequest*) reportDownloadURLRequest {
    
    NSData *reportDownloadBodyData = [[self reportDownloadBodyString] dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest *reportDownloadRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://reportingitc.apple.com/autoingestion.tft"]];
    [reportDownloadRequest setHTTPMethod:@"POST"];
    [reportDownloadRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [reportDownloadRequest setValue:@"java/1.6.0_26" forHTTPHeaderField:@"User-Agent"];
    [reportDownloadRequest setHTTPBody:reportDownloadBodyData];
    
    return reportDownloadRequest;
}

#pragma mark Date formater
-(void) setReportDate:(NSString*)stringDate
{
    _reportDate = [self dateFromString:stringDate];
}

-(NSString*) dateFromString:(NSString *) stringDate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy/MM/dd"];

    NSDate *today = [dateFormatter dateFromString:stringDate];
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    cal.firstWeekday = 2;
    
    NSDateComponents *components =
    [cal components:NSCalendarUnitWeekday | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:today];
    
    NSDate *selectedDate = nil;
    if ([self.period caseInsensitiveCompare:@"daily"] == NSOrderedSame)
    {
        NSDate *singleDay  = [cal dateFromComponents:components];
        selectedDate = singleDay;
        
    } else if ([self.period caseInsensitiveCompare:@"weekly"] == NSOrderedSame) {
        
        [components setDay:([components day] + ((7 - [components weekday])+1))];
        NSDate *lastWeek  = [cal dateFromComponents:components];
        selectedDate = lastWeek;
        
    }else{  // default case value Monthly
        
        [components setDay:0];
        NSDate *thisMonth = [cal dateFromComponents:components];
        selectedDate = thisMonth;
    }
    
    NSDateFormatter *finalFormater = [[NSDateFormatter alloc] init];
    [finalFormater setDateFormat:@"yyyyMMdd"];
    
    return  [finalFormater stringFromDate:selectedDate];
}


-(NSString* ) reportDownloadBodyString
{
    NSString *escapedUsername = [user stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *escapedPassword = [password stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return [NSString stringWithFormat:@"USERNAME=%@&PASSWORD=%@&VNDNUMBER=%@&TYPEOFREPORT=%@&DATETYPE=%@&REPORTTYPE=%@&REPORTDATE=%@",escapedUsername, escapedPassword, _vendor, @"Sales", _period, @"Summary", _reportDate];
}

-(PMKPromise*) downloadReport {
    
    NSData *reportDownloadBodyData = [[self reportDownloadBodyString] dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest *reportDownloadRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://reportingitc.apple.com/autoingestion.tft"]];
    [reportDownloadRequest setHTTPMethod:@"POST"];
    [reportDownloadRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [reportDownloadRequest setValue:@"java/1.6.0_26" forHTTPHeaderField:@"User-Agent"];
    [reportDownloadRequest setHTTPBody:reportDownloadBodyData];
    
    return  [NSURLConnection promise:reportDownloadRequest].then(^(NSData *reportData,NSHTTPURLResponse *response ,NSData *rawData){
        
        NSString *errorMessage = [[response allHeaderFields] objectForKey:@"Errormsg"];
        if (errorMessage) {
            NSLog(@"  %@", errorMessage);
            return ;
        }
        NSString *originalFilename = [[response allHeaderFields] objectForKey:@"Filename"];
        originalFilename = [originalFilename stringByDeletingPathExtension];
        NSLog(@"  %@", originalFilename);
        
        NSData *inflatedReportData = [rawData gzipInflate];
        NSString * cvsReports = [[NSString alloc] initWithData:inflatedReportData encoding:NSUTF8StringEncoding];
        NSLog(@"%@",cvsReports);
        
        
        NSData *outTxt =[cvsReports dataUsingEncoding:NSUTF8StringEncoding];
        
        NSString *current = [[NSFileManager defaultManager] currentDirectoryPath];
        current = [current stringByAppendingPathComponent:originalFilename];
        [[NSFileManager defaultManager] createFileAtPath:current contents:outTxt attributes:nil];
    });
    
}

@end
