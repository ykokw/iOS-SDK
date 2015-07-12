#import "AddHomeViewController.h"
#import "ButtonUtils.h"
#import "DataHolder.h"
#import "HomeDetailableViewController.h"
#import "HomesTableViewController.h"
#import "MODEApp.h"
#import "OverlayViewProtocol.h"
#import "UIColor+Extentions.h"
#import "Utils.h"

@interface HomesTableViewController ()

@property(strong, nonatomic) UIButton* editButton;
@property (strong, nonatomic) NSMutableArray* homes;

@end

@implementation HomesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
      
    self.navigationController.navigationBar.barTintColor = [UIColor defaultThemeColor];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    setupProfileButton(self.navigationItem, self, @selector(handleProfile));

    self.navigationItem.titleView = setupTitle(@"Homes");
    self.navigationItem.hidesBackButton = YES;
    
    [self fetchHomes];

}

-(void)handleProfile
{
    [self performSegueWithIdentifier:@"ProfileSegue" sender:nil];
}

- (void) fetchHomes
{
    DataHolder* data = [DataHolder sharedInstance];
    
    [MODEAppAPI getHomes:data.clientAuth userId:data.clientAuth.userId
              completion:^(NSArray *homes, NSError *err) {
                  
                  NSLog(@"%@", self.navigationController);

                  if (homes != nil) {
                      self.homes = [NSMutableArray arrayWithArray:homes];
                      [self.tableView reloadData];
                  } else {
                      showAlert(err);
                  }
              }];
}

- (void) addItem
{
    [self performSegueWithIdentifier:@"AddHomeSegue" sender:nil];
    
}

- (void) editItem
{
    NSLog(@"editItem");
    self.editButton.selected = !self.editing;
    [self setEditing:!self.editing animated:true];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView* tableHeaderView = tableView.tableHeaderView;
    UIView *view=[[UIView alloc]init];
    setupAddButton(view, self, @selector(addItem));
    self.editButton = setupEditButton(view, self, @selector(editItem));
    [tableHeaderView insertSubview:view atIndex:0];
    
    return view;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50.0;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.homes != nil) {
        return self.homes.count;
    }
    
    return 0;
}

-(void)handleEdit:(UIButton*)sender
{
    NSLog(@"hoge %ld", sender.tag);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *cellIdentifier = @"homeCellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
  
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        
        // set up edit icon at the right of UITableViewCell.
        UIButton *editButton = [UIButton buttonWithType:UIButtonTypeInfoDark];
        [editButton setImage:[UIImage imageNamed:@"Edit.png"] forState:UIControlStateNormal];
        editButton.frame = CGRectMake(0, 0, 50, 50);
        editButton.tintColor = [UIColor bodyTextColor];
        [editButton addTarget:self action:@selector(handleEdit:) forControlEvents:UIControlEventTouchUpInside];
        cell.editingAccessoryView = editButton;
        cell.editingAccessoryView.userInteractionEnabled = YES;
    }

    // Need to set the tag to identify accessory icon click.
    // The tag is used as index in handleEdit:
    UIButton* editButton = (UIButton*)cell.editingAccessoryView;
    editButton.tag = indexPath.row;
    
    MODEHome* home = self.homes[indexPath.row];
    NSString* cellvalue = home.name;
    
    cell.textLabel.text = cellvalue;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
      [self performSegueWithIdentifier:@"HomeDetailSegue" sender:nil];
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.editing;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    DataHolder* data = [DataHolder sharedInstance];
        MODEHome* targetHome = self.homes[indexPath.row];
        [self.homes removeObjectAtIndex:indexPath.row];
        [MODEAppAPI deleteHome:data.clientAuth homeId:targetHome.homeId completion:^(MODEHome *home, NSError *err) {
            if (err != nil) {
                showAlert(err);
                [self fetchHomes];
            }
        }];
    
    // Then perform the action on the tableView
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [tableView beginUpdates];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                         withRowAnimation:UITableViewRowAnimationFade];
        [tableView endUpdates];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"HomeDetailSegue"]) {
        HomeDetailableViewController *view = [segue destinationViewController];
        NSIndexPath* indexPath = [self.tableView indexPathForSelectedRow];
        view.targetHome = [self.homes objectAtIndex:indexPath.row];
    } else if ([segue.identifier isEqualToString:@"AddHomeSegue"]){
        AddHomeViewController* view = [segue destinationViewController];
        view.sourceVC = self;
    }
}

@end
