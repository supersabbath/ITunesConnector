//
//  LookupMetadataAction.h
//  iTunesConnector
//
//  Created by Fernando Canon on 30/03/15.
//  Copyright (c) 2015 Fernando Canon. All rights reserved.
//

#import "ITCAction+Action.h"

@interface LookupMetadataAction : Action

@property (nonatomic,strong) NSString *appSKU;
@property (nonatomic,strong) NSString *outPutPath;

@end
