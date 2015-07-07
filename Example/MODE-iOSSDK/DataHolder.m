//
//  DataHolder.m
//  MODE-iOSSDK
//
//  Created by TakanoNaoki on 7/6/15.
//  Copyright (c) 2015 Naoki Takano. All rights reserved.
//

#import "DataHolder.h"

@implementation DataHolder

- (id) init
{
    self = [super init];
    if (self)
    {
        self.projectId = 3; // set you projectID here.
        self.appId = @"app1";
//        self.clientAuth = [[MODEClientAuthentication alloc] init];
    }
    return self;
}

+ (DataHolder *)sharedInstance
{
    static DataHolder *_sharedInstance = nil;
    static dispatch_once_t onceSecurePredicate;
    dispatch_once(&onceSecurePredicate,^
                  {
                      _sharedInstance = [[self alloc] init];
                  });
    
    return _sharedInstance;
}

-(void)saveData
{
    
    NSError* err;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[MTLJSONAdapter JSONDictionaryFromModel:self.clientAuth error:nil]
                                                       options:0 error:&err];
    if (err) {
        NSLog(@"%@", err);
    }
    
    NSString* str = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSLog(@"saved: %@", str);
    
    [[NSUserDefaults standardUserDefaults] setObject:str forKey:@"auth"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)loadData
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"auth"])
    {
        NSString* str = [[NSUserDefaults standardUserDefaults] objectForKey:@"auth"];
        
        NSLog(@"loaded: %@", str);
        
        NSError *err;
        NSData* data = [str dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
        
        MODEClientAuthentication* auth = [MTLJSONAdapter modelOfClass:MODEClientAuthentication.class fromJSONDictionary:dict error:&err];
        
        if (err) {
            NSLog(@"%@", err);
        }
        
        if (auth) {
            NSLog(@"Auth %@", auth);
        }
        
        self.clientAuth = auth;
    }
    else
    {
        NSLog(@"You need to autheticate first");
    }
}

@end
