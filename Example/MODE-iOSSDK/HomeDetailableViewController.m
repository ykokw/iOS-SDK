#import "AddDeviceInConsoleViewController.h"
#import "AddHomeMemberViewController.h"
#import "ButtonUtils.h"
#import "DataHolder.h"
#import "HomeDetailableViewController.h"
#import "MODEApp.h"
#import "UIColor+Extentions.h"
#import "Utils.h"

@interface HomeDetailableViewController ()

@property(strong, nonatomic) UIButton* editButton;
@property(strong, nonatomic) UIButton* membersButton;
@property(strong, nonatomic) UIButton* devicesButton;

// Here we assume only either array is non nil to show which.
@property(strong, nonatomic) NSMutableArray* members;
@property(strong, nonatomic) NSMutableArray* devices;

@end

@implementation HomeDetailableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.barTintColor = [UIColor defaultThemeColor];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
   
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Prof" style:UIBarButtonItemStylePlain target:self action:@selector(handleProfile)];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
  
    self.navigationItem.titleView = setupTitle(self.targetHome.name);
    
    [self fetchMembers];
}

-(void) handleProfile
{
    NSLog(@"Profile");
    [self performSegueWithIdentifier:@"ProfileSegue" sender:nil];
}

- (void)fetchMembers
{
    self.membersButton.selected = true;
    self.devicesButton.selected = false;

    self.editButton.selected = false;
    [self setEditing:false animated:true];

    DataHolder* data = [DataHolder sharedInstance];
    [MODEAppAPI getHomeMembers:data.clientAuth homeId:self.targetHome.homeId
                    completion:^(NSArray *members, NSError *err) {
                        if (members != nil) {
                            self.devices = nil;
                            self.members = [NSMutableArray arrayWithArray:members];
                            for (MODEHomeMember* member in members) {
                                if (member.verified == false) {
                                    member.name = @"(Unverified)";
                                }
                            }
                            [self.tableView reloadData];
                        } else {
                            showAlert(err);
                        }
                    }];
}

- (void)fetchDevices
{
    self.membersButton.selected = false;
    self.devicesButton.selected = true;
    
    self.editButton.selected = false;
    [self setEditing:false animated:true];
    
    DataHolder* data = [DataHolder sharedInstance];
    [MODEAppAPI  getDevices:data.clientAuth homeId:self.targetHome.homeId
        completion:^(NSArray *devices, NSError *err) {
            if (devices != nil) {
                self.devices = [NSMutableArray arrayWithArray:devices];
                self.members = nil;
                [self.tableView reloadData];
            } else {
                showAlert(err);
            }
        }];
}

- (UIButton*) createRoundButton:(CGRect)rect title:(NSString*)title selector:(SEL)selector selected:(BOOL)selected
{
    UIButton *button=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = rect;
    button.tintColor = [UIColor defaultThemeColor];
    [button setTitle:title forState:UIControlStateNormal];
    button.selected = selected;
    [button sizeToFit];
    [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];

    return button;
}

- (void) addItem
{
    if (self.members) {
        [self performSegueWithIdentifier:@"AddHomeMemberSegue" sender:nil];
    } else if (self.devices) {
        [self performSegueWithIdentifier:@"AddDeviceSegue" sender:nil];
    }
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
    
    self.devicesButton = [self createRoundButton:CGRectMake(170, 10, 100, 50) title:@"Devices" selector:@selector(fetchDevices)
                                        selected:self.devices ? true : false
                          ];
    self.membersButton = [self createRoundButton:CGRectMake(80, 10, 100, 50) title:@"Members" selector:@selector(fetchMembers)
                                        selected:self.members ? true : false];

    [view addSubview:self.membersButton];
    [view addSubview:self.devicesButton];
    
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
        cellvalue = [device.name isEqual:@""] ? device.tag : device.name;
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


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.editing;
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {

    DataHolder* data = [DataHolder sharedInstance];
    if (self.members != nil) {
        MODEHomeMember* targetMember = self.members[indexPath.row];
        [self.members removeObjectAtIndex:indexPath.row];
        [MODEAppAPI deleteHomeMember:data.clientAuth homeId:self.targetHome.homeId userId:targetMember.userId
            completion:^(MODEHomeMember *member, NSError *err) {
                if (err != nil) {
                    showAlert(err);
                    [self fetchMembers];
                }
            }];
    } else {
        MODEDevice* targetDevice = self.devices[indexPath.row];
        [self.devices removeObjectAtIndex:indexPath.row];
        [MODEAppAPI deleteDevice:data.clientAuth deviceId:targetDevice.deviceId
            completion:^(MODEDevice *device, NSError *err) {
                if (err != nil) {
                    showAlert(err);
                    [self fetchDevices];
                }
        }];
    }
        
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
    if ([segue.identifier isEqualToString:@"AddHomeMemberSegue"]) {
        AddHomeMemberViewController *view = [segue destinationViewController];
        view.sourceVC = self;
    } else {
        AddDeviceInConsoleViewController *view = [segue destinationViewController];
        view.sourceVC = self;
    }
}

@end
