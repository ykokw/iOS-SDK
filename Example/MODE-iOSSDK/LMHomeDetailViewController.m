#import "LMAddDeviceInConsoleViewController.h"
#import "LMAddHomeMemberViewController.h"
#import "LMButtonUtils.h"
#import "LMDataHolder.h"
#import "LMDeviceManager.h"
#import "LMHomeDetailViewController.h"
#import "LMUIColor+Extentions.h"
#import "LMUtils.h"
#import "MODEApp.h"

#define DEVICES_IDX 0
#define MEMBERS_IDX 1

@interface LMHomeDetailViewController ()

@property(strong, nonatomic) UIView  *tableHeaderSubView;
@property(strong, nonatomic) UIButton *editButton;
@property(strong, nonatomic) UISegmentedControl *devicesOrMembersControl;

// Here we assume only either array is non nil to show which.
@property(strong, nonatomic) NSMutableArray *items;

// We should revisit this lookup table, it could be the root cause of leak.
@property(strong, nonatomic)NSMutableDictionary *deviceIdToSwitches;
// We need this status dictionary to sync out of order query result arrival.
@property(strong, nonatomic)NSMutableDictionary *deviceIdToStatus;
@property(strong, nonatomic)NSMutableDictionary *deviceIdToCell;

@end

@implementation LMHomeDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.deviceIdToSwitches = [[NSMutableDictionary alloc]init];
    self.deviceIdToStatus = [[NSMutableDictionary alloc]init];
    self.deviceIdToCell = [[NSMutableDictionary alloc]init];
    
    setupProfileButton(self.navigationItem, self, @selector(handleProfile));
    self.navigationItem.titleView = setupTitle(self.targetHome.name);
    
    [[LMDeviceManager sharedInstance] addMODEDeviceDelegate:self];

    [self fetchDevices];

    self.tableView.allowsSelection = NO;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[LMDeviceManager sharedInstance]removeMODEDeviceDelegate:self];
}

- (void)didReceiveMemoryWarning
{
    [[LMDeviceManager sharedInstance]removeMODEDeviceDelegate:self];
}

- (BOOL)isMembers
{
    return self.devicesOrMembersControl.selectedSegmentIndex == MEMBERS_IDX;
}

- (void)handleProfile
{
    [self performSegueWithIdentifier:@"ProfileSegue" sender:nil];
}


- (void)fetchMembers
{
    [self fetchMembersWithBlock:nil];
}

- (void)fetchMembersWithBlock:(void(^)())complete
{
    self.editButton.selected = false;
    [self setEditing:false animated:true];
    
     __weak __typeof__(self) weakSelf = self;
    LMDataHolder *data = [LMDataHolder sharedInstance];
    [MODEAppAPI getHomeMembers:data.clientAuth homeId:self.targetHome.homeId
        completion:^(NSArray *members, NSError *err) {
            DLog(@"Get home members:");
            
            if (err != nil) {
                showAlert(err);
            } else if ([weakSelf isMembers]){
                if (members != nil) {
                    weakSelf.items = [NSMutableArray arrayWithArray:members];
                    for (MODEHomeMember *member in members) {
                        DLog(@"Member: %@", member);
                        if (member.verified == false) {
                            member.name = @"(Unknown)";
                        }
                    }
                    [weakSelf.tableView reloadData];
                }
            } else {
                DLog(@"Devices is selected. No update needed.");
            }
            
            if (complete != nil) {
                complete();
            }
        }];
}

- (void)fetchDevices
{
    [self fetchDevicesWithBlock:nil];
}

- (void)updateDeviceItems:(NSArray*)devices err:(NSError*)err
{
    if (![self isMembers]){
        if (devices != nil) {
            for (MODEDevice *device in devices) {
                DLog(@"Device: %@", device);
            }
            self.items = [NSMutableArray arrayWithArray:devices];
            [[LMDeviceManager sharedInstance] queryDeviceStatus:devices];
            [self.tableView reloadData];
        }
    } else {
        DLog(@"Members is selected, so not updated");
    }
}

- (void)fetchDevicesWithBlock:(void(^)())complete
{
    self.editButton.selected = false;
    [self setEditing:false animated:true];
    
    __weak __typeof__(self) weakSelf = self;
    LMDataHolder *data = [LMDataHolder sharedInstance];
    [MODEAppAPI  getDevices:data.clientAuth homeId:self.targetHome.homeId
        completion:^(NSArray *devices, NSError *err) {
            DLog(@"Get devices:");
            
            if (err != nil) {
                showAlert(err);
            } else {
                [weakSelf updateDeviceItems:devices err:err];
            }
            if (complete != nil) {
                complete();
            }
        }];
}

- (void)handleAdd
{
    [self performSegueWithIdentifier:
        ([self isMembers] ? @"AddHomeMemberSegue" : @"AddDeviceSegue") sender:nil];
}

- (void)handleEdit
{
    self.editButton.selected = !self.editing;
    [self setEditing:!self.editing animated:true];
}

- (void)handleDevicesOrMembers:(UISegmentedControl*)segment
{
    if ([self isMembers]) {
        [self fetchMembers];
    } else {
        [self fetchDevices];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (self.tableHeaderSubView == nil) {
        UIView *tableHeaderView = tableView.tableHeaderView;
        UIView *view=[[UIView alloc]init];
        setupAddButton(view, self, @selector(handleAdd), self.view.frame.size.width);
        self.editButton = setupEditButton(view, self, @selector(handleEdit));
        [tableHeaderView insertSubview:view atIndex:0];
    
        NSArray *itemArray = [NSArray arrayWithObjects: @"Devices", @"Members", nil];
        UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:itemArray];
        segmentedControl.frame = CGRectMake(self.view.frame.size.width/2 - 90, 10, 180, 30);
        [segmentedControl addTarget:self action:@selector(handleDevicesOrMembers:) forControlEvents: UIControlEventValueChanged];
        segmentedControl.tintColor = [UIColor defaultThemeColor];
        
        segmentedControl.selectedSegmentIndex = DEVICES_IDX;
        
        [view addSubview:segmentedControl];
        self.devicesOrMembersControl = segmentedControl;
        
        self.tableHeaderSubView = view;
        
    }
    return self.tableHeaderSubView;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    return 75.0;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.items.count;
}

