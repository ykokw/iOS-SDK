#import "LMAddHomeViewController.h"
#import "LMButtonUtils.h"
#import "LMDataHolder.h"
#import "LMHomeDetailViewController.h"
#import "LMHomesTableViewController.h"
#import "LMUIColor+Extentions.h"
#import "LMUtils.h"
#import "MODEApp.h"

@interface LMHomesTableViewController ()

@property(strong, nonatomic) UIButton *editButton;
@property(strong, nonatomic) NSMutableArray *homes;
@property(strong, nonatomic) MODEHome *editTargetHome;

@end

@implementation LMHomesTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    setupProfileButton(self.navigationItem, self, @selector(handleProfile));

    self.navigationItem.titleView = setupTitle(@"Homes");
    self.navigationItem.hidesBackButton = YES;
    
    [self fetchHomes];
}

- (void)handleProfile
{
    [self performSegueWithIdentifier:@"ProfileSegue" sender:nil];
}

- (void)fetchHomes
{
    [self fetchHomesWithBlock:nil];
}

- (void)updateHomes:(NSArray*)homes err:(NSError*)err
{
    DLog(@"Get homes;");
    for (MODEHome *home in homes) {
        DLog(@"Home: %@", home);
    }
    self.homes = [NSMutableArray arrayWithArray:homes];
    [self.tableView reloadData];
}

- (void)fetchHomesWithBlock:(void(^)())complete
{
    __weak __typeof__(self) weakSelf = self;
    LMDataHolder *data = [LMDataHolder sharedInstance];
    [MODEAppAPI getHomes:data.clientAuth userId:data.clientAuth.userId
          completion:^(NSArray *homes, NSError *err) {
              if (err != nil) {
                  showAlert(err);
              } else {
                  [weakSelf updateHomes:homes err:err];
              }
              
              if (complete != nil) {
                  complete();
              }
          }];
}

- (void)handleAdd
{
    [self performSegueWithIdentifier:@"AddHomeSegue" sender:nil];
    
}

- (void)handleEdit
{
    DLog(@"handleEdit");
    self.editButton.selected = !self.editing;
    [self setEditing:!self.editing animated:true];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *tableHeaderView = tableView.tableHeaderView;
    UIView *view=[[UIView alloc]init];
    setupAddButton(view, self, @selector(handleAdd));
    self.editButton = setupEditButton(view, self, @selector(handleEdit));
    [tableHeaderView insertSubview:view atIndex:0];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.homes != nil) {
        return self.homes.count;
    }
    
    return 0;
}

- (void)handleEdit:(UIButton*)sender
{
    self.editTargetHome = [self.homes objectAtIndex:sender.tag];
    
    [self performSegueWithIdentifier:@"EditHomeSegue" sender:nil];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"homeCellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
  
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        // Set up edit icon at the right of UITableViewCell.
        UIButton *editButton = [UIButton buttonWithType:UIButtonTypeInfoDark];
        [editButton setImage:[UIImage imageNamed:@"Edit.png"] forState:UIControlStateNormal];
        editButton.frame = CGRectMake(0, 0, 50, 50);
        editButton.tintColor = [UIColor bodyTextColor];
        [editButton addTarget:self action:@selector(handleEdit:) forControlEvents:UIControlEventTouchUpInside];
        cell.editingAccessoryView = editButton;
        cell.editingAccessoryView.userInteractionEnabled = YES;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    // Need to set the tag to identify accessory icon click.
    // The tag is used as index in handleEdit:
    UIButton *editButton = (UIButton*)cell.editingAccessoryView;
    editButton.tag = indexPath.row;
    
    MODEHome *home = self.homes[indexPath.row];
    setCellLabel(cell.textLabel, home.name, [UIColor cellTextColor], 16.0);
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"HomeDetailSegue" sender:nil];
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.editing;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    __weak __typeof__(self) weakSelf = self;
    LMDataHolder *data = [LMDataHolder sharedInstance];
    MODEHome *targetHome = self.homes[indexPath.row];
    [weakSelf.homes removeObjectAtIndex:indexPath.row];
    [MODEAppAPI deleteHome:data.clientAuth homeId:targetHome.homeId
        completion:^(MODEHome *home, NSError *err) {
            if (err != nil) {
                showAlert(err);
                [weakSelf fetchHomes];
            }
        }];
    
    // Then perform the action on the tableView
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [tableView beginUpdates];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
            withRowAnimation:UITableViewRowAnimationFade];
        [tableView endUpdates];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"HomeDetailSegue"]) {
        LMHomeDetailViewController *view = [segue destinationViewController];
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        view.targetHome = [self.homes objectAtIndex:indexPath.row];
    } else if ([segue.identifier isEqualToString:@"AddHomeSegue"] ||
        [segue.identifier isEqualToString:@"EditHomeSegue"] ){
        LMAddHomeViewController *view = [segue destinationViewController];
        view.sourceVC = self;
        
        if([segue.identifier isEqualToString:@"EditHomeSegue"]) {
            view.targetHome = self.editTargetHome;
        }
    }
}

- (IBAction)pullToRefresh:(UIRefreshControl *)sender {
    
    [self fetchHomesWithBlock:^{
        [sender endRefreshing];
    }];
}
@end
