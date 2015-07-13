#import "RegisteredViewController.h"
#import "ModeApp.h"
#import "DataHolder.h"
#import "Utils.h"
#import "Messages.h"
#import "OverlayViewProtocol.h"

@interface RegisteredViewController ()

@property(strong, nonatomic) IBOutlet UILabel* message;

@end

@implementation RegisteredViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.hidesBackButton = YES;
    setupMessage(self.message, MESSAGE_REGISTERED);
    
}

-(void) removeOverlayViews{
    removeOverlayViewSub(self.navigationController, nil);
}

- (IBAction)handleSkip:(id)sender {
      [self performSegueWithIdentifier:@"@console" sender:self];
}
@end
