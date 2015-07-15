#import "LMDataHolder.h"
#import "LMLumosViewController.h"
#import "LMMessages.h"
#import "LMUtils.h"
#import "LMUIColor+Extentions.h"

@interface LMLumosViewController ()

@property(strong, nonatomic) IBOutlet UILabel* message;

@end

@implementation LMLumosViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barTintColor = [UIColor defaultThemeColor];

    setupMessageWithColor(self.message, MESSAGE_SAMPLE_APP, [UIColor whiteColor]);
    
    UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Background.png"]];
    
    [self.view addSubview:backgroundImage];
    [self.view sendSubviewToBack:backgroundImage];
    
    if ([[LMDataHolder sharedInstance] clientAuth].token != nil) {
         NSString* segue = @"@console";
        [self performSegueWithIdentifier:segue sender:self];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillDisappear:animated];
}

@end
