//
//  iTunesConnector_Test.m
//  iTunesConnector Test
//
//  Created by Fernando Canon on 29/03/15.
//  Copyright (c) 2015 Fernando Canon. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>

#define EXP_SHORTHAND
#import <Expecta/Expecta.h>
#import <PromiseKit.h>

#import <OCMock/OCMock.h>

//sut
#import "ITunesConnector.h"

//collaborator
#import "ReportDownloadAction.h"
#import "Options.h"
#import "NSFileHandle+Print.h"


@interface iTunesConnector_Test : XCTestCase

@end

@implementation iTunesConnector_Test

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testITunesConnectorShouldStopAndPrintHelp {
    
    XCTestExpectation *catchExpectation  =  [self expectationWithDescription:@"help call"];

    //give
    NSArray *args = @[@"-h",@"-p",@"pass",@"-u",@"fer",@"upload"];
    Options *opts = [[Options alloc] init];
    id optionsPartialMock = OCMPartialMock(opts);
    
   //OCMStub([optionsPartialMock processArguments:[OCMArg any]]).andReturn([self fakeEmptyPromise]);

    ITunesConnector *connector = [[ITunesConnector alloc] initWithArguments:args];
    id connectorPartialMock = OCMPartialMock(connector);
    
    //when
    connector.options = optionsPartialMock;
    [connector run];
    
    OCMVerify([optionsPartialMock processArguments:[OCMArg any]]);
    OCMVerify([connectorPartialMock printUsage]);
    
    if (connector.exitStatus == 1) {
        [catchExpectation fulfill];
    }
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        NSLog(@"Timeout");
    }];
}
/*
 This test expects to verify the call to stdout with the succes message in LookupMetadaAction
 */
- (void)testITunesConnectorShouldPerformLookup{
    
    XCTestExpectation *catchExpectation  =  [self expectationWithDescription:@"lookup call"];
    
    //give
    NSArray *args =@[@"-p",@"pass",@"-u",@"fer",@"lookupMetadata",@"-vendor_id",@"id",@"-path",@"."];
    
    //when
    ITunesConnector *connector = [[ITunesConnector alloc] initWithArguments:args];
    id connectorPartialMock = OCMPartialMock(connector);
    [connector run];

   OCMVerify([connectorPartialMock outputMessageToStdout:[OCMArg isNotNil]]); // test that message was post with a notification

    
    if (connector.exitStatus == EXIT_SUCCESS) {
        [catchExpectation fulfill];
    }
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
        NSLog(@"Timeout");
    }];
}

/**
 Test for upload command
 */
- (void)testITunesConnectorShouldPerformUpload{
    
    XCTestExpectation *catchExpectation  =  [self expectationWithDescription:@"upload command"];
    
    //give
    NSArray *args =@[@"-p",@"pass",@"-u",@"fer",@"upload",@"-ipa",@"~/Desktop/file.ipa"];
    
    //when
    ITunesConnector *connector = [[ITunesConnector alloc] initWithArguments:args];
    id connectorPartialMock = OCMPartialMock(connector);
    
     [connector run];
    
    OCMVerify([connectorPartialMock outputMessageToStdout:[OCMArg any]]);
        
    if (connector.exitStatus == EXIT_SUCCESS) {
        [catchExpectation fulfill];
    }
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        NSLog(@"Timeout");
    }];
}



- (void)testITunesConnectorShouldDoNothingDueWronAction {
    
    XCTestExpectation *catchExpectation  =  [self expectationWithDescription:@"action call"];
    
    //give
    NSArray *args = @[@"-p",@"pass",@"-u",@"fer",@"wronAction"];
    
    //when
    ITunesConnector *connector = [[ITunesConnector alloc] initWithArguments:args];
    id connectorPartialMock = OCMPartialMock(connector);
    [connector run];
    
    OCMVerify([connectorPartialMock manageError:[OCMArg any]]);
    
    if (connector.exitStatus == 1) {
        [catchExpectation fulfill];
    }
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
        NSLog(@"Timeout");
    }];
}

/*
 Helper for mock classes and stubs
 */
-(PMKPromise*) fakeEmptyPromise
{
 return [PMKPromise new:^(PMKFulfiller fulfill, PMKRejecter reject) {

     Action *genericAction = [[Action alloc] init];
     
     fulfill(@[genericAction]);
 }];
}
@end
