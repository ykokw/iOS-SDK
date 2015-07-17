#import "LMDataHolder.h"
#import "LMMessages.h"
#import "LMOverlayViewProtocol.h"
#import "LMRegisteredViewController.h"
#import "LMUtils.h"
#import "ModeApp.h"

@interface LMRegisteredViewController ()

@property(strong, nonatomic) IBOutlet UILabel *message;

@end

@implementation LMRegisteredViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.hidesBackButton = YES;
    setupMessage(self.message, MESSAGE_REGISTERED, 15.0);
}

- (void)removeOverlayViews
{
    removeOverlayViewSub(self.navigationController, nil);
}

- (IBAction)handleSkip:(id)sender
{
    [self performSegueWithIdentifier:@"@console" sender:self];
}
@end
