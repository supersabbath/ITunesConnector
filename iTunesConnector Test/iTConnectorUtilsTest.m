//
//  iTConnectorUtilsTest.m
//  iTunesConnector
//
//  Created by Fernando Canon on 29/03/15.
//  Copyright (c) 2015 Fernando Canon. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>

#define EXP_SHORTHAND
#import <Expecta/Expecta.h>

//Sut
#import "ITunesConnectorUtils.h"


@interface iTConnectorUtilsTest : XCTestCase

@end

@implementation iTConnectorUtilsTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testShouldReturnXcodePath
{
    //when
    NSString *path =XcodeDeveloperDirPath();
    //then
    expect(path).to.contain(@"Xcode");
}


- (void)testXcodePathShouldEndInContentsDir
{
    //when
    NSString *path =XcodeDeveloperDirPath();
    //then
    expect([path lastPathComponent]).to.equal(@"Contents");
}
@end
