#import "LMDataHolder.h"
#import "LMDeviceManager.h"
#import "MODEAppDelegate.h"
#import "LMUtils.h"

@implementation MODEAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillTerminate:) name:UIApplicationWillTerminateNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults addObserver:self
               forKeyPath:@"projectId"
                  options:NSKeyValueObservingOptionNew
                  context:NULL];

    [defaults addObserver:self
               forKeyPath:@"isEmailLogin"
                  options:NSKeyValueObservingOptionNew
                  context:NULL];

    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    // Override point for customization after application launch.
    [[LMDataHolder sharedInstance] loadData];
    return YES;
}

-(void)observeValueForKeyPath:(NSString *)keyPath
                     ofObject:(id)object
                       change:(NSDictionary *)change
                      context:(void *)context
{
    LMDataHolder* data = [LMDataHolder sharedInstance];
    [data loadProjectId];

    if (data.oldProjectId != data.projectId ||
        data.oldIsEmailLogin != data.isEmailLogin) {
        // When projectId is changed, reset the session and go back to the root view.
        
        data.oldProjectId = data.projectId;
        data.oldIsEmailLogin = data.isEmailLogin;
        
        [data saveOldProjectId];
        
        data.members = [[LMDataHolderMembers alloc] init];
        data.clientAuth = [[MODEClientAuthentication alloc] init];

        // Stop WebSocket connection because projectId is changed.
        [[LMDeviceManager sharedInstance] stopListenToEvents];
        [data saveData];
        
        UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
        [navigationController popToRootViewControllerAnimated:YES];
    }
}

- (void)appDidBecomeActive:(NSNotification *)note
{
    DLog(@"appDidBecomeActive");
    [self observeValueForKeyPath:nil ofObject:nil change:nil context:nil];
    
    [[LMDeviceManager sharedInstance] reconnect];
}

- (void)appWillResignActive:(NSNotification *)note
{
    DLog(@"appWillResignActive");
    [[LMDeviceManager sharedInstance] stopListenToEvents];
}

- (void)appWillTerminate:(NSNotification *)note
{
     DLog(@"appWillTerminate");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillTerminateNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSUserDefaultsDidChangeNotification object:nil];
    
    [[LMDataHolder sharedInstance] saveData];
    
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
