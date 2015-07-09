#import "ButtonUtils.h"
#import "DataHolder.h"
#import "HomeDetailableViewController.h"
#import "MODEApp.h"
#import "UIColor+Extentions.h"
#import "Utils.h"

@interface HomeDetailableViewController ()

// Here we assume only either array is non nil to show which.
@property(strong, nonatomic) NSArray* members;
@property(strong, nonatomic) NSArray* devices;

@end

@implementation HomeDetailableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.navigationController.navigationBar.barTintColor = [UIColor defaultThemeColor];
    
    [self fetchMembers];
}

- (void)fetchMembers
{
    DataHolder* data = [DataHolder sharedInstance];
    [MODEAppAPI getHomeMembers:data.clientAuth homeId:self.targetHome.homeId
                    completion:^(NSArray *members, NSError *err) {
                        if (members != nil) {
                            self.devices = nil;
                            self.members = members;
                            [self.tableView reloadData];
                        } else {
                            showAlert(err);
                        }
                    }];
}

- (void)fetchDevices
{
    DataHolder* data = [DataHolder sharedInstance];
    [MODEAppAPI  getDevices:data.clientAuth homeId:self.targetHome.homeId
        completion:^(NSArray *devices, NSError *err) {
            if (devices != nil) {
                self.devices = devices;
                self.members = nil;
                [self.tableView reloadData];
            } else {
                showAlert(err);
            }
        }];
}

- (UIButton*) createRoundButton:(CGRect)rect title:(NSString*)title selector:(SEL)selector
{
    UIButton *button=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = rect;
    button.tintColor = [UIColor defaultThemeColor];
    [button setTitle:title forState:UIControlStateNormal];
    [button sizeToFit];
    [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];

    return button;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView* view = setupEditButtonsInSectionHeader(tableView.tableHeaderView);
 
    [view addSubview:[self createRoundButton:CGRectMake(80, 10, 100, 50) title:@"Members" selector:@selector(fetchMembers)]];
    [view addSubview:[self createRoundButton:CGRectMake(170, 10, 100, 50) title:@"Devices" selector:@selector(fetchDevices)]];
    
    return view;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50.0;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.members != nil) {
        return self.members.count;
    } else if(self.devices != nil) {
        return self.devices.count;
    }
    
    return 0;
}

- (NSString*) getCellIdentifier
{
    return self.members ? @"membersCellId" : @"devicesCellId";
}

- (void) setupCell:(UITableViewCell*) cell row:(long)row
{
    NSString* cellvalue;
    
    if(self.members) {
        MODEHomeMember* member = self.members[row];
        cellvalue = member.name;
    } else {
        MODEDevice* device = self.devices[row];
        cellvalue = device.name;
    }
    cell.textLabel.text = cellvalue;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *cellIdentifier = [self getCellIdentifier];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    [self setupCell:cell row:indexPath.row];
    
    return cell;
}


/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
