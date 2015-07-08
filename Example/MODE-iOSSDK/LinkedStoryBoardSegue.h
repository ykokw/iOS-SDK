#import <UIKit/UIKit.h>

// This class is for handling transition between multiple storyboards.
// You can specify the destination with "scene_name@storyboard_name".
// If you don't specify "scene_name", it will be forwarded to the initial scene in storyboard.

@interface LinkedStoryBoardSegue : UIStoryboardSegue

+ (UIViewController *)sceneNamed:(NSString *)identifier;

@end
