//
//  OptionsTest.m
//  iTunesConnector
//
//  Created by Fernando Canon on 31/03/15.
//  Copyright (c) 2015 Fernando Canon. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>

#import <PromiseKit/PromiseKit.h>
#import "Options.h"
#import "LookupMetadataAction.h"

#import "ITCAction+Action.h"
#import <Promise.h>

#define EXP_SHORTHAND
#import <Expecta/Expecta.h>


@interface OptionsTest : XCTestCase {
    Options *options;
}
@end

@implementation OptionsTest

- (void)setUp {
    
    [super setUp];
    options = [[Options alloc] init];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    
}

- (void)testParameterHelp {
    
    NSString *error = nil;
    [options consumeArguments:[@[@"-help"]mutableCopy] errorMessage:&error];
    
    expect(options.showHelp).to.beTruthy();
    
}


- (void)testNonParameters
{
    
    NSString *error = nil;
    
    [options consumeArguments:[@[@""]mutableCopy] errorMessage:&error];
    
    expect(options.showHelp).to.beFalsy();
    
    expect(options.actions).to.haveCountOf(0);
}


-(void) testWrongOptions {
    
    
    NSString *error = nil;
    
    [options consumeArguments:[@[@"-wrong"]mutableCopy] errorMessage:&error];
    
    expect(error).toNot.beNil();
    
}

- (void) testOptionsShouldHaveUploadAction {
    
    NSString *error = nil;
    
    [options consumeArguments:[@[@"upload"]mutableCopy] errorMessage:&error];
    
    expect(options.actions).to.haveCountOf(1);
    
}

- (void)testUserShouldBeFer {
    
    NSString *error = nil;
    
    [options consumeArguments:[@[@"-user",@"fer"]mutableCopy] errorMessage:&error];
    
    expect(options.user).to.equal(@"fer");
    
    [options consumeArguments:[@[@"-u",@"fer"]mutableCopy] errorMessage:&error];
    
    expect(options.user).to.equal(@"fer");
}

- (void)testPasswordShouldnotBeNil {
    
    NSString *error = nil;
    
    [options consumeArguments:[@[@"-p",@"fake"]mutableCopy] errorMessage:&error];
    
    expect(options.passwd).to.equal(@"fake");
    
    [options consumeArguments:[@[@"-password",@"fake"]mutableCopy] errorMessage:&error];
    
    expect(options.passwd).toNot.beNil();
}


- (void)testActionsSholdContainUploadActionInstace {
    
    
    NSString *error = nil;
    
    [options consumeArguments:[@[@"-p",@"fake",@"upload"]mutableCopy] errorMessage:&error];
    
    expect([options.actions firstObject]).toNot.beNil();
}


- (void)testProcessOptionsShouldCallCathPromise
{
    
    XCTestExpectation *catchExpectation  =  [self expectationWithDescription:@"cacth"];
    
    [options processArguments:[@[@"invalid",@"error",@"WTF"] mutableCopy]].then(^(NSArray *args){
        
        XCTFail(@"This test shouldn't pass through here");
        
    }).catch(^(NSError* error){
        
        expect(error.domain).to.equal(@"OptionsErrorDomain");
        
        [catchExpectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:1 handler:^(NSError *error) {
        NSLog(@"Timeout");
    }];
}

- (void)testProcessOptionShouldCallThen
{
    
    XCTestExpectation *catchExpectation  =  [self expectationWithDescription:@"then call"];
    
    [options processArguments:[@[@"-p",@"pass",@"-u",@"fer",@"upload"] mutableCopy]].then(^(NSArray *args){
       
        
        expect(args).to.haveCountOf(1);
        expect(args.firstObject).to.beInstanceOf(NSClassFromString(@"UploadAction"));
        
        [catchExpectation fulfill];
        
    }).catch(^(NSError* error){
        
        XCTFail(@"This test shouldn't pass through here");
        
    });
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        NSLog(@"Timeout");
    }];
}


- (void)testShouldPerformLookupAction
{

    XCTestExpectation *catchExpectation  =  [self expectationWithDescription:@"lookup call"];
    
    [options processArguments:[@[@"-p",@"pass",@"-u",@"fer",@"lookupMetadata"] mutableCopy]].then(^(NSArray *args){
        
        
        expect(args).to.haveCountOf(1);
        expect(args.firstObject).to.beInstanceOf(NSClassFromString(@"LookupMetadataAction"));
        
        LookupMetadataAction *lookupAction = [args firstObject];
        
        [lookupAction performActionWithOptions:options].then(^{
            XCTFail(@"dd");
        });
        
        [catchExpectation fulfill];
        
    }).catch(^(NSError* error){
        
        XCTFail(@"This test shouldn't pass through here");
        
    });
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        NSLog(@"Timeout");
    }];

}
@end
