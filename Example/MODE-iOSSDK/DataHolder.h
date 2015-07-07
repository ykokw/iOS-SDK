//
//  DataHolder.h
//  MODE-iOSSDK
//
//  Created by TakanoNaoki on 7/6/15.
//  Copyright (c) 2015 Naoki Takano. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MODEData.h"

@interface DataHolder : NSObject

+ (DataHolder *)sharedInstance;

@property (assign, nonatomic) int projectId;
@property (strong, nonatomic) NSString* appId;

@property (strong, nonatomic) MODEClientAuthentication* clientAuth;
@property (strong, nonatomic) NSString* userName;
@property (strong, nonatomic) NSString* phoneNumber;


-(void) saveData;
-(void) loadData;

@end
