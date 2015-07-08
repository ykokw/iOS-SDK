#import "LumosViewController.h"
#import "DataHolder.h"

@implementation LumosViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    if ( [[DataHolder sharedInstance] clientAuth] != nil ) {
        NSString* segue = [DataHolder sharedInstance].members.homeId == 0 ? @"BypassSignUpSegue" : @"@console";
        [self performSegueWithIdentifier:segue sender:self];
    }
}

@end
