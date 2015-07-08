#import "CongratzViewController.h"
#import "Messages.h"
#import "Utils.h"

@interface CongratzViewController ()

@property(strong, nonatomic) IBOutlet UILabel* message;

@end

@implementation CongratzViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    setupMessage(self.message, MESSAGE_CONGRATZ);

}
- (IBAction)handleTakeMeHome:(id)sender
{
       [self performSegueWithIdentifier:@"@console" sender:self];
}

@end