- (NSString *) getCellIdentifier
{
    return [self isMembers] ? @"membersCellId" : @"devicesCellId";
}

- (void)receivedEvent:(int)deviceId status:(BOOL)status
{
    UISwitch *switchView = self.deviceIdToSwitches[[NSNumber numberWithInt:deviceId]];
    [switchView setOn:status animated:TRUE];
    // The status is used when UISwitch is intialized in setupCell.
    self.deviceIdToStatus[[NSNumber numberWithInt:deviceId]] = [NSNumber numberWithBool:status];
}

- (void)receivedButtonPressed:(int)deviceId
{
    UITableViewCell *cell = self.deviceIdToCell[[NSNumber numberWithInt:deviceId]];
    
    [UIView animateWithDuration:0.0 delay:0.0 options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionCurveEaseInOut animations:^
    {
        [cell setHighlighted:YES animated:YES];
    } completion:^(BOOL finished)
    {
        [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionCurveEaseInOut animations:^
         {
             [cell setHighlighted:NO animated:YES];
         } completion: NULL];
    }];
}


- (void)handleSwitch:(UISwitch*)sw
{
    if ([self isMembers]) {
        NSDictionary *reason = @{@"reason": @"Wrong state"};
        showAlert([NSError errorWithDomain:@"App" code:-1 userInfo:reason]);
        return;
    }
    
    MODEDevice *device = self.items[sw.tag];
    [[LMDeviceManager sharedInstance] triggerSwitch:device.deviceId status:sw.on];
}

- (void)setupCell:(UITableViewCell*) cell row:(long)row
{
    NSString *cellvalue;
    
    if([self isMembers]) {
        MODEHomeMember *member = self.items[row];
        cellvalue = member.name;
        
        setCellLabel(cell.detailTextLabel, formatPhonenumberFromString(member.phoneNumber),
                     [UIColor subCellTextColor], 14.0);
        
        if (member.verified == false) {
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 120, 20)];
            setCellLabel(label, @"Pending Verification", [UIColor subCellTextColor], 12.0);
            label.textAlignment = NSTextAlignmentRight;
            cell.accessoryView = label;
        }
    } else {
        MODEDevice *device = self.items[row];
        cellvalue = [device.name isEqual:@""] ? device.tag : device.name;
        
        UISwitch *switchView = (UISwitch*)cell.accessoryView;
        
        self.deviceIdToSwitches[[NSNumber numberWithInt:device.deviceId]] = switchView;
        // This initialization is needed, because status query would be already received.
        switchView.on = self.deviceIdToStatus[[NSNumber numberWithInt:device.deviceId]] ? TRUE : FALSE;

        self.deviceIdToCell[[NSNumber numberWithInt:device.deviceId]] = cell;
    }
    setCellLabel(cell.textLabel, cellvalue, [UIColor cellTextColor], 15.0);
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = [self getCellIdentifier];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        //cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIView *bgColorView = [[UIView alloc] init];
        bgColorView.backgroundColor = [UIColor defaultThemeColorWithAlpha:0.40];
        [cell setSelectedBackgroundView:bgColorView];
        
        if ([self isMembers] == false) {
            UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
            cell.accessoryView = switchView;
            switchView.tag = indexPath.row;
            [switchView setOn:NO animated:YES];
            [switchView addTarget:self action:@selector(handleSwitch:) forControlEvents:UIControlEventValueChanged];
        }
    }
    
    [self setupCell:cell row:indexPath.row];
    
    return cell;
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
    if ([self isMembers]) {
        MODEHomeMember *targetMember = self.items[indexPath.row];
        [self.items removeObjectAtIndex:indexPath.row];
        [MODEAppAPI deleteHomeMember:data.clientAuth homeId:self.targetHome.homeId userId:targetMember.userId
            completion:^(MODEHomeMember *member, NSError *err) {
                if (err != nil) {
                    showAlert(err);
                    // Failed to delete and view and model is out of sync, so call fetchMembers again.
                    [weakSelf fetchMembers];
                }
            }];
    } else {
        MODEDevice *targetDevice = self.items[indexPath.row];
        [self.items removeObjectAtIndex:indexPath.row];
        [MODEAppAPI deleteDevice:data.clientAuth deviceId:targetDevice.deviceId
            completion:^(MODEDevice *device, NSError *err) {
                if (err != nil) {
                    showAlert(err);
                    // Failed to delete and view and model is out of sync, so call fetchDevices again.
                    [weakSelf fetchDevices];
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
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"AddHomeMemberSegue"]) {
        LMAddHomeMemberViewController *view = [segue destinationViewController];
        view.sourceVC = self;
    } else if ([segue.identifier isEqualToString:@"AddDeviceSegue"]){
        LMAddDeviceInConsoleViewController *view = [segue destinationViewController];
        view.sourceVC = self;
    }
}

- (IBAction)pullToRefresh:(UIRefreshControl *)sender {
    
    void(^complete)() = ^{
        [sender endRefreshing];
    };
    
    if ([self isMembers]) {
        [self fetchMembersWithBlock:complete];
    } else {
        [self fetchDevicesWithBlock:complete];
    }}

@end
