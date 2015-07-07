//
//  LumosViewController.m
//  MODE-iOSSDK
//
//  Created by TakanoNaoki on 7/7/15.
//  Copyright (c) 2015 Naoki Takano. All rights reserved.
//

#import "LumosViewController.h"
#import "DataHolder.h"

@implementation LumosViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    if ( [[DataHolder sharedInstance] clientAuth] != nil ) {
        NSString* segue = [DataHolder sharedInstance].members.homeId == 0 ? @"BypassSignUpSegue" : @"BypassCongratzSegue";
        [self performSegueWithIdentifier:segue sender:self];
    }
}

@end
