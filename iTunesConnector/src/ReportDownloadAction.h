//
//  ReportDownloadAction.h
//  iTunesConnector
//
//  Created by Fernando Canon on 03/04/15.
//  Copyright (c) 2015 Fernando Canon. All rights reserved.
//

#import "ITCAction+Action.h"

@interface ReportDownloadAction : Action

@property (nonatomic, strong) NSString *period;
@property (nonatomic, strong) NSString *reportDate;
@property (nonatomic, strong) NSString *vendor;

-(PMKPromise*) downloadReport;
@end


@interface ReportDownloadAction (private)

-(NSString*) dateFromString:(NSString *) stringDate;

@end