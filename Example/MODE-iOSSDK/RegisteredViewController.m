#import "DataHolder.h"
#import "ModeApp.h"
#import "Messages.h"
#import "OverlayViewProtocol.h"
#import "RegisteredViewController.h"
#import "Utils.h"

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
