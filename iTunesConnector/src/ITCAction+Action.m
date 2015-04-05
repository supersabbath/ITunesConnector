//
//  ITCAction+Action.m
//  iTunesConnector
//
//  Created by Fernando Canon on 02/04/15.
//  Copyright (c) 2015 Fernando Canon. All rights reserved.
//

#import "ITCAction+Action.h"

@implementation Action (itunesconnector)

- (PMKPromise*) performActionWithOptions:(Options *)options
{
    return [PMKPromise new:^(PMKFulfiller fulfill, PMKRejecter reject) {
        fulfill(@"nothing to be done!");
    }];
}


@end
