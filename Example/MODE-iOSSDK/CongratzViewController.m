//
//  CongratzViewController.m
//  MODE-iOSSDK
//
//  Created by TakanoNaoki on 7/7/15.
//  Copyright (c) 2015 Naoki Takano. All rights reserved.
//

#import "CongratzViewController.h"
#import "ModeApp.h"
#import "DataHolder.h"
#import "Utils.h"

@implementation CongratzViewController

- (IBAction)handleNext:(id)sender {
    DataHolder* data = [DataHolder sharedInstance];
    
    [MODEAppAPI createHome:data.clientAuth name:@"MyHome" timezone:@"America/Los_Angeles" completion:^(MODEHome *home, NSError *err) {
            if (err == nil) {
                data.members.homeId = home.homeId;
                
                [data saveData];
                
                [self performSegueWithIdentifier:@"AddDevicesSegue" sender:self];
            } else {
                showAlert(err);
            }
        }];

}

@end
