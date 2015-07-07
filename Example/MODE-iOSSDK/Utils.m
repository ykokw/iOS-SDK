#import <Foundation/Foundation.h>

void showAlert(NSError* err) {
    
    NSString* msg = err.userInfo[@"reason"];
    NSLog(@"Failed to call createUser: %@", err);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:err.domain
                                                    message:msg
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];

}