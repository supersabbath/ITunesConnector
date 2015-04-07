//
//  UploadActionTest.m
//  iTunesConnector
//
//  Created by Fernando Canon on 03/04/15.
//  Copyright (c) 2015 Fernando Canon. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>

//SUT
#import "UploadAction.h"
#import "LookupMetadataAction.h"
#import "ReportDownloadAction.h"


//Colaborators
#import "Options.h"
#import <PromiseKit/Promise.h>
#import "ITCAction+Action.h"

#import <OCMock/OCMock.h>
#define EXP_SHORTHAND
#import <Expecta/Expecta.h>


@interface ActionsClassesTest : XCTestCase {
    Options *opt ;
}
@end

@implementation ActionsClassesTest

- (void)setUp {
    [super setUp];
    opt =[[Options alloc] init];
}


- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


- (void)testShouldPerformActionShouldFailAndCallErrorMethod
{
    __block XCTestExpectation *catchExpectation  =  [self expectationWithDescription:@"nil user"];
    //given
    
    opt.passwd = @"pw";
    opt.user = nil;
    
    //when
    UploadAction *action = [[UploadAction alloc] init];
    [action performActionWithOptions:opt].then(^(NSString *message){
        
        XCTFail(@"This test must never pass over here");
    }).catch(^(NSError* error){
        //then
        expect(error.userInfo[@"output_message"]).to.beginWith(@"ITunesConnector Should have");
        [catchExpectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        NSLog(@"Timeout");
    }];
}


- (void)testUploadActionShoulFailDueNilParameter {
    
    __block XCTestExpectation *catchExpectation  =  [self expectationWithDescription:@"nil user"];
    //given
    
    opt.passwd = @"pw";
    opt.user = @"user";
    
    //when
    UploadAction *action = [[UploadAction alloc] init];
    action.ipaPath = nil;
    [action performActionWithOptions:opt].then(^(NSString *message){
        
        XCTFail(@"This test must never pass over here");
    }).catch(^(NSError* error){
        //then
        expect(error.userInfo[@"output_message"]).to.beginWith(@"Upload command");
        [catchExpectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        NSLog(@"Timeout");
    }];
}


/*
 Lookup tests
 */
- (void) testLookupMetadaWithNoArguments {
    
    __block XCTestExpectation *catchExpectation  =  [self expectationWithDescription:@"lookupmetada void"];
    //given
  
    opt.passwd = @"pw";
    opt.user = @"user";
    
    //when
    LookupMetadataAction *action = [[LookupMetadataAction alloc] init];
    
    [action performActionWithOptions:opt].then(^(NSString *message){
        
        XCTFail(@"This test must never pass over here");
    }).catch(^(NSError* error){
        //then
        expect(error.userInfo[@"output_message"]).to.equal(@"ITunesConnector lookupMetadata  needs vendor and destination path");
        [catchExpectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        NSLog(@"Timeout");
    }];
}


- (void)testReportDownloadActionDateCreation
{
    
    ReportDownloadAction *downloadReport = [[ReportDownloadAction alloc] init];
    //[downloadReport download];
    
    //given Daily
    downloadReport.period = @"Daily";
    NSString *testDate =   [downloadReport dateFromString:@"2014/4/13"];
    //then
    expect(testDate).to.equal(@"20140413");

    //give Monthly
    downloadReport.period = @"Monthly";
    testDate =   [downloadReport dateFromString:@"2014/4/19"];
    //then
    expect(testDate).to.equal(@"20140331");
    
    //give Weekly
    downloadReport.period = @"Weekly";
    
    testDate =   [downloadReport dateFromString:@"2014/4/7"];
    //then
    expect(testDate).to.equal(@"20140413");
    
    testDate =   [downloadReport dateFromString:@"2015/01/13"];
    //then
    expect(testDate).to.equal(@"20150118");

    
    testDate =   [downloadReport dateFromString:@"2015/4/5"];
    //then
    expect(testDate).to.equal(@"20150412");
    
    testDate =   [downloadReport dateFromString:@"2015/01/13"];
    //then
    expect(testDate).to.equal(@"20150118");

}

-(void) testReportActionShouldConsumeArgs {

    ReportDownloadAction *downloadReport = [[ReportDownloadAction alloc] init];
    
    [downloadReport consumeArguments:[@[@"-t",@"weekly",@"-d",@"2015/03/12"] mutableCopy] errorMessage:nil];
    
    expect(downloadReport.period).to.equal(@"weekly");
    expect(downloadReport.reportDate).to.equal(@"20150315");
}

- (void)testReportSholdDownload
{
    __block XCTestExpectation *catchExpectation  =  [self expectationWithDescription:@"download shold work"];
    
    opt.passwd = @"DevPl4yc0_";
    opt.user = @"dev@playco.com";
    
    
    ReportDownloadAction *downloadReport = [[ReportDownloadAction alloc] init];
    
    [downloadReport consumeArguments:[@[@"-t",@"weekly",@"-d",@"2015/03/12",@"-v",@"86626911"]mutableCopy] errorMessage:nil];
    
    
    [downloadReport performActionWithOptions:opt].then(^(NSString *message){
    
        [catchExpectation fulfill];
        expect(message).to.beginWith(@"Report file at");
        
    }).catch(^{
        XCTFail(@"Download fails");
    });
    
    [self waitForExpectationsWithTimeout:15 handler:^(NSError *error) {
        NSLog(@"Timeout");
    }];
}
@end
