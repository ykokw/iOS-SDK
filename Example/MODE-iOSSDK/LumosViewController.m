#import "DataHolder.h"
#import "LumosViewController.h"
#import "Messages.h"
#import "Utils.h"

@interface LumosViewController ()

@property(strong, nonatomic) IBOutlet UILabel* message;

@end

@implementation LumosViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    setupMessage(self.message, MESSAGE_SAMPLE_APP);
    
    UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Background.png"]];
    
    [self.view addSubview:backgroundImage];
    [self.view sendSubviewToBack:backgroundImage];
    
    if ( [[DataHolder sharedInstance] clientAuth].token != nil ) {
         NSString* segue = [DataHolder sharedInstance].members.homeId == 0 ? @"BypassSignUpSegue" : @"@console";
        [self performSegueWithIdentifier:segue sender:self];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillDisappear:animated];
}

@end
