//
//  SignUpViewController.m
//  MODE-iOSSDK
//
//  Created by TakanoNaoki on 7/6/15.
//  Copyright (c) 2015 Naoki Takano. All rights reserved.
//

#import "SignUpViewController.h"
#import "MODEApp.h"
#import "DataHolder.h"
#import "Utils.h"

@interface SignUpViewController ()

@property(strong, nonatomic) IBOutlet UITextField* nameField;
@property(strong, nonatomic) IBOutlet UITextField* phoneNumberField;

@end

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.nameField setPlaceholder:@"Name"];
    [self.phoneNumberField setPlaceholder:@"Phonenumber"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)handleNext:(id)sender {
    DataHolder* data = [DataHolder sharedInstance];
    
    
    [MODEAppAPI createUser:data.projectId phoneNumber:self.phoneNumberField.text name:self.nameField.text
                completion:^(MODEUser *user, NSError *err) {
                    if (err == nil) {
                        data.members.userName = self.nameField.text;
                        data.members.phoneNumber = self.phoneNumberField.text;
                        [self performSegueWithIdentifier:@"VerifyAccountSegue" sender:self];
            
                    } else {
                        showAlert(err);
                    }
                }];
}

@end
